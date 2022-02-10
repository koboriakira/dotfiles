autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }
GIT_PROMPT='${vcs_info_msg_0_}'

# GitHub CLIのコマンド補完を設定

eval "$(gh completion -s zsh)"

# alias
alias ga='git add'
alias gb='git branch'
alias gs='git status'
alias gco='git checkout'
alias gcm='git commit'
alias gps='git push'
alias gpl='git pull'
alias gl='git log3'
alias gl-short='git log1'
alias gg='git graph'
alias gd='git diff --histogram'
alias gds='git diff --staged --histogram'

# 現在開いているフィーチャーブランチのIssueを開く
open-current-issue() {
  local ISSUE_NUMBER=`git branch --show-current | sed -e "s/\..*//g"`
  gh issue view $ISSUE_NUMBER --web
}

# 現在開いているフィーチャーブランチのPRを開く
open-current-pullrequest() {
  gh pr view --web
}

# 指定したPRを開く
open-pullrequest() {
  local PULL_REQUEST=$(gh pr list | fzf +m | awk '{print $1}')
  if [ -n "$PULL_REQUEST" ]; then
    gh pr view $PULL_REQUEST --web
  fi
}

# 指定したIssueを開く
open-issue() {
  local ISSUE=$(gh issue list --limit 1000 | fzf +m | awk '{print $1}')
  if [ -n "$ISSUE" ]; then
    gh issue view $ISSUE --web
  fi
}

# リモートブランチとの差分をとる
git-diff-remote() {
  gd $1 origin/$(git branch --show-current)..HEAD
}

# 今回コミットした差分をとる
git-diff-commit() {
  git diff HEAD^
}

# ブランチを切り替える
checkout-fzf-gitbranch() {
    local GIT_BRANCH=$(git branch --all | grep -v HEAD | fzf +m)
    if [ -n "$GIT_BRANCH" ]; then
        git checkout $(echo "$GIT_BRANCH" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    fi
    zle accept-line
}
zle -N checkout-fzf-gitbranch

# Issueを作成して、ブランチを切り替え
create-issue() {
  echo 'Issue Title: ' && read issuetitle
  echo 'Issue Body: ' && read issuebody
  echo 'Label: ' && read label
  echo 'Branch name: ' && read branchname
  issuenumber=`gh issue create --title "$issuetitle" --body "$issuebody" --label "$label" | tail -1 | cut -d / -f7`
  git co -b "$issuenumber.$branchname"
}

gitconfig-user-private() {
  git config user.name "Kobori Akira"
  git config user.email "private.beats@gmail.com"
}

# Issueを作成する
create-issue() {
  result=`gh issue create --title "$1" --body "Writing..." --assignee "@me"`
  chrome open ${result}
}
