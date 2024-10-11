#!/bin/bash

# google-japanese-imeを入れるために必要
sudo softwareupdate --install-rosetta

brew install \
  awscli \
  chrome-cli \
  coreutils \
  diffutils \
  docker \
  findutils \
  ffmpeg \
  fswatch \
  gawk \
  git-secrets \
  gnu-sed \
  gnu-tar \
  graphviz \
  gzip \
  iproute2mac \
  lv \
  nektos/tap/act \
  plantuml \
  pstree \
  python \
  pyenv \
  pipenv
brew install --cask \
  1password \
  alfred \
  android-studio \
  docker \
  google-chrome \
  google-japanese-ime \
  hammerspoon \
  iterm2 \
  karabiner-elements \
  licecap \
  notion \
  rectangle \
  sequel-ace \
  session-manager-plugin \
  slack \
  swinsian \
  visual-studio-code \
  wezterm

# git-secretsの設定をグローバルに入れる
git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets
git config --global init.templatedir '~/.git-templates/git-secrets'
