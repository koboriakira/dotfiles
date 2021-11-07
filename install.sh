#!/bin/bash
set -eu

if type "git" > /dev/null 2>&1; then
  : # do nothing
else
  echo "ERROR: 初期設定にはgitが必要です"
  exit 1
fi

CURRENT_DIRECTORY=`pwd`

# DOTPATHの設定
set +u
if [ -z ${DOTPATH} ]; then
  export DOTPATH=$HOME/.dotfiles
fi
set -u
DOT_TARBALL="https://github.com/koboriakira/dotfiles/tarball/main"
REMOTE_URL="git@github.com:koboriakira/dotfiles.git"

# ダウンロード
echo "Downloading dotfiles..."
mkdir ${DOTPATH}
git clone --recursive "${REMOTE_URL}" "${DOTPATH}"
echo $(tput setaf 2)Download dotfiles complete!. ✔︎$(tput sgr0)

# 初期設定、イニシャライズ
bash ${DOTPATH}/initialize.sh

# デプロイ
bash ${DOTPATH}/deploy.sh

cd $CURRENT_DIRECTORY
