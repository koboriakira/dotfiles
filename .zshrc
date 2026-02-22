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
source $HOME/.zsh/.zsh_python.zsh
source $HOME/.zsh/.zsh_chatgpt.zsh
source $HOME/.zsh/.zsh_obsidian.zsh

# 初期化
eval "$(starship init zsh)"

# zprofでプロファイリングをしたいときはコメントアウトを外す
# if (which zprof > /dev/null 2>&1) ;then
#   zprof | less
# fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/a_kobori/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/a_kobori/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/a_kobori/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/a_kobori/google-cloud-sdk/completion.zsh.inc'; fi
