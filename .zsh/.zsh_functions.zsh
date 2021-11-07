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
