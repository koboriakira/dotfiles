---
name: cron-setup
description: Generate robust cron job shell scripts with proper environment handling. Use when setting up any scheduled task via cron, launchd, or similar schedulers. Covers PATH issues, environment variable loading, logging, error handling, and optional Slack notification.
disable-model-invocation: true
argument-hint: "[タスク概要]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# cron-setup

cron やスケジューラから任意のコマンドを定期実行するシェルスクリプトを生成する。

cron 環境特有の問題（PATH不足、環境変数の欠落、ログの消失）を事前に解消した堅牢なスクリプトを生成する。

## 背景: cron 環境の落とし穴

cron はログインシェル（zsh/bash）を経由しないため、対話シェルで動くコマンドが cron では失敗する。

| 問題 | 症状 | 原因 |
|------|------|------|
| コマンドが見つからない | exit=127 | PATH が `/usr/bin:/bin` のみ |
| 認証・トークンエラー | exit=1 等 | APIキー等の環境変数が未設定 |
| 通知が飛ばない | 静かに失敗 | トークン未設定 + エラー握りつぶし |
| ログが残らない | デバッグ不能 | stdout/stderr の出力先未指定 |
| Homebrew ツールが使えない | command not found | `/opt/homebrew/bin` が PATH にない |

詳細なトラブルシューティングは [troubleshooting.md](troubleshooting.md) を参照。

## 実行フロー

### 1. 要件の収集

`AskUserQuestion` で以下を確認する。

**必須:**
- 実行するコマンドまたはタスクの内容
- 実行スケジュール（cron式、例: `0 7 * * *`）
- 作業ディレクトリ（スクリプトの `cd` 先）

**推奨:**
- 必要な環境変数（APIキー、トークン等）とその格納先
- Slack 通知の要否（通知先チャンネルID）

**任意:**
- `.env` ファイルのパス
- 出力レポートのパスパターン（Slack投稿用）
- 追加の PATH（Homebrew、pip、npm 等のインストール先）

### 2. 環境の事前検証

スクリプト生成前に以下を確認する:

```bash
# メインコマンドの存在確認とパス特定
which <command>

# 必要な環境変数の設定場所を特定
# 優先順: 環境変数 → .env → zsh設定ファイル → .bashrc/.bash_profile
```

### 3. スクリプトの生成

[script-template.sh](script-template.sh) をベースに、ユーザーの要件に合わせたスクリプトを生成する。

生成先: ユーザーの指定場所、またはプロジェクト内 `scripts/` ディレクトリ

**テンプレートのカスタマイズ方針:**
- 不要なセクション（Slack通知、レポート投稿等）は削除する
- 実行コマンド部分はユーザーの要件に合わせて書き換える
- 環境変数の読み込みは実際に必要な変数のみに絞る

### 4. crontab の設定

生成後、crontab への登録コマンドを提示する:

```bash
# 現在の crontab を確認
crontab -l

# 追加（既存のエントリは維持）
(crontab -l 2>/dev/null; echo "CRON_SCHEDULE SCRIPT_PATH") | crontab -
```

### 5. 動作確認の案内

以下の確認手順を提示する:

1. スクリプトの手動実行で正常動作を確認
2. cron 環境をシミュレートして実行（`env -i HOME="$HOME" PATH="/usr/bin:/bin" bash script.sh`）
3. ログファイルの出力内容を確認
4. 翌日のcron実行後にログを確認

## 代表的なユースケース

### Claude Code CLI の定期実行

```bash
claude -p "タスクの指示内容" \
  --allowedTools "Task,Read,Grep,Glob,Bash,Write" \
  --output-format text \
  --max-turns 50 \
  >> "$LOG" 2>&1
```

Claude Code 固有の注意点:
- `ANTHROPIC_API_KEY` の読み込みが必須
- `~/.local/bin` を PATH に追加する必要がある
- `--max-turns` でターン数を制限し、暴走を防ぐ

### Python スクリプトの定期実行

```bash
/usr/local/bin/python3 "$PROJECT_DIR/scripts/task.py" >> "$LOG" 2>&1
```

Python 固有の注意点:
- `which python3` でフルパスを確認し、フルパスで呼び出す
- venv を使う場合は `source venv/bin/activate` を先に実行
- pip でインストールしたパッケージは PATH 依存のため注意

### Node.js / npm スクリプトの定期実行

```bash
/usr/local/bin/node "$PROJECT_DIR/scripts/task.js" >> "$LOG" 2>&1
```

### curl による API 呼び出し

```bash
curl -s -X POST "https://api.example.com/webhook" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}' >> "$LOG" 2>&1
```

## 注意事項

- シークレット（APIキー、トークン等）はスクリプトにハードコードしない
- 必ず外部ファイル（`.env` 等）から読み込む
- スクリプトには `set -euo pipefail` を含める
- ログのローテーションは利用者に委ねる（スキルでは設定しない）
- 実行権限（`chmod +x`）の付与を忘れないよう案内する
