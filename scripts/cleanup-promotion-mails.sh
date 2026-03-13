#!/bin/bash
# cleanup-promotion-mails.sh
# 1年以上前のプロモーションラベルのみのメールを毎日500件ゴミ箱へ移動
#
# APIコスト: messages.list(5 units) + messages.batchModify(50 units) = 55 units/実行
# 処理速度: 500件/日 → 10万件を約200日（約6.5ヶ月）で完了

set -euo pipefail

BATCH_SIZE=500
ONE_YEAR_AGO=$(date -v-1y +"%Y/%m/%d")
QUERY="label:promotions before:${ONE_YEAR_AGO} -label:inbox -label:starred -label:important"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Starting cleanup: before=${ONE_YEAR_AGO}, batch_size=${BATCH_SIZE}"

# IDリストを取得（1回のAPIコール）
RESPONSE=$(gws gmail users messages list \
  --params "{\"userId\": \"me\", \"q\": \"${QUERY}\", \"maxResults\": ${BATCH_SIZE}}" 2>/dev/null)

IDS_JSON=$(echo "$RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
messages = data.get('messages', [])
if not messages:
    print('[]')
else:
    print(json.dumps([m['id'] for m in messages]))
")

COUNT=$(echo "$IDS_JSON" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")

if [ "$COUNT" -eq 0 ]; then
  log "No messages to process. All done."
  exit 0
fi

log "Found ${COUNT} messages. Moving to trash..."

# batchModifyでTRASHラベルを一括付与（1回のAPIコール）
gws gmail users messages batchModify \
  --params '{"userId": "me"}' \
  --json "{\"ids\": ${IDS_JSON}, \"addLabelIds\": [\"TRASH\"]}"

log "Done: moved ${COUNT} messages to trash"
