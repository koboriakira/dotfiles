#!/bin/bash

# 端末依存用のrun commandを記録するためのスクリプトを作成
touch $DOTPATH/.zsh/.zsh__temporary.zsh

# brewのインストール
bash ${DOTPATH}/initialize/install_brew.sh

# アプリのインストール
bash ${DOTPATH}/initialize/apps/install.sh
echo $(tput setaf 2)Install applications: complete!. ✔︎$(tput sgr0)

# miseのインストール（Node.js, Python, Rust 等のバージョン管理）
bash ${DOTPATH}/initialize/install_mise.sh

# zinitのインストール
bash ${DOTPATH}/initialize/install_zinit.sh

# vim-plugをインストール
bash ${DOTPATH}/initialize/install_vim_plug.sh

# git clone
bash ${DOTPATH}/initialize/github/clone_repositories.sh

# Python関連のインストール（uv）
bash ${DOTPATH}/initialize/python/install_python.sh

# Claudeのインストール
bash ${DOTPATH}/initialize/install_claude.sh

# starshipのインストール
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

# Mac向けの初期設定を実行
if test -e /etc/os-release ; then
  :
else
  # フォント
  curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/initialize/fonts.sh | bash -s

  # SSHの設定
  curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/initialize/configure_ssh.sh | bash -s

  # Macの初期設定
  curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/initialize/initialize_mac.sh | bash -s
fi
