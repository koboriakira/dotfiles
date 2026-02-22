# エージェントチーム リファレンス

## アーキテクチャ

| コンポーネント | 役割 |
|-------------|------|
| チームリード | チームの作成・メンバーのスポーン・作業の調整 |
| チームメイト | 割り当てられたタスクを独立して実行 |
| タスクリスト | メンバー間で共有される作業項目リスト |
| メールボックス | エージェント間の通信システム |

### データの保存場所

- チーム設定: `~/.claude/teams/{team-name}/config.json`
- タスクリスト: `~/.claude/tasks/{team-name}/`

### config.json の構造

```json
{
  "members": [
    {
      "name": "researcher",
      "agentId": "uuid",
      "agentType": "general-purpose"
    }
  ]
}
```

## チーム起動プロンプトのテンプレート

### 基本テンプレート

```
Create an agent team to {{タスクの説明}}.

Spawn {{N}} teammates:
- {{役割1}}: {{担当範囲の説明}}
- {{役割2}}: {{担当範囲の説明}}
- {{役割3}}: {{担当範囲の説明}}

{{完了後の指示（結果統合、レポート作成等）}}
```

### モデル指定付きテンプレート

```
Create a team with {{N}} teammates to {{タスクの説明}}.
Use {{モデル名}} for each teammate.
```

### プラン承認付きテンプレート

```
Spawn a {{役割}} teammate to {{タスクの説明}}.
Require plan approval before they make any changes.
{{承認基準の説明}}
```

### 品質ゲート付きテンプレート

```
Create an agent team to {{タスクの説明}}.
Only approve plans that include test coverage.
Reject plans that modify the database schema.

Spawn:
- {{役割1}}: {{担当}}
- {{役割2}}: {{担当}}
```

## 操作コマンド

### in-process モード

| 操作 | キー |
|------|------|
| メンバー間を移動 | `Shift+Down` |
| メンバーのセッション表示 | `Enter` |
| メンバーのターン中断 | `Escape` |
| タスクリスト表示 | `Ctrl+T` |

### split-pane モード

- 各メンバーが独立したペインに表示
- ペインをクリックして直接操作

### チーム管理コマンド（リードに指示）

```
# メンバーに直接指示
Tell the {{role}} teammate to {{指示}}

# メンバーのシャットダウン
Ask the {{role}} teammate to shut down

# チームのクリーンアップ（全メンバー停止後）
Clean up the team

# リードの待機指示
Wait for your teammates to complete their tasks before proceeding
```

## 表示モード設定

### settings.json

```json
{
  "teammateMode": "auto"
}
```

| 値 | 動作 |
|----|------|
| `auto` | tmux セッション内なら split、それ以外は in-process |
| `in-process` | メインターミナル内で全メンバー実行 |
| `tmux` | split-pane モード（tmux/iTerm2 が必要） |

### CLI フラグ

```bash
claude --teammate-mode in-process
```

## フック（品質ゲート）

### TeammateIdle

メンバーがアイドル状態になるとき実行。終了コード2でフィードバックを送り、作業を続けさせる。

### TaskCompleted

タスクが完了としてマークされるとき実行。終了コード2で完了を阻止し、フィードバックを送る。

### 設定例（settings.json）

```json
{
  "hooks": {
    "TeammateIdle": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/check-teammate-quality.sh"
          }
        ]
      }
    ],
    "TaskCompleted": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/validate-task-completion.sh"
          }
        ]
      }
    ]
  }
}
```

## 有効なユースケースパターン

| パターン | 説明 | メンバー構成例 |
|---------|------|-------------|
| 並行レビュー | 異なる観点で同時にレビュー | セキュリティ、パフォーマンス、テストカバレッジ |
| 競合仮説デバッグ | 異なる仮説を並行検証 | 仮説A担当、仮説B担当、仮説C担当 |
| レイヤー別開発 | フロントエンド/バックエンド/テスト分担 | FE担当、BE担当、テスト担当 |
| リサーチ+実装 | 調査と実装を分離 | リサーチャー、実装者 |
| Devil's advocate | 提案に対する反論を並行検討 | 提案者、反論者、調停者 |

## 制約・注意事項

- `/resume` や `/rewind` で in-process メンバーは復元されない
- タスクステータスの更新が遅延する場合がある
- シャットダウンは現在のリクエスト完了を待つため時間がかかる場合がある
- 1セッション1チーム、ネスト不可
- リードの移譲は不可
- 権限はリードから継承。スポーン時の個別指定不可
- split-pane は VS Code 統合ターミナル、Windows Terminal、Ghostty では未サポート
