---
name: cron-setup
description: Set up cron jobs using the shared cron-runner.sh. Use when adding any scheduled task via cron. Determines options, constructs the crontab entry, and verifies execution — no per-job shell script needed.
disable-model-invocation: true
argument-hint: "[タスク概要]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# cron-setup

`~/.dotfiles/scripts/cron-runner.sh` を使って cron ジョブを設定する。

**個別のシェルスクリプトは作成しない。** cron-runner.sh が PATH 拡張・.env 読み込み・ログ・Slack 通知・エラーハンドリングをすべて共通処理する。

## cron-runner.sh のインターフェース

```
cron-runner.sh [OPTIONS] -- <COMMAND> [ARGS...]
```

| オプション | 説明 | デフォルト |
|-----------|------|----------|
| `-d, --dir <PATH>` | 作業ディレクトリ | カレントディレクトリ |
| `-e, --env <FILE>` | .env ファイルのパス | `<dir>/.env` |
| `--no-env` | .env 読み込みをスキップ | off |
| `-n, --notify` | 成否を Slack 通知 | off |
| `-c, --channel <ID>` | Slack 通知先チャンネル | `$SLACK_CHANNEL` or `C04Q3AV4TA5` |
| `-l, --log <FILE>` | ログファイルのパス | `/tmp/cron-runner-<name>.log` |
| `--name <NAME>` | ジョブ名（ログ・通知用） | コマンドから自動生成 |

**固定動作（オプションなし）:**
- PATH 拡張: `~/.local/bin`, `/opt/homebrew/bin`, `/usr/local/bin`
- `ANTHROPIC_API_KEY` は常に unset（Max 利用前提）

## 実行フロー

### 1. 要件の収集

`AskUserQuestion` で以下を確認する。

**必須:**
- 実行するコマンドまたはタスクの内容
- 実行スケジュール（cron 式、例: `0 7 * * *`）
- 作業ディレクトリ

**推奨:**
- Slack 通知の要否
- .env ファイルの有無と場所

### 2. 環境の事前検証

crontab エントリ構築前に以下を確認する:

```bash
# メインコマンドの存在確認
which <command>

# .env ファイルの存在確認（--no-env でない場合）
ls <dir>/.env

# cron 環境をシミュレートして動作確認
env -i HOME="$HOME" PATH="/usr/bin:/bin" bash ~/.dotfiles/scripts/cron-runner.sh -d <dir> -- <command>
```

### 3. crontab エントリの構築

要件に応じてオプションを組み立て、crontab エントリを生成する。

**例:**

```bash
# sandpiper コマンド（Slack 通知あり）
0 7 * * * ~/.dotfiles/scripts/cron-runner.sh -d ~/git/sandpiper -n -- uv run sandpiper sync-jira-to-project --notify

# Claude CLI（Max 利用）
0 8 * * * ~/.dotfiles/scripts/cron-runner.sh -d ~/git/cloud-sourcing -n -- claude -p "今日の調査を実行して" --max-turns 50

# 任意のシェルスクリプト（.env 不要）
30 6 * * * ~/.dotfiles/scripts/cron-runner.sh -d ~/git/blog --no-env -- bash scripts/daily-blog-auto-core.sh

# ジョブ名とログを明示指定
0 9 * * 1 ~/.dotfiles/scripts/cron-runner.sh -d ~/git/project --name weekly-report -l ~/logs/weekly.log -n -- python3 report.py
```

### 4. crontab の設定

```bash
# 現在の crontab を確認
crontab -l

# 追加（既存のエントリは維持）
(crontab -l 2>/dev/null; echo "CRON_SCHEDULE CRON_ENTRY") | crontab -
```

### 5. 動作確認の案内

以下の確認手順を提示する:

1. cron-runner.sh を手動で実行して正常動作を確認
2. cron 環境シミュレート: `env -i HOME="$HOME" PATH="/usr/bin:/bin" bash ~/.dotfiles/scripts/cron-runner.sh ...`
3. ログファイルの出力内容を確認
4. `--notify` 付きなら Slack 通知が届くことを確認
5. 翌日の cron 実行後にログを確認

## トラブルシューティング

詳細は [troubleshooting.md](troubleshooting.md) を参照。

## 注意事項

- シークレット（API キー、トークン等）はスクリプトにハードコードしない。.env から読み込む
- ログのローテーションは利用者に委ねる
