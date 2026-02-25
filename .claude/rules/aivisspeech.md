# 音声読み上げ（AivisSpeech Engine）

AivisSpeech Engine（`http://127.0.0.1:10101`）は常にローカルで起動している前提とする。

## 読み上げテキストの作成ルール

- 自然な話し言葉の文章にする（箇条書きではない）
- 技術用語は最小限にし、必要な場合は簡潔に説明を添える
- 150〜300文字程度に収める
- ファイルパスやコマンド名は含めず「設定ファイル」「コマンド」など抽象的な表現に置き換える
- 記号（`/`、`-`、`_`、`.` など）はテキストに含めない
- 英単語や漢字はそのまま記述してよい（AivisSpeech が自然に読み上げる）

## API 呼び出し手順

```bash
ENCODED_TEXT=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$TEXT")

QUERY=$(curl -s -X POST \
  "http://127.0.0.1:10101/audio_query?text=${ENCODED_TEXT}&speaker=888753760" \
  -H 'accept: application/json' -d '')

echo "$QUERY" | curl -s -X POST \
  "http://127.0.0.1:10101/synthesis?speaker=888753760" \
  -H 'accept: audio/wav' \
  -H 'Content-Type: application/json' \
  -o /tmp/aivisspeech_output.wav \
  -d @-
afplay /tmp/aivisspeech_output.wav
```

> speaker=888753760 はデフォルトの話者ID。変更が必要な場合は `/speakers` エンドポイントで確認できる。
