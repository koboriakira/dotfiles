#!/bin/bash
# あらかじめmain.shのパーミッションが755かを確認する
if [ ! -x "${HOME}/git/squoosh-cli/main.sh" ]; then
  echo "main.shのパーミッションが755ではありません"
  return 1
fi

WATCHED_DIR="$HOME/Downloads/.screencapture"
echo "スクリーンショットを監視中..."
fswatch -0 -e ".*" -i "\\.png$" --event Created "$WATCHED_DIR" | while read -d "" event
do
  file=$(basename "$event")

  # ファイル名を変更する
  # - 先頭にドットが含まれる場合はそれを取り除く
  # - ファイル名に半角スペースが混じっているので、ファイル名をアンダースコアに変換する
  file=$(echo $file | sed -e 's/^\.//')
  newfile=$(echo $file | sed -e 's/ /_/g')
  mv "$WATCHED_DIR/$file" "$WATCHED_DIR/$newfile"

  ${HOME}/git/squoosh-cli/main.sh $WATCHED_DIR`/$newfile --force > /dev/null 2>&1
done
