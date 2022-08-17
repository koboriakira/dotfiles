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
    echo $(tput setaf 2)Remove containers. ✔︎$(tput sgr0)
  fi
  docker network prune -f > /dev/null # ネットワークを削除
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
  fi
  echo $(tput setaf 2)Init docker: Complete. ✔︎$(tput sgr0)
}

function find-includes-string() {
  find . -type f -print | xargs grep $0
}

function empty-trash() {
  find ~/Downloads/* -exec rm -r {} \;
}

