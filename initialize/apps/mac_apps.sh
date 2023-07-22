#!/bin/bash

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
  pstree
brew install --cask \
  alfred \
  android-studio \
  docker \
  google-japanese-ime \
  iterm2 \
  karabiner-elements \
  licecap \
  notion \
  rectangle \
  sequel-ace \
  session-manager-plugin \
  visual-studio-code

# git-secretsの設定をグローバルに入れる
git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets
git config --global init.templatedir '~/.git-templates/git-secrets'
