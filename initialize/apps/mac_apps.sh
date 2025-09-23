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
  pstree \
  python \
  pyenv \
  pipenv \
  uv
brew install --cask \
  1password \
  alfred \
  android-studio \
  docker \
  github \
  google-chrome \
  google-japanese-ime \
  hammerspoon \
  iterm2 \
  karabiner-elements \
  licecap \
  mediahuman-audio-converter \
  notion \
  notion-calendar \
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
