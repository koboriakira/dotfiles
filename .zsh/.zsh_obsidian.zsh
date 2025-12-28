# OBSIDIAN_MY_VAULD_DIR が設定されていることが前提

# Obsidianのデイリーノートのパスを取得する
function get-daily-note-path() {
  local today=$(date +%Y-%m-%d)
  echo "$OBSIDIAN_MY_VAULD_DIR/dailynote/$today.md"
}

# Obsidianのデイリーノートの末尾にTODO形式の行を追加する
function dailynote-add-todo() {
  local daily_note_path=$(get-daily-note-path)
  if [ ! -f "$daily_note_path" ]; then
    echo "Daily note not found: $daily_note_path"
    return 1
  fi
  local todo_item="$1"
  if [ -z "$todo_item" ]; then
    echo "Usage: dailynote-add-todo <todo_item>"
    return 1
  fi

  # 最終行がTODO形式である場合、勝手にTODO形式になるのでテキストのみ追加する
  if grep -qE '^\s*-\s+\[ \]\s+' "$daily_note_path"; then
    echo "$todo_item" >> "$daily_note_path"
  else
    # 最終行がTODO形式でない場合、TODO形式で追加する
    todo_item="- [ ] $todo_item"
    echo "$todo_item #task" >> "$daily_note_path"
  fi
}

function obsd-task() {
    # 引数チェック
    if [ $# -eq 0 ]; then
        echo "使用方法: obsd-task <タスク名>"
        return 1
    fi

    local task_name="$1"
    local md_file="${OBSIDIAN_MY_VAULD_DIR}/00_inbox/task_${task_name}.md"

    # マークダウンファイルを作成
    touch "$md_file"
    echo "# Task: ${task_name}" > "$md_file"

    # screenocr split コマンドを実行
    OLDPWD=$(pwd)
    cd ${HOME}/git/screen-times
    local output=$(screenocr split "$task_name" 2>&1)
    cd $OLDPWD

    # 実行結果から .jsonl ファイルパスを抽出
    local jsonl_path=$(echo "$output" | grep -o '/Users/[^[:space:]]*\.jsonl' | head -n 1)

    if [ -n "$jsonl_path" ]; then
        echo "" >> "$md_file"
        echo "## ログファイル" >> "$md_file"
        echo "" >> "$md_file"
        echo "$jsonl_path" >> "$md_file"
        echo "" >> "$md_file"
        echo "タスクファイルを作成しました: $md_file"
        echo "ログファイル: $jsonl_path"
    else
        echo "警告: .jsonl ファイルパスを抽出できませんでした"
        echo "screenocr の出力:"
        echo "$output"
    fi

    # デイリーノートにリンクを追加
    local daily_note_path=$(get-daily-note-path)
    if [ -f "$daily_note_path" ]; then
        echo "- [[task_${task_name}]]" >> "$daily_note_path"
        echo "デイリーノートにリンクを追加しました: $daily_note_path"
    else
        echo "警告: デイリーノートが見つかりません: $daily_note_path"
    fi
}
