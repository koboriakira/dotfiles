# sandpiper

個人タスク管理CLIツール。TODO・プロジェクト・プロジェクトタスクをNotionと同期する。

## 基本方針

- ユーザーの意図を読み取り、適切なサブコマンドを選んで実行する
- 一覧取得 → 内容確認 → 更新 の順序で進める
- page_id が必要な操作では、まず `list` で候補を取得してから操作する
- 複数操作が必要な場合はまとめて実行してよい

## --async フラグ（重要）

すべてのコマンドに `--async` フラグが利用可能。**更新・作成系のコマンドでは原則として `--async` を付与すること**。

```bash
sandpiper todo start <id> --async
sandpiper todo complete <id> --async
sandpiper grocery want <name> --async
# など
```

- `--async` を付けるとリクエストを送信後すぐに制御が返り、処理完了を待たない
- 結果を確認する必要がない場合（ステータス更新・追加など）は必ず `--async` を使う
- **取得系（list / get）には使わない**（結果を受け取る必要があるため）

## コマンドリファレンス

### todo — TODOの取得・更新

```bash
# 一覧（デフォルト: status=TODO）
sandpiper todo list
sandpiper todo list --status IN_PROGRESS
sandpiper todo list --status DONE
sandpiper todo list --status ALL

# 個別取得
sandpiper todo get <page_id>

# ステータス変更（優先して使うこと）
sandpiper todo start <page_id>               # IN_PROGRESS に変更し開始時刻を記録（現在時刻）
sandpiper todo start <page_id> --start HH:MM  # 開始時刻を指定
sandpiper todo complete <page_id>            # DONE に変更し終了時刻を記録（現在時刻）
sandpiper todo complete <page_id> --end HH:MM  # 終了時刻を指定
# ※ complete はステータスが TODO の場合に --start HH:MM が必須
sandpiper todo complete <page_id> --start HH:MM --end HH:MM

# 削除
sandpiper todo delete <page_id>              # 論理削除（is_deleted=true に設定）

# 汎用更新（title や section の変更、フォールバック用）
sandpiper todo update <page_id> --status TODO|IN_PROGRESS|DONE
sandpiper todo update <page_id> --title "新しいタイトル"
sandpiper todo update <page_id> --section A_07_10|B_10_13|C_13_17|D_17_19|E_19_22|F_22_24|G_24_27
# ※ sectionは時間帯を表す (例: B_10_13 = 10:00〜13:00)
```

### project — プロジェクトの取得・更新

```bash
# 一覧
sandpiper project list
sandpiper project list --status TODO|IN_PROGRESS|DONE

# 個別取得
sandpiper project get <page_id>

# 更新
sandpiper project update <page_id> --status TODO|IN_PROGRESS|DONE
sandpiper project update <page_id> --name "新しい名前"
sandpiper project update <page_id> --end-date YYYY-MM-DD
```

### project-task — プロジェクトタスクの取得・更新

```bash
# 一覧
sandpiper project-task list
sandpiper project-task list --status TODO|IN_PROGRESS|DONE
sandpiper project-task list --project-id <project_page_id>

# 個別取得
sandpiper project-task get <page_id>

# 更新
sandpiper project-task update <page_id> --status TODO|IN_PROGRESS|DONE
sandpiper project-task update <page_id> --title "新しいタイトル"
```

### taste — 飲食記録の管理

```bash
# 一覧
sandpiper taste list

# 記録を追加
sandpiper taste add <飲食の名前>
sandpiper taste add <飲食の名前> --tag <タグ> --tag <タグ2>   # タグ（複数指定可）
sandpiper taste add <飲食の名前> --comment "一言コメント"
sandpiper taste add <飲食の名前> --place <NotionページID>      # 場所
sandpiper taste add <飲食の名前> --impression "感想"
sandpiper taste add <飲食の名前> --image /path/to/image.jpg   # 添付画像（複数指定可）
```

**使いどころ:**
- 「〇〇を食べた」「〇〇を飲んだ」→ `sandpiper taste add <名前>`
- コメントや感想があれば `--comment` / `--impression` で追記
- 写真があれば `--image` で添付（Notionページにアップロード）

### prepare-tomorrow-todos — 明日のTODOを一括作成

```bash
sandpiper prepare-tomorrow-todos
```

ルーチンタスク・プロジェクトタスク・サムデイリスト・カレンダーイベントから明日のTODOを自動生成する。
日本時間 18:00〜23:59 は「明日」、00:00〜17:59 は「今日」として扱う。

**使いどころ:**
- 「明日の予定をつくって」「明日のTODOを準備して」→ `sandpiper prepare-tomorrow-todos`

### grocery — 買い物リストの管理

```bash
# 買いたいアイテムを追加・チェックON（存在しない場合は新規作成）
sandpiper grocery want <アイテム名>
sandpiper grocery buy <アイテム名> [アイテム名2 ...]   # 購入済みに変更（複数指定可）
```

**使いどころ:**
- 「〇〇を買っておきたい」「〇〇が欲しい」→ `sandpiper grocery want <name>`
- 「〇〇を買った」「〇〇を購入した」→ `sandpiper grocery buy <name> [name2 ...]`
- 複数アイテムは `buy` なら1コマンドでまとめて指定可

## 使用例

**TODOを開始する:**
```bash
sandpiper todo list          # 一覧でpage_idを確認
sandpiper todo start <id>    # IN_PROGRESS に変更（開始時刻を自動記録）
```

**TODOを完了にする:**
```bash
sandpiper todo list --status IN_PROGRESS   # 一覧でpage_idを確認
sandpiper todo complete <id>               # DONE に変更（終了時刻を自動記録）
```

**プロジェクトのタスク一覧を確認:**
```bash
sandpiper project list --status IN_PROGRESS   # プロジェクトのidを確認
sandpiper project-task list --project-id <id>
```

**タスクを進行中に変更:**
```bash
sandpiper project-task update <id> --status IN_PROGRESS
```
