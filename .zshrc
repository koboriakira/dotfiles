# コマンドの有無を判別
# if has "brew"; then
#   ...
# fi
has() {
  type "$1" > /dev/null 2>&1
}

# 端末依存
source $HOME/.zsh/.zsh__temporary.zsh

# 汎用
source $HOME/.zsh/.zsh_zinit.zsh
source $HOME/.zsh/.zsh_setting.zsh
source $HOME/.zsh/.zsh_git.zsh
source $HOME/.zsh/.zsh_alias.zsh
source $HOME/.zsh/.zsh_functions.zsh
source $HOME/.zsh/.zsh_keybind.zsh

# 初期化
eval "$(starship init zsh)"

# zprofでプロファイリングをしたいときはコメントアウトを外す
# if (which zprof > /dev/null 2>&1) ;then
#   zprof | less
# fi
