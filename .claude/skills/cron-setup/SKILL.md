---
name: cron-setup
description: Set up scheduled jobs using cron or launchd. Use when adding any scheduled task. Determines the right scheduler (cron vs launchd), constructs the entry, and verifies execution.
disable-model-invocation: true
argument-hint: "[タスク概要]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# cron-setup

スケジュールジョブを cron または launchd（LaunchAgents）で設定する。

**個別のシェルスクリプトは作成しない。** cron-runner.sh が PATH 拡張・.env 読み込み・ログ・Slack 通知・エラーハンドリングをすべて共通処理する。どちらのスケジューラでも cron-runner.sh を経由して実行する。

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

### 1. cron vs launchd の判断

以下の基準でスケジューラを決定する。

**launchd（LaunchAgents）を使う場合:**
- `claude` CLI を使うジョブ（macOS Keychain 認証が必要）
- macOS GUI セッション依存の処理（Keychain、Security フレームワーク等）

**cron のままでよい場合:**
- `claude` CLI を使わないシンプルなスクリプト
- 外部リポジトリの独自スクリプト
- Keychain アクセスが不要な処理

> **背景:** cron 環境では macOS Keychain にアクセスできず、`claude -p` が「Not logged in」で失敗する。launchd の LaunchAgents はユーザーセッション内で動くため Keychain にアクセス可能。

### 2. 要件の収集

`AskUserQuestion` で以下を確認する。

**必須:**
- 実行するコマンドまたはタスクの内容
- 実行スケジュール（cron 式 `0 7 * * *` または時刻 `07:00`）
- 作業ディレクトリ

**推奨:**
- Slack 通知の要否
- .env ファイルの有無と場所

### 3. 環境の事前検証

crontab エントリ構築前に以下を確認する:

```bash
# メインコマンドの存在確認
which <command>

# .env ファイルの存在確認（--no-env でない場合）
ls <dir>/.env

# cron 環境をシミュレートして動作確認
env -i HOME="$HOME" PATH="/usr/bin:/bin" bash ~/.dotfiles/scripts/cron-runner.sh -d <dir> -- <command>
```

### 4a. cron の場合: crontab エントリの構築

要件に応じてオプションを組み立て、crontab エントリを生成する。

**例:**

```bash
# sandpiper コマンド（Slack 通知あり）
0 7 * * * ~/.dotfiles/scripts/cron-runner.sh -d ~/git/sandpiper -n -- uv run sandpiper sync-jira-to-project --notify

# 任意のシェルスクリプト（.env 不要）
30 6 * * * ~/.dotfiles/scripts/cron-runner.sh -d ~/git/blog --no-env -- bash scripts/daily-blog-auto-core.sh

# ジョブ名とログを明示指定
0 9 * * 1 ~/.dotfiles/scripts/cron-runner.sh -d ~/git/project --name weekly-report -l ~/logs/weekly.log -n -- python3 report.py
```

```bash
# 現在の crontab を確認
crontab -l

# 追加（既存のエントリは維持）
(crontab -l 2>/dev/null; echo "CRON_SCHEDULE CRON_ENTRY") | crontab -
```

### 4b. launchd の場合: plist の作成

plist を `~/Library/LaunchAgents/` に作成する。命名規則: `com.koboriakira.<project>.<job-name>.plist`

**テンプレート:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.koboriakira.PROJECT.JOB_NAME</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/koboriakira/.dotfiles/scripts/cron-runner.sh</string>
        <string>-d</string>
        <string>/Users/koboriakira/path/to/dir</string>
        <string>-n</string>
        <string>--name</string>
        <string>JOB_NAME</string>
        <string>--</string>
        <string>claude</string>
        <string>-p</string>
        <string>/skill-name</string>
        <string>--max-turns</string>
        <string>50</string>
    </array>

    <!-- スケジュール: 1つの時刻なら dict、複数なら array of dict -->
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>8</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>

    <key>StandardOutPath</key>
    <string>/Users/koboriakira/Library/Logs/JOB_NAME.log</string>

    <key>StandardErrorPath</key>
    <string>/Users/koboriakira/Library/Logs/JOB_NAME.error.log</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/Users/koboriakira/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key>
        <string>/Users/koboriakira</string>
    </dict>

    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
```

**有効化・無効化:**

```bash
# 有効化
launchctl load ~/Library/LaunchAgents/com.koboriakira.PROJECT.JOB_NAME.plist

# 無効化
launchctl unload ~/Library/LaunchAgents/com.koboriakira.PROJECT.JOB_NAME.plist

# 登録確認
launchctl list | grep koboriakira
```

**注意:**
- ProgramArguments ではシェル展開（`$()`, `~`）が使えない。フルパスを記述する
- シェル展開が必要な場合は `/bin/bash -c "..."` を使う
- 複数スケジュールは `StartCalendarInterval` を array of dict にする

### 5. 動作確認の案内

以下の確認手順を提示する:

1. cron-runner.sh を手動で実行して正常動作を確認
2. **cron の場合:** cron 環境シミュレート: `env -i HOME="$HOME" PATH="/usr/bin:/bin" bash ~/.dotfiles/scripts/cron-runner.sh ...`
3. **launchd の場合:** `launchctl list | grep <job-name>` で登録確認
4. ログファイルの出力内容を確認
5. `--notify` 付きなら Slack 通知が届くことを確認
6. 翌日のログで自動実行を確認

## トラブルシューティング

詳細は [troubleshooting.md](troubleshooting.md) を参照。

## 注意事項

- シークレット（API キー、トークン等）はスクリプトにハードコードしない。.env から読み込む
- ログのローテーションは利用者に委ねる
