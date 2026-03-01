# トラブルシューティング

cron で定期タスクを実行する際に遭遇する典型的な問題と解決策。

## 問題一覧

### 1. コマンドが見つからない (exit=127)

**原因:** cron の PATH は `/usr/bin:/bin` 程度しか含まれない。ユーザーが追加インストールしたコマンドは見つからない。

**よくあるパス:**

| コマンド | 典型的なインストール先 |
|----------|----------------------|
| Homebrew ツール (jq, gh 等) | `/opt/homebrew/bin`（Apple Silicon）/ `/usr/local/bin`（Intel） |
| Claude Code CLI | `~/.local/bin` |
| pipx / pip ツール | `~/.local/bin` |
| nvm 経由の Node.js | `~/.nvm/versions/node/vXX.X.X/bin` |
| rbenv 経由の Ruby | `~/.rbenv/shims` |

**解決策:**
```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
```

**確認方法:**
```bash
which <command>
```

### 2. 環境変数が設定されていない

**原因:** cron はログインシェルを経由しないため、`.zshrc` や `.bash_profile` で設定した環境変数が存在しない。

**解決策（3つの戦略）:**

```bash
# 戦略A: .env ファイルから読み込む（推奨）
set -a; source "$PROJECT_DIR/.env"; set +a

# 戦略B: zsh 設定ファイルから export 行のみ抽出（安全）
eval "$(grep '^export TARGET_VAR=' "$HOME/.zshrc")"

# 戦略C: dotfiles の一時ファイルから読み込む
eval "$(grep '^export ' "$HOME/.dotfiles/.zsh/.zsh__temporary.zsh")"
```

**注意:** シークレットをスクリプトにハードコードしない。

### 3. zsh 設定ファイルを丸ごと source してエラーになる

**原因:** `.zshrc` は対話シェル用の設定（`compinit`、`alias` 等）を含むため、非対話環境で source するとエラーになる。

**解決策:** `grep '^export '` で export 行のみを安全に抽出する。

```bash
# 安全: export 行のみ読み込み
eval "$(grep '^export ' "$HOME/.zshrc")"

# 危険: 丸ごと source
source "$HOME/.zshrc"  # 避ける
```

### 4. `.env` の変数が子プロセスに渡らない

**原因:** `source .env` だけでは `export` されず、子プロセスに渡らない。

**解決策:**
```bash
set -a          # 以降の変数定義を自動で export
source .env
set +a          # 自動 export を解除
```

### 5. ログが残らない / 出力が消える

**原因:** cron はデフォルトで stdout/stderr をメールに送信するか破棄する。

**解決策:**
```bash
# stdout と stderr を両方ログに追記
command >> "$LOG" 2>&1
```

### 6. Slack 通知が静かに失敗する

**原因:** トークン未設定のまま curl を実行し、エラーを `/dev/null` に捨てている。

**解決策:** トークン未設定時は明示的にスキップしてログに記録する。

```bash
slack_notify() {
  local msg="$1"
  if [ -z "${SLACK_BOT_TOKEN:-}" ]; then
    log "WARN: SLACK_BOT_TOKEN is not set, skipping notification"
    return
  fi
  # curl ...
}
```

## デバッグ手順

### 手動で cron 環境を再現する

```bash
# cron と同じ最小環境で実行（ログインシェルの設定を読み込まない）
env -i HOME="$HOME" PATH="/usr/bin:/bin" bash /path/to/script.sh
```

### cron のログを確認する

```bash
# macOS
log show --predicate 'process == "cron"' --last 1h

# Linux
grep CRON /var/log/syslog
```

### 環境変数の確認（デバッグ用）

スクリプトの先頭付近で環境変数をダンプする（本番では削除）:

```bash
log "DEBUG: PATH=$PATH"
log "DEBUG: MY_API_KEY=${MY_API_KEY:+SET}"  # 値は隠し、設定有無だけ表示
```

## macOS 固有の注意点

### launchd との違い

macOS では cron の代わりに launchd を使うこともできる:

| 項目 | cron | launchd |
|------|------|---------|
| 設定場所 | `crontab -e` | `~/Library/LaunchAgents/*.plist` |
| 環境変数 | 最小限 | `EnvironmentVariables` で指定可能 |
| ログ | 手動で設定 | `StandardOutPath`/`StandardErrorPath` |
| スリープ復帰 | 実行されない | `StartCalendarInterval` で復帰後に実行 |

### Full Disk Access

macOS のセキュリティ設定により、cron から特定のディレクトリにアクセスできない場合がある。

**解決策:** システム環境設定 → プライバシーとセキュリティ → フルディスクアクセス に `/usr/sbin/cron` を追加する。
