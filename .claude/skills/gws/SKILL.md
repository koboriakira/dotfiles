---
name: gws
description: >
  Gmail・Googleカレンダー・Googleドライブ・スプレッドシートなど Google Workspace サービスを操作するときは、
  MCP ツールよりも `gws` コマンド（ローカル CLI）を優先して使用する。
  「メールを調べて」「カレンダーを確認して」「スプレッドシートを読み込んで」「Googleドライブを検索して」
  など Google Workspace 系の作業を依頼されたら必ずこのスキルを参照すること。
---

# gws — Google Workspace CLI

`gws` はローカルにインストールされた Google Workspace CLI ツール。
MCP の Gmail/Calendar ツールより **このコマンドを優先して使うこと**。

## 基本構文

```bash
gws <service> <resource> [sub-resource] <method> [flags]
```

### 主なフラグ

| フラグ | 説明 |
|--------|------|
| `--params '<JSON>'` | クエリパラメータ（GET 系） |
| `--json '<JSON>'` | リクエストボディ（POST/PATCH/PUT 系） |
| `--format table` | テーブル形式で出力（デフォルトは json） |
| `--page-all` | 全ページを自動取得（NDJSON 形式） |
| `--page-limit N` | `--page-all` 時の最大ページ数（デフォルト 10） |

## よく使うコマンド例

### Gmail

```bash
# メール一覧（未読のみ）
gws gmail users messages list --params '{"userId": "me", "q": "is:unread", "maxResults": 20}'

# 特定ラベルのメール一覧
gws gmail users messages list --params '{"userId": "me", "labelIds": "INBOX", "maxResults": 50}'

# メール詳細取得
gws gmail users messages get --params '{"userId": "me", "id": "<messageId>", "format": "full"}'

# メールをアーカイブ（INBOXラベルを削除）
gws gmail users messages modify \
  --params '{"userId": "me", "id": "<messageId>"}' \
  --json '{"removeLabelIds": ["INBOX"]}'

# メールを削除（ゴミ箱へ）
gws gmail users messages trash --params '{"userId": "me", "id": "<messageId>"}'

# ラベル一覧
gws gmail users labels list --params '{"userId": "me"}'

# スレッド取得
gws gmail users threads get --params '{"userId": "me", "id": "<threadId>"}'
```

### Googleカレンダー

```bash
# カレンダー一覧
gws calendar calendarList list

# イベント一覧（今日以降）
gws calendar events list --params '{"calendarId": "primary", "timeMin": "2026-03-08T00:00:00Z", "maxResults": 20, "singleEvents": true, "orderBy": "startTime"}'

# イベント詳細
gws calendar events get --params '{"calendarId": "primary", "eventId": "<eventId>"}'

# イベント作成
gws calendar events insert \
  --params '{"calendarId": "primary"}' \
  --json '{
    "summary": "ミーティング",
    "start": {"dateTime": "2026-03-10T10:00:00+09:00"},
    "end":   {"dateTime": "2026-03-10T11:00:00+09:00"}
  }'

# イベント更新
gws calendar events patch \
  --params '{"calendarId": "primary", "eventId": "<eventId>"}' \
  --json '{"summary": "更新後のタイトル"}'

# イベント削除
gws calendar events delete --params '{"calendarId": "primary", "eventId": "<eventId>"}'
```

### Googleドライブ

```bash
# ファイル検索
gws drive files list --params '{"q": "name contains '\''report'\'' and trashed=false", "pageSize": 20}'

# ファイル取得
gws drive files get --params '{"fileId": "<fileId>", "fields": "id,name,mimeType,modifiedTime"}'
```

### スプレッドシート

```bash
# シート読み込み
gws sheets spreadsheets values get \
  --params '{"spreadsheetId": "<spreadsheetId>", "range": "Sheet1!A1:Z100"}'

# 値の書き込み
gws sheets spreadsheets values update \
  --params '{"spreadsheetId": "<spreadsheetId>", "range": "Sheet1!A1", "valueInputOption": "USER_ENTERED"}' \
  --json '{"values": [["名前", "値"], ["Alice", 100]]}'
```

## スキーマ確認

API パラメータが不明なときはスキーマを参照する。

```bash
gws schema gmail.users.messages.list
gws schema calendar.events.insert
gws schema drive.files.list
```

## 注意事項

- `--params` の JSON はシングルクォートで囲む（シェルのエスケープ対策）
- 日時は RFC3339 形式（例: `2026-03-08T00:00:00Z` または `2026-03-08T09:00:00+09:00`）
- ページネーションが必要な場合は `--page-all` を使うか `nextPageToken` を手動で追って次ページを取得する
- エラーが出た場合は `gws schema <service.resource.method>` でパラメータを確認する
