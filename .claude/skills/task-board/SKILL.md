---
name: task-board
description: Task management with Obsidian task board. Use when the user starts a new task, requests work, or asks to manage tasks. Triggers issue creation check and task board updates.
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

まずタスクボードを Read で読み込み、現在の状態を把握する。

### ステップ2：Issue化の検討

以下の3基準でユーザーに確認する。AskUserQuestion を使い、番号で回答できる形式にする。

| 基準 | 内容 |
|---|---|
| 外部共有・レビュー | チームメンバーへの共有やコードレビューが必要か |
| システム変更 | コードやインフラ等の変更を伴うか |
| トラッキング | 進捗をチームで追跡する必要があるか |

質問例:
```
このタスクについて:
1. Issue化する（チーム共有・コード変更・進捗追跡のいずれかに該当）
2. Issue化しない（セッション記録のみ）
```

いずれか1つでも該当する場合はIssue化を推奨する。推奨理由も簡潔に伝える。

### ステップ3：タスクボードへの追加

#### Issue化する場合

1. GitHub Issue を作成する（mcp__github__create_issue を使用）
2. タスクボードの `## 🚧 In Progress` セクションにリンク付きで追加する

```markdown
- [ ] [#番号](https://github.com/org/repo/issues/番号) タスク名
```

#### Issue化しない場合

タスクボードの `## 🚧 In Progress` セクションにセッションURLなしで追加する（セッションURL は作業完了時に付与）。

```markdown
- [ ] タスク名
```

### ステップ4：作業完了時

タスクが完了したら:

1. タスクボードのタスクにチェックを入れる（`- [ ]` → `- [x]`）
2. Issue化しなかったタスクにはセッションURLを付与する（`[session](https://claude.ai/chat/${CLAUDE_SESSION_ID})`）
3. `updated` フロントマターを更新する

```markdown
- [x] タスク名 [session](https://claude.ai/chat/xxxx)
```

## タスクの記法

### 優先度・期日（Tasks プラグイン対応）

必要に応じて以下の絵文字を付与する:

| 絵文字 | 意味 |
|---|---|
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
| ✅ Done | Tasks プラグインのクエリで自動表示 |

## 注意事項

- タスクボードファイルが存在しない場合はエラーを報告し、ユーザーに確認する
- 既存のタスクを上書き・削除しない。追記のみ行う
- フロントマターの `updated` は操作のたびに更新する
