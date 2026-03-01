#!/bin/bash
# {{SCRIPT_NAME}}
# cron で定期実行するタスクスクリプト
#
# 実行内容:
#   1. 環境変数を読み込み（cron 環境対応）
#   2. メインタスクを実行
#   3. （オプション）結果を Slack に投稿
#
# cron 設定例:
#   {{CRON_SCHEDULE}} {{SCRIPT_PATH}}

set -euo pipefail

# ============================================================
# 1. PATH の拡張（cron 環境対応）
# ============================================================
# cron 環境では PATH が最小限（/usr/bin:/bin 程度）のため、
# 必要なコマンドのインストール先を追加する。
#
# 代表的なパス:
#   ~/.local/bin        — Claude Code CLI, pipx 等
#   /opt/homebrew/bin   — Homebrew (Apple Silicon)
#   /usr/local/bin      — Homebrew (Intel) / 手動インストール
#   $HOME/.nvm/versions/node/vXX/bin — nvm 経由の Node.js
#
# 不要なパスは削除してよい。
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

# ============================================================
# 2. 環境変数の読み込み（cron 環境対応）
# ============================================================
# cron はログインシェルを経由しないため、
# 対話シェルで設定済みの環境変数が存在しない。
#
# 以下は読み込み戦略のテンプレート。
# 実際に必要な変数名・ファイルパスに書き換えること。

# --- 戦略A: .env ファイルから読み込む（推奨） ---
# set -a で source した変数を自動 export する。
# export なしの KEY=VALUE 形式でも子プロセスに渡る。
#
# {{ENV_FILE_SECTION_START}}
PROJECT_DIR="{{PROJECT_DIR}}"
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  # shellcheck source=/dev/null
  source "$PROJECT_DIR/.env"
  set +a
fi
# {{ENV_FILE_SECTION_END}}

# --- 戦略B: zsh 設定ファイルから export 行のみ抽出 ---
# .zshrc を丸ごと source すると compinit 等でエラーになるため、
# grep で export 行のみ安全に抽出する。
#
# {{ZSH_ENV_SECTION_START}}
# 必要な変数名を指定（例: ANTHROPIC_API_KEY）
# ENV_VAR_NAME="ANTHROPIC_API_KEY"
# if [ -z "${!ENV_VAR_NAME:-}" ]; then
#   for ZSH_FILE in \
#     "$HOME/.dotfiles/.zsh/.zsh__temporary.zsh" \
#     "$HOME/.zshenv" \
#     "$HOME/.zshrc"; do
#     if [ -f "$ZSH_FILE" ]; then
#       eval "$(grep "^export ${ENV_VAR_NAME}=" "$ZSH_FILE" 2>/dev/null || true)"
#       [ -n "${!ENV_VAR_NAME:-}" ] && break
#     fi
#   done
# fi
# {{ZSH_ENV_SECTION_END}}

# ============================================================
# 3. プロジェクト固有の設定
# ============================================================

LOG_DIR="$PROJECT_DIR/{{LOG_DIR}}"
TODAY=$(date +%Y-%m-%d)
TODAY_COMPACT=$(date +%Y%m%d)
LOG="$LOG_DIR/{{LOG_PREFIX}}_${TODAY_COMPACT}.log"

mkdir -p "$LOG_DIR"
cd "$PROJECT_DIR"

# ============================================================
# 4. ユーティリティ関数
# ============================================================

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"
}

# --- Slack 通知（オプション。不要なら削除） ---
# {{SLACK_SECTION_START}}
SLACK_CHANNEL="{{SLACK_CHANNEL}}"
SLACK_API="https://slack.com/api/chat.postMessage"
MAX_SLACK_LENGTH=3500

slack_notify() {
  local msg="$1"
  if [ -z "${SLACK_BOT_TOKEN:-}" ]; then
    log "WARN: SLACK_BOT_TOKEN is not set, skipping notification"
    return
  fi
  curl -s -X POST "$SLACK_API" \
    -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg ch "$SLACK_CHANNEL" --arg txt "$msg" \
      '{channel: $ch, text: $txt}')" > /dev/null 2>&1
}
# {{SLACK_SECTION_END}}

# ============================================================
# 5. メインタスクの実行
# ============================================================

log "=== {{TASK_NAME}} start ==="

TASK_EXIT=0
{{MAIN_COMMAND}} >> "$LOG" 2>&1 || TASK_EXIT=$?

log "=== {{TASK_NAME}} end (exit=$TASK_EXIT) ==="

# ============================================================
# 6. 結果処理
# ============================================================

if [ $TASK_EXIT -ne 0 ]; then
  # {{SLACK_NOTIFY_START}}
  slack_notify ":warning: [cron] {{TASK_NAME}} ${TODAY}: FAILED (exit=$TASK_EXIT)"
  # {{SLACK_NOTIFY_END}}
  log "=== done (failed) ==="
  exit 1
fi

# --- レポートファイルの Slack 投稿（オプション。不要なら削除） ---
# {{REPORT_SECTION_START}}
# REPORT_PATH="{{REPORT_PATH_PATTERN}}"
# if [ ! -f "$REPORT_PATH" ]; then
#   REPORT_PATH=$(find "{{REPORT_DIR}}" -name "*${TODAY_COMPACT}*" -type f | head -1)
# fi
#
# if [ -z "${REPORT_PATH:-}" ] || [ ! -f "${REPORT_PATH:-}" ]; then
#   slack_notify ":warning: [cron] {{TASK_NAME}} ${TODAY}: OK but report file not found"
#   log "=== done (no report) ==="
#   exit 0
# fi
#
# REPORT_TEXT=$(cat "$REPORT_PATH")
# if [ ${#REPORT_TEXT} -gt $MAX_SLACK_LENGTH ]; then
#   REPORT_TEXT="${REPORT_TEXT:0:$MAX_SLACK_LENGTH}
# ...
# (truncated)"
# fi
#
# slack_notify "{{SLACK_REPORT_HEADER}}
#
# ${REPORT_TEXT}"
# {{REPORT_SECTION_END}}

log "=== done ==="
