# コマンドの有無を判別
# if has "brew"; then
#   ...
# fi
has() {
  type "$1" > /dev/null 2>&1
}

# 端末依存
source ~/.zsh/.zsh__temporary.zsh

# 汎用
source ~/.zsh/.zsh_zinit.zsh
source ~/.zsh/.zsh_setting.zsh
source ~/.zsh/.zsh_git.zsh
source ~/.zsh/.zsh_alias.zsh
source ~/.zsh/.zsh_functions.zsh
source ~/.zsh/.zsh_keybind.zsh

# 初期化
eval "$(starship init zsh)"
