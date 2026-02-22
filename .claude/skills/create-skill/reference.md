# フロントマター完全リファレンス

SKILL.md の YAML フロントマターで使用可能な全フィールド。

## フィールド一覧

| フィールド | 必須 | 型 | デフォルト | 説明 |
|-----------|------|-----|-----------|------|
| `name` | いいえ | string | ディレクトリ名 | スキルの表示名。小文字・数字・ハイフンのみ（最大64文字） |
| `description` | 推奨 | string | 本文の最初の段落 | スキルの説明。Claude の自動判断に使用される |
| `argument-hint` | いいえ | string | なし | 引数のヒント。例: `[issue-number]`, `[filename] [format]` |
| `disable-model-invocation` | いいえ | boolean | `false` | `true` で Claude の自動呼び出しを無効化 |
| `user-invocable` | いいえ | boolean | `true` | `false` で `/` メニューから非表示 |
| `allowed-tools` | いいえ | string | 全ツール | カンマ区切りのツールリスト |
| `model` | いいえ | string | 継承 | 使用モデル（sonnet, opus, haiku） |
| `context` | いいえ | string | なし | `fork` でサブエージェント実行 |
| `agent` | いいえ | string | `general-purpose` | `context: fork` 時のエージェントタイプ |
| `hooks` | いいえ | object | なし | スキルライフサイクルフック |

## 文字列置換変数

スキルコンテンツ内で使用可能な変数:

| 変数 | 説明 |
|------|------|
| `$ARGUMENTS` | スキル呼び出し時に渡された引数 |
| `${CLAUDE_SESSION_ID}` | 現在のセッション ID |

`$ARGUMENTS` がコンテンツに存在しない場合、引数は末尾に `ARGUMENTS: <value>` として追加される。

## 動的コンテキスト注入

`` !`command` `` 構文でシェルコマンドの出力をスキルコンテンツに注入できる。
コマンドはスキルが Claude に送信される**前**に実行される。

```markdown
## 現在の状態
- ブランチ: !`git branch --show-current`
- 変更ファイル: !`git diff --name-only`
```

## allowed-tools のパターン記法

```yaml
# 特定ツールのみ
allowed-tools: Read, Grep, Glob

# Bash をパターンで制限
allowed-tools: Bash(npm:*), Bash(git:*), Read

# MCP ツール
allowed-tools: mcp__server-name__tool-name
```

## 呼び出し制御の組み合わせ

| 設定 | ユーザ呼び出し | Claude 自動呼び出し | 用途 |
|------|-------------|-------------------|------|
| デフォルト | 可 | 可 | リファレンス型スキル |
| `disable-model-invocation: true` | 可 | 不可 | タスク型（deploy, commit 等） |
| `user-invocable: false` | 不可 | 可 | バックグラウンド知識 |

## SKILL.md テンプレート

### リファレンス型（最小構成）

```yaml
---
name: {{name}}
description: {{英語での説明。いつ使うかを明記}}
---

{{ガイドライン・規約・パターンの記述}}
```

### タスク型（手動トリガー）

```yaml
---
name: {{name}}
description: {{英語での説明}}
disable-model-invocation: true
argument-hint: "[{{引数の説明}}]"
allowed-tools: {{必要なツール}}
---

# {{スキル名}}

{{目的の説明}}

## 実行手順

1. {{ステップ1}}
2. {{ステップ2}}
3. {{ステップ3}}

## 注意事項

{{制約や注意点}}
```

### サブエージェント型（fork 実行）

```yaml
---
name: {{name}}
description: {{英語での説明}}
context: fork
agent: {{Explore|Plan|general-purpose}}
allowed-tools: {{必要なツール}}
---

# {{タスクの説明}}

$ARGUMENTS

## 調査手順

1. {{ステップ1}}
2. {{ステップ2}}

## 出力形式

{{期待する出力の構造}}
```

### 動的コンテキスト注入型

```yaml
---
name: {{name}}
description: {{英語での説明}}
disable-model-invocation: true
---

## 現在の状態

- ブランチ: !`git branch --show-current`
- 最新コミット: !`git log --oneline -5`

## タスク

$ARGUMENTS
```

## ディレクトリ構造

```
skill-name/
├── SKILL.md           # メイン指示（必須）
├── reference.md       # 詳細リファレンス（任意）
├── templates/         # テンプレート集（任意）
│   └── template.md
├── examples/          # 出力例（任意）
│   └── sample.md
└── scripts/           # 実行スクリプト（任意）
    └── helper.py
```

サポートファイルは SKILL.md から参照して、Claude がいつ読むべきか分かるようにする:

```markdown
詳細は [reference.md](reference.md) を参照。
出力例は [examples/sample.md](examples/sample.md) を参照。
```
