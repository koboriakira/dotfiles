---
name: task-board
description: Task management with Obsidian task board. Use for every task — record all work on the task board regardless of size. Optionally link to GitHub Issues when criteria are met.
argument-hint: "[タスク名（省略可）]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, mcp__github__create_issue, mcp__github__get_issue, mcp__github__list_issues, mcp__github__search_issues
---

# タスクボード管理

Obsidian ベースのタスクボードを管理し、GitHub Issues との連携を行う。

## ファイルパス

```
$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-vault/Claude/task-board.md
```

## 作業開始フロー

### ステップ1：タスクボードの現状確認

まずタスクボードを Read で読み込み、現在の状態を把握する。`whoami` で自身の端末ユーザー名を取得し、タスクの検索や次に実行すべきタスクの検討時には、原則として自身の端末（🖥 が一致するタスク）を優先的に絞り込む。他端末のタスクも表示はするが、着手対象の判断は自端末のタスクを基本とする。

### ステップ2：タスクボードへの追加

すべての作業をタスクボードに記録する。Issue の有無にかかわらず、作業を開始したら `## 🚧 In Progress` セクションに追加する。作成日を ➕ で、端末ユーザー名を 🖥 で記録する。端末ユーザー名は `whoami` コマンドで取得する。

```markdown
- [ ] タスク名 🖥 ユーザー名 ➕ YYYY-MM-DD
```

### ステップ3：Issue化の検討（該当する場合のみ）

以下の3基準のいずれかに該当する場合、Issue化するかユーザーに確認する。該当しない場合はこのステップをスキップする。

| 基準 | 内容 |
|---|---|
| 外部共有・レビュー | チームメンバーへの共有やコードレビューが必要か |
| システム変更 | コードやインフラ等の変更を伴うか |
| トラッキング | 進捗をチームで追跡する必要があるか |

Issue化する場合:

1. GitHub Issue を作成する（mcp__github__create_issue を使用）
2. タスクボードのタスクにリンクを追加する

```markdown
- [ ] [#番号](https://github.com/org/repo/issues/番号) タスク名
```

### ステップ4：作業完了時

タスクが完了したら:

1. タスクにチェックを入れ、完了日を ✅ で記録する
2. Claude Code で作業した場合、Issue化しなかったタスクにはセッションURLを付与する（`[session](https://claude.ai/chat/${CLAUDE_SESSION_ID})`）。他ツール（GitHub Copilot Agent 等）で作業した場合はセッションURLなしでよい
3. タスクを `## 🚧 In Progress` から `## ✅ Done` セクション内のアーカイブ領域（クエリブロックの下）に移動する
4. `updated` フロントマターを更新する

```markdown
- [x] タスク名 [session](https://claude.ai/chat/xxxx) 🖥 ユーザー名 ➕ 2026-02-27 ✅ 2026-02-27
```

## タスクの記法

### 外部チケットリンク

GitHub Issue 以外のチケット管理サービス（Jira、Linear、Asana、Backlog 等）のURLがある場合、🔗 でタスクに記録する。リンクテキストはチケットIDや短い識別名にする。

```markdown
- [ ] タスク名 🔗 [PROJ-123](https://example.atlassian.net/browse/PROJ-123)
```

GitHub Issue リンクと併用も可能:

```markdown
- [ ] [#番号](https://github.com/org/repo/issues/番号) タスク名 🔗 [PROJ-123](https://example.atlassian.net/browse/PROJ-123)
```

### 端末識別

タスクには作業を行った端末のユーザー名を 🖥 で記録する。`whoami` コマンドの出力をそのまま使用する。

### 優先度・期日（Tasks プラグイン対応）

必要に応じて以下の絵文字を付与する:

| 絵文字 | 意味 |
|---|---|
| 🔗 | 外部チケットURL（🔗 [PROJ-123](URL)） |
| 🖥 | 端末ユーザー名（🖥 koboriakira など。`whoami` で取得） |
| 📅 | 期日（📅 YYYY-MM-DD） |
| ⏫ | 優先度：最高 |
| 🔼 | 優先度：高 |
| 🔽 | 優先度：低 |

### セクションの使い分け

| セクション | 用途 |
|---|---|
| 🚧 In Progress | 現在作業中のタスク |
| 📋 Todo | 未着手のタスク |
| 🚫 Blocked | ブロックされているタスク |
| ✅ Done | 完了タスクのアーカイブ。クエリブロック＋その下にアーカイブ行 |

## 注意事項

- タスクボードファイルが存在しない場合はエラーを報告し、ユーザーに確認する
- 既存のタスクを上書き・削除しない。追記のみ行う
- フロントマターの `updated` は操作のたびに更新する
