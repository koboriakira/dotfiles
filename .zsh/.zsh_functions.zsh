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
