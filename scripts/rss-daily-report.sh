#!/bin/bash
# RSS フィードを取得し、Claude Code で要約レポートを生成する（日次 cron 用）
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RSS_DIR="${HOME}/.claude/rss"
REPORT_DIR="${RSS_DIR}/reports"
TODAY=$(date '+%Y-%m-%d')
REPORT_FILE="${REPORT_DIR}/${TODAY}.md"
LOG_FILE="${RSS_DIR}/history.log"

mkdir -p "$REPORT_DIR"

# 1. フィード取得
echo "$(date '+%Y-%m-%d %H:%M:%S') [rss-daily-report] フィード取得開始"
bash "${SCRIPT_DIR}/fetch-rss.sh"

# 2. Claude Code で要約レポート生成
PROMPT="$(cat <<'PROMPT_EOF'
以下の手順で RSS フィードの要約レポートを生成してください。

1. ~/.claude/rss/ 配下の XML ファイルを読み込み、直近7日間の新着エントリを抽出する
2. 以下のカテゴリに分類して要約する:
   - 新機能・モデル更新（Anthropic News, Claude Blog）
   - Claude Code の変更（Claude Code Changelog, Claude Code Releases）
   - 技術・研究（Anthropic Engineering, Anthropic Research）
   - 障害・メンテナンス（Claude Status）
3. 各エントリは「- [タイトル](リンク) - 概要1〜2文」の形式
4. 該当なしのカテゴリは省略
5. 最後に「## 注目ポイント」として、CLAUDE.md やスキル、ワークフローに影響しうる変更を箇条書きで挙げる

レポート全文を標準出力に出力してください。マークダウン形式で、冒頭に「# RSS レポート（YYYY-MM-DD）」のヘッダーをつけてください。
PROMPT_EOF
)"

echo "$(date '+%Y-%m-%d %H:%M:%S') [rss-daily-report] レポート生成開始"
claude -p "$PROMPT" --output-format text --allowedTools 'Read,Glob,Grep,Bash(python3:*)' > "$REPORT_FILE" 2>/dev/null

# 3. 履歴ログに追記
ENTRY_COUNT=$(grep -c '^\- \[' "$REPORT_FILE" 2>/dev/null || echo "0")
echo "${TODAY}: 日次レポート生成 / 掲載${ENTRY_COUNT}件 / ${REPORT_FILE}" >> "$LOG_FILE"

echo "$(date '+%Y-%m-%d %H:%M:%S') [rss-daily-report] 完了: ${REPORT_FILE}"
