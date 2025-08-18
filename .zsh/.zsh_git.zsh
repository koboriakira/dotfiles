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
alias grs='git reset'
alias grsh='git reset --hard'

# Issue系

gh-open-issue() {
  # 現在開いているフィーチャーブランチのIssueを開く
  local ISSUE_NUMBER=`git branch --show-current | sed -e "s/\..*//g"`
  gh issue view $ISSUE_NUMBER --web
}

gh-create-issue() {
  # Issueを作成して、ブランチを切り替える
  # $1：イシューのタイトル

  local TITLE=$1
  number=`gh issue create --title $TITLE --body "" | tail -1 | cut -d / -f7`
  branch_name=`_openai-api "#$number $TITLE" name-branch | jq -r '.branch_name'`
  git checkout -b $branch_name
  gh-create-pr "feat: $TITLE" $number
}

# Pull Request系

gh-open-pr() {
  # 現在開いている(フィーチャー)ブランチのPRを開く
  gh pr view --web
}

gh-create-pr() {
    # 現在開いているブランチのPRを作成する
    # $1：PRのタイトル
    # $2: 【任意】イシュー番号 (ブランチから取得できることもあるため)

    if [ $# -lt 1 ]; then
        echo "Input PR title"
        return 1
    fi

    branch=`git branch --show-current`

    if [ $# -eq 2 ]; then
        issue_number=$2
    else
        # `feature/#13-update-dependent-packages`のようなブランチ名を期待している
        issue_number=`git branch --show-current | cut -d# -f2 | cut -d- -f1`

        # issue_numberが数値でない場合はエラー
        if ! [[ $issue_number =~ ^[0-9]+$ ]]; then
            echo "Issue number is not numeric: $issue_number"
            return 1
        fi
    fi

    git commit --allow-empty -m "Create empty commit for PR"
    git push origin $branch
    url=`gh pr create --title "$1" --body "Close #$issue_number"`
}

# その他

git-config-user-private() {
  # プライベート用のユーザー情報を設定する
  git config user.name "Kobori Akira"
  git config user.email "private.beats@gmail.com"
}

git-delete-merged-branch() {
  # mainにマージ済のブランチを削除
  git branch --merged origin/HEAD | egrep -v '^\*|main$' | xargs git branch -d
}

# よくつかう

checkout-fzf-gitbranch() {
  # ブランチを切り替える

  local GIT_BRANCH=$(git branch --all | grep -v HEAD | fzf +m)
  if [ -n "$GIT_BRANCH" ]; then
      git checkout $(echo "$GIT_BRANCH" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  fi
  zle accept-line
}
zle -N checkout-fzf-gitbranch


# open-pr() {
#   # 指定したPRを開く
#   local PULL_REQUEST=$(gh pr list | fzf +m | awk '{print $1}')
#   if [ -n "$PULL_REQUEST" ]; then
#     gh pr view $PULL_REQUEST --web
#   fi
# }

git-set-upstream() {
  # upstreamを設定する
  # $1: リモート名 (デフォルトはorigin)
  # $2: ブランチ名 (デフォルトは現在のブランチ)

  local remote=${1:-origin}
  local branch=${2:-$(git branch --show-current)}

  git branch --set-upstream-to=$remote/$branch $branch
}
