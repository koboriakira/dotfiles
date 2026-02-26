#!/bin/bash
# Claude / Anthropic 関連 RSS フィードを取得してローカルに保存する
set -eo pipefail

RSS_DIR="${HOME}/.claude/rss"
mkdir -p "$RSS_DIR"

FEEDS=(
  "anthropic_news|https://raw.githubusercontent.com/Olshansk/rss-feeds/main/feeds/feed_anthropic_news.xml"
  "anthropic_engineering|https://raw.githubusercontent.com/Olshansk/rss-feeds/main/feeds/feed_anthropic_engineering.xml"
  "anthropic_research|https://raw.githubusercontent.com/Olshansk/rss-feeds/main/feeds/feed_anthropic_research.xml"
  "claude_code_changelog|https://raw.githubusercontent.com/Olshansk/rss-feeds/main/feeds/feed_anthropic_changelog_claude_code.xml"
  "claude_blog|https://raw.githubusercontent.com/Olshansk/rss-feeds/main/feeds/feed_claude.xml"
  "claude_code_releases|https://github.com/anthropics/claude-code/releases.atom"
  "claude_status|https://status.claude.com/history.rss"
)

echo "$(date '+%Y-%m-%d %H:%M:%S') RSS フィード取得開始"

FAILED=0
TOTAL=${#FEEDS[@]}
for entry in "${FEEDS[@]}"; do
  name="${entry%%|*}"
  url="${entry#*|}"
  output="${RSS_DIR}/${name}.xml"
  if curl -sf --max-time 30 -o "$output" "$url"; then
    echo "  OK: ${name}"
  else
    echo "  FAIL: ${name} (${url})"
    FAILED=$((FAILED + 1))
  fi
done

echo "$(date '+%Y-%m-%d %H:%M:%S') 完了 (失敗: ${FAILED}/${TOTAL})"
echo "保存先: ${RSS_DIR}"
