#!/bin/zsh

# 下記をもとにライブラリを選んでみた
# https://qiita.com/obake_fe/items/c2edf65de684f026c59c#%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E5%B1%A5%E6%AD%B4%E6%A4%9C%E7%B4%A2

# 初期化
source $HOME/.zinit/bin/zinit.zsh

# zsh-completions: コマンド補完
zinit ice wait'0'; zinit light zsh-users/zsh-completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' ## 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*:default' menu select=1 ## 補完候補を一覧表示したとき、Tabや矢印で選択できるようにする

# zsh-syntax-highlighting: シンタックスハイライト
zinit light zsh-users/zsh-syntax-highlighting

# zsh-autosuggestions: 履歴補完
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244" # サジェストのカラー
