# 【参考】
# https://qiita.com/reireias/items/d906ab086c3bc4c22147#%E7%99%BB%E5%A0%B4%E5%9B%9E%E6%95%B0%E3%81%AE%E5%A4%9A%E3%81%84%E9%A0%86

# 基本的なコマンド
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias dt="date +%Y%m%d"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias back="cd $OLDPWD"

if has "chrome-cli"; then
  alias chrome="chrome-cli"
fi

# global alias
alias -g H="| head"
alias -g T="| tail"
alias -g B="| bat"
alias -g G="| rg"
alias -g PB="| pbcopy"
alias -g F="| fzf"

# ripgrep(grep)
if has "rg"; then
  alias grep="rg" # Linuxのgrepは'ggrep'で行う
fi

# exa(ls, tree)
if has "exa"; then
  alias ls='exa'                                                         # ls
  alias l='exa -lbF --git'                                               # list, size, type, git
  alias ll='exa -lbGF --git'                                             # long list
  alias llm='exa -lbGd --git --sort=modified'                            # long list, modified date sort
  alias la='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
  alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list
  alias lS='exa -1'                                                      # one column, just names
  alias lt='exa -lbF --git -T --git-ignore --level=2'                                        # tree
fi

# bat
if has "bat"; then
  alias batenv='env | bat'
  alias batpath="echo $PATH | sed 's/:/\'$'\n/g' | bat"
fi

# Docker
if has "docker-compose"; then
  alias dcu='docker-compose up -d'
  alias dcd='docker-compose down'
  alias dcr='docker-compose restart'
  alias dcp='docker-compose ps'
  alias dcb='docker-compose build'
  alias dcx='docker-compose exec'
  alias dcl='docker-compose logs'
fi
if has "docker"; then
  alias dp='docker ps'
  alias dx='docker exec -it'
fi

# NeoVim(Vim)
if has "nvim"; then
  alias vi='nvim'
  alias vim='nvim'
fi

# yarn
if has "yarn"; then
  alias ya="yarn add"
  alias yad="yarn add -D"
  alias yd="yarn && yarn dev"
fi

# VSCode
if has "code"; then
  alias code='code'
  alias code.='code .'
fi

# VSCode Insider
if has "code-insiders"; then
  alias codei='code-insiders'
  alias codei.='code-insiders .'
fi

# tar
alias tar-compress="tar cvzf"
alias tar-decompress="tar xvzf"

# curl
alias getmyip="curl inet-ip.info"

# .zsh_functions
alias fdf=cd-fzf-find

# 溜まったスクリーンショットを削除
alias remove-screencapture='rm -f ${HOME}/Downloads/.screencapture/*'

# スクリーンショットを格納しているフォルダを開く
alias open-screencapture='open ${HOME}/Downloads/.screencapture'

# 現在実行されているプロセスを確認
alias psaux='psauxwww-fzf'

# 指定したプロセスを削除
alias pskill='ps-kill-fzf'

# Chrome, Google
alias doc.new='chrome open https://doc.new'
alias sheet.new='chrome open https://sheet.new'
alias meet.new='chrome open https://meet.new'

# Terraform
alias terraform='terraform_function' # 詳細は.zsh_functionsに記載
alias tfp='terraform_function fmt . && terraform_function plan -parallelism=30'
alias tfa='terraform_function fmt . && terraform_function apply -parallelism=30 --auto-approve'
alias tfm='terraform_function fmt'
alias tfi='terraform_function init'

# Python
alias python='python3.11'
alias pip='pip3.11'
