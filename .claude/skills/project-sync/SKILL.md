---
name: project-sync
description: Automatically extract milestones from Obsidian session logs and task board, then create/update Notion projects. Use this skill when syncing session activity to Notion projects, running project pipeline, or when the user mentions "project-sync" or wants to update Notion projects from session logs. Also triggers via cron at 16:00 and 04:00.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, mcp__claude_ai_Notion__notion-search, mcp__claude_ai_Notion__notion-fetch, mcp__claude_ai_Notion__notion-create-pages, mcp__claude_ai_Notion__notion-update-page
---

# project-sync

Obsidian セッションログとタスクボードからマイルストーンを事後的に切り出し、Notion プロジェクトとして自動登録する。

## 定数

```
VAULT_PATH = $HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-vault
SESSION_CODE_DIR = $VAULT_PATH/Claude/Code
SESSION_CHAT_DIR = $VAULT_PATH/Claude/Chat
TASK_BOARD_PATH = $VAULT_PATH/Claude/task-board.md
STATE_FILE = $HOME/.claude/state/project-sync-last-run.txt
NOTION_PROJECT_DATA_SOURCE = collection://1b1f03e3-6bff-43b4-a8a5-924ffa2feeef
```

## 実行フロー

### Step 1: 前回実行日時の取得

`$STATE_FILE` を読み込む。存在しなければ 7 日前をデフォルトとする。

```bash
if [ -f "$HOME/.claude/state/project-sync-last-run.txt" ]; then
  cat "$HOME/.claude/state/project-sync-last-run.txt"
else
  date -v-7d +%Y-%m-%d
fi
```

### Step 2: セッションログの収集

`Claude/Code/` と `Claude/Chat/` 配下の `.md` ファイルを走査する。前回実行日時以降に作成・更新されたファイルのみ対象とする。

ファイル名が `YYYY-MM-DD_` で始まるので、日付部分と前回実行日を比較してフィルタリングする。

各ファイルの frontmatter から `date`, `type`, `repository` を抽出し、本文の `## 概要` セクションからサマリーを取得する。

**ディレクトリ構造からリポジトリを判定する:**
- `Claude/Code/{org}/{repo}/` → `{org}/{repo}`
- `Claude/Chat/` 配下のファイル → リポジトリなし（Chat セッション）

### Step 3: タスクボードの読み込み

`task-board.md` を読み込み、各エントリのステータス（完了/未完了）と日付を把握する。

### Step 4: リポジトリ単位でグルーピング

収集したセッションログをリポジトリごとにまとめる。Chat セッションはテーマが近いもの同士でグルーピングを試みる。

### Step 5: 切り出しロジックの適用

各リポジトリについて以下の判断フローを実行する。詳細は [references/extraction-logic.md](references/extraction-logic.md) を参照。

1. **既存プロジェクト確認** — Notion で同一リポジトリ URL の InProgress プロジェクトを検索。存在すれば新規作成しない
2. **ルーティン判定** — ファイル名やパターンからルーティン作業を除外
3. **テーマ評価** — セッション群からまとまったマイルストーンとして言語化できるか判断
4. **ステータス判定** — 最新セッションが 2 日以上前 かつ タスクボードの関連エントリが全完了 → Done、それ以外 → InProgress

### Step 6: Notion プロジェクト作成

切り出したマイルストーンごとに Notion プロジェクトを作成する。

**作成時のプロパティ:**

| プロパティ | 設定ルール |
|-----------|-----------|
| 名前 | `P:{マイルストーン名}` |
| ステータス | `InProgress` or `Done` |
| リポジトリURL | `https://github.com/{org}/{repo}` |
| 開始日 | 最初のセッションの日付 |
| 完了日 | Done の場合のみ、最後のセッション日付 |
| 詳細 | セッションログの概要を集約（2-3 文） |

**Notion MCP での作成例:**

```
mcp__claude_ai_Notion__notion-create-pages({
  parent: { data_source_id: "1b1f03e3-6bff-43b4-a8a5-924ffa2feeef" },
  pages: [{
    properties: {
      "名前": "P:sandpiper MCPサーバー構築＆Claude連携",
      "ステータス": "Done",
      "リポジトリURL": "https://github.com/koboriakira/sandpiper",
      "date:開始日:start": "2026-02-23",
      "date:開始日:is_datetime": 0,
      "date:完了日:start": "2026-02-24",
      "date:完了日:is_datetime": 0,
      "詳細": "SandpiperにMCPサーバーを追加し、Claude Desktop/Codeからタスク取得を可能にした。ツール名リネームや差し込みタスク追加も実施。"
    }
  }]
})
```

### Step 7: 実行記録の保存

1. 現在日時を `$STATE_FILE` に書き込む
2. 実行結果のサマリーをログ出力する（作成数、スキップ数、理由）

```bash
mkdir -p "$HOME/.claude/state"
date +%Y-%m-%d > "$HOME/.claude/state/project-sync-last-run.txt"
```

## 除外対象

- **dotfiles リポジトリ** — 横断的インフラのためプロジェクト化しない
- **ルーティン作業** — 詳細は [references/extraction-logic.md](references/extraction-logic.md) を参照

## 出力形式

実行完了後、以下のサマリーを出力する:

```
## project-sync 実行結果

- 対象期間: {前回実行日} 〜 {今日}
- スキャンしたセッション数: N
- 新規プロジェクト作成: N 件
  - P:xxx（リポジトリ名、ステータス）
  - ...
- スキップ: N 件
  - リポジトリ名: 理由（既存InProgressあり / ルーティン / テーマ不明確）
```
