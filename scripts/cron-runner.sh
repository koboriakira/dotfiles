#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# cron-runner.sh — 汎用cronジョブランナー
#
# Usage:
#   cron-runner.sh [OPTIONS] -- <COMMAND> [ARGS...]
#
# Options:
#   -d, --dir <PATH>       作業ディレクトリ（デフォルト: カレントディレクトリ）
#   -e, --env <FILE>       .envファイルのパス（デフォルト: <dir>/.env）
#   --no-env               .env読み込みをスキップ
#   -n, --notify           成否をSlack通知
#   -c, --channel <ID>     Slack通知先チャンネル（デフォルト: $SLACK_CHANNEL or C04Q3AV4TA5）
#   -l, --log <FILE>       ログファイルのパス（デフォルト: /tmp/cron-runner-<name>.log）
#   --name <NAME>          ジョブ名（ログ・通知用）
#   -t, --timeout <SECS>   タイムアウト秒数（超過でSIGTERM→SIGKILL、exit 124）
# =============================================================================

# --- PATH拡張 ---
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

# --- デフォルト値 ---
WORK_DIR=""
ENV_FILE=""
NO_ENV=false
NOTIFY=false
CHANNEL="${SLACK_CHANNEL:-C04Q3AV4TA5}"
LOG_FILE=""
JOB_NAME=""
TIMEOUT=""

# --- usage ---
usage() {
  sed -n '/^# Usage:/,/^# =====/p' "$0" | grep -v '^# =====' | sed 's/^# //' | sed 's/^#//'
  exit 1
}

# --- 引数パース ---
COMMAND=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dir)
      WORK_DIR="$2"; shift 2 ;;
    -e|--env)
      ENV_FILE="$2"; shift 2 ;;
    --no-env)
      NO_ENV=true; shift ;;
    -n|--notify)
      NOTIFY=true; shift ;;
    -c|--channel)
      CHANNEL="$2"; shift 2 ;;
    -l|--log)
      LOG_FILE="$2"; shift 2 ;;
    --name)
      JOB_NAME="$2"; shift 2 ;;
    -t|--timeout)
      TIMEOUT="$2"; shift 2 ;;
    --)
      shift; COMMAND=("$@"); break ;;
    -h|--help)
      usage ;;
    *)
      echo "Error: unknown option '$1'" >&2
      usage ;;
  esac
done

# --- コマンド必須チェック ---
if [[ ${#COMMAND[@]} -eq 0 ]]; then
  echo "Error: no command specified. Use -- to separate options from command." >&2
  usage
fi

# --- ジョブ名の自動生成 ---
if [[ -z "$JOB_NAME" ]]; then
  JOB_NAME="$(basename "${COMMAND[0]}")"
fi

# --- ログファイルのデフォルト ---
if [[ -z "$LOG_FILE" ]]; then
  LOG_FILE="/tmp/cron-runner-${JOB_NAME}.log"
fi

# --- 作業ディレクトリ ---
if [[ -n "$WORK_DIR" ]]; then
  if [[ ! -d "$WORK_DIR" ]]; then
    echo "Error: directory '$WORK_DIR' does not exist." >&2
    exit 1
  fi
  cd "$WORK_DIR"
fi

# --- .env読み込み ---
if [[ "$NO_ENV" == false ]]; then
  env_path="${ENV_FILE:-${WORK_DIR:-.}/.env}"
  if [[ -f "$env_path" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$env_path"
    set +a
  fi
fi

# --- ANTHROPIC_API_KEY unset（常にunset。Max利用を前提）---
unset ANTHROPIC_API_KEY 2>/dev/null || true

# --- Slack通知関数 ---
slack_notify() {
  local message="$1"
  local token="${SLACK_BOT_TOKEN:-}"
  if [[ -z "$token" ]]; then
    echo "[cron-runner] SLACK_BOT_TOKEN is not set. Skipping notification." >&2
    return 0
  fi
  curl -sS --location 'https://slack.com/api/chat.postMessage' \
    --header "Authorization: Bearer $token" \
    --header 'Content-Type: application/json' \
    --data "{\"channel\": \"$CHANNEL\", \"text\": \"$message\"}" > /dev/null
}

# --- ログ関数 ---
log() {
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$ts] $*" | tee -a "$LOG_FILE"
}

# --- メイン実行 ---
log "=== cron-runner: $JOB_NAME ==="
log "Command: ${COMMAND[*]}"
log "Working directory: $(pwd)"

start_time=$(date +%s)
exit_code=0

# コマンド実行（stdout/stderrをログにも流す）
if [[ -n "$TIMEOUT" ]]; then
  "${COMMAND[@]}" >> "$LOG_FILE" 2>&1 &
  cmd_pid=$!
  ( sleep "$TIMEOUT" && kill -TERM "$cmd_pid" 2>/dev/null && sleep 5 && kill -KILL "$cmd_pid" 2>/dev/null ) &
  watchdog_pid=$!
  wait "$cmd_pid" 2>/dev/null || exit_code=$?
  # watchdog を停止（コマンドが先に終了した場合）
  kill "$watchdog_pid" 2>/dev/null
  wait "$watchdog_pid" 2>/dev/null || true
  # SIGTERM (143) で終了した場合はタイムアウトとみなす
  if [[ $exit_code -eq 143 ]]; then
    exit_code=124
    log "TIMEOUT: command killed after ${TIMEOUT}s"
  fi
else
  "${COMMAND[@]}" >> "$LOG_FILE" 2>&1 || exit_code=$?
fi

end_time=$(date +%s)
duration=$(( end_time - start_time ))

if [[ $exit_code -eq 0 ]]; then
  log "Result: SUCCESS (${duration}s)"
else
  log "Result: FAILED (exit code: $exit_code, ${duration}s)"
fi

# --- Slack通知 ---
if [[ "$NOTIFY" == true ]]; then
  if [[ $exit_code -eq 0 ]]; then
    slack_notify "[cron] $JOB_NAME: SUCCESS (${duration}s)"
  else
    slack_notify "[cron] $JOB_NAME: FAILED (exit code: $exit_code, ${duration}s)"
  fi
fi

exit "$exit_code"
