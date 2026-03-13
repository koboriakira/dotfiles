# カレントディレクトリから指定したディレクトリに移動する
cd-fzf-find() {
  local DIR=$(find ./ -path '*/\.*' -name .git -prune -o -type d -print 2> /dev/null | fzf +m)
  if [ -n "$DIR" ]; then
      cd $DIR
  fi
}
zle -N cd-fzf-find

# プロセスを確認する
psauxwww-fzf() {
  ps auxwww | head -1 # ヘッダ
  ps auxwww | fzf +m # ボディ
}

# 指定したプロセスをKillする
ps-kill-fzf() {
  local PROCESS=$(ps auxwww | fzf +m)
  if [ -n "$PROCESS" ]; then
    echo $PROCESS | sed 's/  */ /g' | cut -d ' ' -f2 | xargs kill -9
  fi
}
zle -N ps-kill-fzf

# 選択した履歴をターミナルに出力する
select-fzf-history() {
  local BUFFER=$(history -n 1 | fzf +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-fzf-history

# 選択したファイルをVimで開く
__fzf-find-vi() {
  local SELECTED_FILE=$(rg --files --follow --no-ignore-vcs --hidden -g '!{node_modules/*,.git/*}'  | sed 's?^./??' | fzf +m --query "$LBUFFER")
  [[ -n $SELECTED_FILE ]] && vim $SELECTED_FILE
}
zle -N __fzf-find-vi

# 直近開いたVSCodeのフォルダURIを開くコマンドを生成
function __generate-latest-vscode-folder_uri() {
  local FOLDER_URI=$(cat ~/Library/Application\ Support/Code/storage.json | jq -r '.windowsState | .lastActiveWindow | .folder')
  echo "code --folder-uri=${FOLDER_URI}"
}

# Dockerの初期化
function init-docker() {
  if [ -n "$(docker ps -aq)" ]; then
    docker stop $(docker ps -aq) > /dev/null # コンテナを停止
    echo $(tput setaf 2)Stop containers. ✔︎$(tput sgr0)
    docker rm $(docker ps -aq) > /dev/null # コンテナを削除
    docker container prune --force > /dev/null
    echo $(tput setaf 2)Remove containers. ✔︎$(tput sgr0)
  fi
  docker network prune --force > /dev/null # ネットワークを削除
  echo $(tput setaf 2)Remove networks. ✔︎$(tput sgr0)
  if [ -n "$(docker images --filter dangling=true -qa)" ]; then
    docker rmi -f $(docker images --filter dangling=true -qa) > /dev/null # REPOSITORYやTAGが<none>になっているイメージを削除
    echo $(tput setaf 2)Remove images. ✔︎$(tput sgr0)
  fi
  if [ -n "$(docker volume ls --filter dangling=true -q)" ]; then
    docker volume rm $(docker volume ls --filter dangling=true -q) > /dev/null # REPOSITORYやTAGが<none>になっているボリュームを削除
    echo $(tput setaf 2)Remove volumes. ✔︎$(tput sgr0)
  fi
  if [ -n "$(docker images -qa)" ]; then
    docker rmi -f $(docker images -qa) > /dev/null # イメージを削除
    docker image prune --force > /dev/null
  fi
  if [ -n "$(docker volume ls -q)" ]; then
    docker volume prune --force > /dev/null # ボリュームを削除
  fi
  docker builder prune --force > /dev/null # イメージのビルド用キャッシュも削除
  echo $(tput setaf 2)Init docker: Complete. ✔︎$(tput sgr0)
}

function find-includes-string() {
  find . -type f -print | xargs grep $0
}

function empty-trash() {
  find ~/Downloads/* -exec rm -r {} \;
}

function terraform_function() {
  if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ] && [ -n "$AWS_DEFAULT_REGION" ]; then
    docker run --platform linux/amd64 -it --rm -v $PWD:/work -w /work -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -e "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" hashicorp/terraform:latest ${@:1}
  else
    echo "AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGIONのいずれかが未設定"
  fi
}

function new-blog() {
  #!/bin/bash
  local BLOG_DIR="${HOME}/git/blog/"

  # 今日の日付をYYYY/MM/DD形式で取得してパスを作成する
  # ただし翌日の午前2時までは前日の日付とする
  if [ `date +'%H'` -lt 2 ]; then
    local FILEPATH="content/`date -v-1d +'%Y/%m/%d'`.md"
  else
    local FILEPATH="content/`date +'%Y/%m/%d'`.md"
  fi

  local BLOG_ABS_PATH="${BLOG_DIR}${FILEPATH}"

  # ファイルを作成
  mkdir -p "$(dirname "${BLOG_ABS_PATH}")" && touch ${BLOG_ABS_PATH}

  # 日記データを取得してファイルに書きこむ
  # curl --silent -X GET "$LAMBDA_NOTION_API_DOMAIN"blog/template/ | jq -r '.message' >> ${BLOG_ABS_PATH}
  curl --silent -X GET http://localhost:10119/blog/template/ | jq -r '.message' >> ${BLOG_ABS_PATH}

  # VSCODEで開く
  code ${BLOG_DIR}
}

# ローカルの.envファイルを読み込む
function export-dotenv() {
  export $(cat .env| grep -v "#" | xargs)
}

# python/whisper.pyを実行する
function openai-whisper() {
  if [ $# -ne 1 ]; then
    echo "Usage: whisper <file_path>"
    return 1
  fi

  # 絶対パスの取得
  abs_path=$(readlink -f $1)

  # Pythonスクリプトの実行
  python3 ~/.dotfiles/python/whisper.py $abs_path
}

# squoosh-cli-in-dockerを利用して、画像最適化をする
function squoosh() {
  local shell_path=${HOME}/git/squoosh-cli/main.sh
  # shell_pathが存在するか確認
  if [ ! -e $shell_path ]; then
    echo "squoosh-cliリポジトリが見つかりません: $shell_path"
    return 1
  fi
  zsh $shell_path $@
}

# Slackチャンネルに投稿する
function slack-post() {
  if [ $# -ne 1 ]; then
    echo "Usage: slack-post <message>"
    return 1
  fi

  local authorization="Bearer $SLACK_BOT_TOKEN"
  local slack_webhook_url=https://slack.com/api/chat.postMessage
  local channel=C05F6AASERZ # diaryチャンネル
  local message=$1

  curl -sS --location 'https://slack.com/api/chat.postMessage' \
    --header "Authorization: $authorization" \
    --header 'Content-Type: application/json' \
    --data '{
        "channel": "'$channel'",
        "text": "'$message'"
    }' > /dev/null
}

# 通知チャンネルに投稿する
# Usage: slack-notify <message> [channel_id]
function slack-notify() {
  if [ $# -lt 1 ]; then
    echo "Usage: slack-notify <message> [channel_id]"
    return 1
  fi

  local authorization="Bearer $SLACK_BOT_TOKEN"
  local message=$1
  local channel=${2:-C04Q3AV4TA5} # デフォルト: 通知チャンネル

  curl -sS --location 'https://slack.com/api/chat.postMessage' \
    --header "Authorization: $authorization" \
    --header 'Content-Type: application/json' \
    --data '{
        "channel": "'$channel'",
        "text": "'$message'"
    }' > /dev/null
}

# ローカルの画像ファイルをSlackにアップロードする
# Usage: slack-upload-image <file_path> [channel_id] [comment]
# channel_idのデフォルト: diaryチャンネル (C05F6AASERZ)
function slack-upload-image() {
  if [ $# -lt 1 ]; then
    echo "Usage: slack-upload-image <file_path> [channel_id] [comment]"
    return 1
  fi

  local file_path=$1
  local channel=${2:-C05F6AASERZ}
  local comment=${3:-""}

  if [ ! -f "$file_path" ]; then
    echo "ファイルが見つかりません: $file_path"
    return 1
  fi

  local fname
  fname=$(basename "$file_path")
  local fsize
  fsize=$(wc -c < "$file_path" | tr -d ' ')

  # Step 1: アップロードURL取得
  local url_response
  url_response=$(curl -sS \
    -X POST \
    -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
    -d "filename=${fname}&length=${fsize}" \
    https://slack.com/api/files.getUploadURLExternal)

  local upload_url file_id
  upload_url=$(echo "$url_response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('upload_url',''))" 2>/dev/null)
  file_id=$(echo "$url_response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_id',''))" 2>/dev/null)

  if [ -z "$upload_url" ] || [ -z "$file_id" ]; then
    local error
    error=$(echo "$url_response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error','unknown'))" 2>/dev/null)
    echo "アップロードURL取得失敗: $error"
    return 1
  fi

  # Step 2: ファイルをアップロード
  local upload_status
  upload_status=$(curl -sS -o /dev/null -w "%{http_code}" \
    -F "file=@${file_path}" \
    "$upload_url")

  if [ "$upload_status" != "200" ]; then
    echo "ファイルアップロード失敗: HTTP $upload_status"
    return 1
  fi

  # Step 3: アップロード完了・チャンネルに投稿
  local complete_response
  complete_response=$(curl -sS \
    -X POST \
    -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"files\":[{\"id\":\"${file_id}\"}],\"channel_id\":\"${channel}\",\"initial_comment\":\"${comment}\"}" \
    https://slack.com/api/files.completeUploadExternal)

  local ok
  ok=$(echo "$complete_response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok','false'))" 2>/dev/null)

  if [ "$ok" = "True" ]; then
    echo "アップロード完了: $file_path"
  else
    local error
    error=$(echo "$complete_response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error','unknown'))" 2>/dev/null)
    echo "アップロード失敗: $error"
    return 1
  fi
}

# 指定したポートを使用しているプロセスを終了する
kill_port() {
    local port=$1

    if [ -z "$port" ]; then
        echo "Usage: kill_port <port_number>"
        return 1
    fi

    # ポートを使用しているプロセスIDを取得
    local pid=$(lsof -ti :$port)

    if [ -z "$pid" ]; then
        echo "ポート $port を使用しているプロセスは見つかりませんでした"
        return 0
    fi

    # プロセスを終了
    kill $pid

    if [ $? -eq 0 ]; then
        echo "ポート $port を使用していたプロセス (PID: $pid) を終了しました"
    else
        echo "プロセス (PID: $pid) の終了に失敗しました。強制終了を試みます..."
        kill -9 $pid
    fi
}

# SSH 接続時に TERM を xterm-256color に切り替える
# Ghostty はデフォルトで TERM=xterm-ghostty を設定するが、
# リモート側に xterm-ghostty の terminfo がないと Ctrl+L 等が動作しない。
# ローカルでは xterm-ghostty のまま Ghostty 固有機能を維持する。
ssh() {
  TERM=xterm-256color command ssh "$@"
}

# Ghostty で Claude Code + Terminal の左右2ペインレイアウトを展開する
tcode() {
  local dir="$PWD"
  local claude_cmd="claude"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dangerously-skip-permissions|--worktrees)
        claude_cmd="$claude_cmd $1"
        ;;
      *)
        echo "Unknown option: $1" >&2
        return 1
        ;;
    esac
    shift
  done

  osascript - "$dir" "$claude_cmd" <<'APPLESCRIPT'
    on run argv
      set targetDir to item 1 of argv
      set claudeCmd to item 2 of argv

      tell application "Ghostty" to activate
      delay 0.5

      tell application "System Events"
        tell process "Ghostty"
          -- 右に分割 (⌘+D) → 右ペインにフォーカスが移る
          keystroke "d" using {command down}
          delay 0.5

          -- 右ペインに Terminal (cd のみ)
          set the clipboard to "cd " & targetDir
          keystroke "v" using {command down}
          key code 36 -- Return
          delay 0.5

          -- 左ペインにフォーカス (Ctrl+H)
          keystroke "h" using {control down}
          delay 0.5

          -- 左ペインに Claude Code
          set the clipboard to "cd " & targetDir & " && " & claudeCmd
          keystroke "v" using {command down}
          key code 36 -- Return
        end tell
      end tell
    end run
APPLESCRIPT
}
