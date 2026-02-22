# サブエージェント フロントマター完全リファレンス

## フィールド一覧

| フィールド | 必須 | 型 | デフォルト | 説明 |
|-----------|------|-----|-----------|------|
| `name` | はい | string | — | 一意の識別子。小文字・ハイフンのみ |
| `description` | はい | string | — | Claude が委譲を判断する説明文 |
| `tools` | いいえ | string | 全ツール継承 | 許可するツール（カンマ区切り） |
| `disallowedTools` | いいえ | string | なし | 拒否するツール |
| `model` | いいえ | string | `inherit` | `sonnet`, `opus`, `haiku`, `inherit` |
| `permissionMode` | いいえ | string | `default` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `skills` | いいえ | list | なし | プリロードするスキル名のリスト |
| `hooks` | いいえ | object | なし | ライフサイクルフック |
| `memory` | いいえ | string | なし | 永続メモリスコープ: `user`, `project`, `local` |

## 利用可能なツール

### 内部ツール

- `Read` - ファイル読み込み
- `Write` - ファイル書き込み
- `Edit` - ファイル編集
- `MultiEdit` - 複数箇所編集
- `Bash` - コマンド実行（パターン制限可: `Bash(npm:*)`, `Bash(git:*)`）
- `Grep` - コンテンツ検索
- `Glob` - ファイルパターン検索
- `WebFetch` - Web情報取得
- `WebSearch` - Web検索
- `Task` - サブタスク委任
- `AskUserQuestion` - ユーザへの質問
- `TodoWrite` - タスクリスト管理
- `Skill` - スキル呼び出し

### MCP ツール

MCP ツールは `mcp__server-name__tool-name` 形式で指定。
バックグラウンドサブエージェントでは利用不可。

## テンプレート

### 基本テンプレート

```markdown
---
name: {{name}}
description: {{英語での説明。いつ使うかを明記。Use proactively を含める}}
tools: {{必要なツール}}
model: {{sonnet|opus|haiku|inherit}}
---

{{システムプロンプト: 役割の定義}}

When invoked:
1. {{ステップ1}}
2. {{ステップ2}}
3. {{ステップ3}}

{{実行時の方針・制約}}
```

### 読み取り専用テンプレート

```markdown
---
name: {{name}}
description: {{説明}}
tools: Read, Grep, Glob
model: haiku
---

{{読み取り専用の分析・調査タスクの記述}}
```

### フック付きテンプレート

```markdown
---
name: {{name}}
description: {{説明}}
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "{{検証スクリプトのパス}}"
---

{{フック付きサブエージェントの記述}}
```

### メモリ付きテンプレート

```markdown
---
name: {{name}}
description: {{説明}}
memory: user
---

{{システムプロンプト}}

Update your agent memory as you discover patterns, conventions,
and recurring issues. This builds institutional knowledge across conversations.
```

### スキルプリロード付きテンプレート

```markdown
---
name: {{name}}
description: {{説明}}
skills:
  - {{スキル名1}}
  - {{スキル名2}}
---

{{プリロードされたスキルの知識を活用するタスクの記述}}
```

## 永続メモリのスコープ

| スコープ | 保存場所 | 用途 |
|---------|---------|------|
| `user` | `~/.claude/agent-memory/<name>/` | 全プロジェクト共通の学習（推奨デフォルト） |
| `project` | `.claude/agent-memory/<name>/` | プロジェクト固有（VCS共有可） |
| `local` | `.claude/agent-memory-local/<name>/` | プロジェクト固有（VCS共有不可） |

メモリ有効時は `MEMORY.md` の最初の200行が自動でシステムプロンプトに注入される。

## フック設定

### サブエージェント内フック（frontmatter）

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/lint.sh"
  Stop:
    - hooks:
        - type: command
          command: "./scripts/cleanup.sh"
```

### プロジェクトレベルフック（settings.json）

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "agent-name",
        "hooks": [
          { "type": "command", "command": "./scripts/setup.sh" }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          { "type": "command", "command": "./scripts/teardown.sh" }
        ]
      }
    ]
  }
}
```

## 組み込みサブエージェント一覧

| エージェント | モデル | ツール | 用途 |
|-----------|--------|--------|------|
| Explore | Haiku | 読み取り専用 | コードベース探索・検索 |
| Plan | 継承 | 読み取り専用 | 計画のための調査 |
| general-purpose | 継承 | 全ツール | 複雑なマルチステップタスク |
| Bash | 継承 | Bash | コマンド実行 |
| Claude Code Guide | Haiku | — | Claude Code機能の案内 |
