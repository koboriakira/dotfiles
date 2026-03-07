---
name: archive-mail
description: 未読メールを自動トリアージし、不要なメールをアーカイブする。ニュースレターや自動通知を判定して一括処理する。
disable-model-invocation: true
argument-hint: "[--max 50]"
allowed-tools: Bash, AskUserQuestion
---

# archive-mail

未読メールを取得し、内容を判定してアーカイブすべきものを自動処理する。

## 処理フロー

### 1. 未読メール一覧を取得

```bash
gws gmail +triage --max 50 --format json
```

`--max` の値はスキル引数で上書き可能（デフォルト: 50）。

### 2. 各メールの内容を取得

一覧から各メール ID に対して metadata と snippet を取得する。

```bash
gws gmail users messages get --params '{"userId": "me", "id": "<MESSAGE_ID>", "format": "metadata", "metadataHeaders": ["Subject", "From", "Date"]}'
```

snippet フィールドも含まれるので、Subject + From + snippet で判定に十分な情報が得られる。

### 3. アーカイブ判定

以下の基準で各メールを分類する。

**アーカイブする（INBOX から除去）:**
- ニュースレター、メルマガ（Substack, note, connpass, 技術系メディア等）
- プロモーション、マーケティングメール
- 自動通知（Dropbox, Amazon 注文確認, SNS 通知, GitHub Actions, CI/CD 通知等）
- サービスのアクティビティサマリー
- 配信停止リンクがある大量送信メール

**残す（アーカイブしない）:**
- 個人宛の直接メール（人間が書いたもの）
- 要返信・要対応のメール
- 請求・決済の重要通知（カード明細、銀行通知等）
- セキュリティアラート（ログイン通知、パスワード変更等）
- 判断に迷うもの

### 4. ユーザーに確認

アーカイブ対象リストを表形式で提示し、`AskUserQuestion` で承認を得る。

表示フォーマット:
```
## アーカイブ対象（N件）
| # | From | Subject | 理由 |
|---|------|---------|------|
| 1 | newsletter@example.com | 週刊ニュース | ニュースレター |
| 2 | ... | ... | ... |

## 残すメール（M件）
| # | From | Subject | 理由 |
|---|------|---------|------|
| 1 | tanaka@example.com | プロジェクトの件 | 個人メール |

アーカイブを実行しますか？（y/n、または除外したい番号を指定）
```

ユーザーが番号を指定した場合、その番号のメールをアーカイブ対象から除外する。

### 5. アーカイブ実行

承認後、各メールに対して以下を実行:

```bash
gws gmail users messages modify --params '{"userId": "me", "id": "<MESSAGE_ID>"}' --json '{"removeLabelIds": ["INBOX", "UNREAD"]}'
```

### 6. Slack 通知

アーカイブ実行後、以下の内容を `slack-notify` で通知する。

**通知対象:**
- 残したメール（全件）
- アーカイブしたメールのうち重要度が比較的高いもの（決済通知、サービス障害、期限付きの案内など）

**通知フォーマット:**
```
📬 メールトリアージ完了（アーカイブ: N件 / 残し: M件）

【要確認メール】
• [From] Subject — 残した理由
• [From] Subject — 残した理由

【アーカイブ済み（要注目）】
• [From] Subject — 注目理由
```

```bash
slack-notify "通知テキスト"
```

重要度の低いアーカイブメール（典型的なニュースレター・プロモーション等）は通知に含めない。

### 7. 結果報告

```
アーカイブ完了:
- アーカイブ: N件
- 残し: M件
- エラー: E件（あれば詳細表示）
- Slack通知: 送信済み
```

## 前提条件

- `gws` コマンドがインストール済みであること
- `gws auth login` で `gmail.modify` スコープを含む認証が完了していること

```bash
# 未認証の場合
gws auth login --scopes "https://www.googleapis.com/auth/gmail.modify"
```

## 注意事項

- 必ずユーザー確認を経てからアーカイブを実行する。自動実行はしない
- エラーが発生した場合、処理済み件数とエラー件数を報告して停止する
- 大量のメールがある場合は `--max` で分割処理する
