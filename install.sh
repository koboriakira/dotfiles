#!/bin/bash
set -eu
CURRENT_DIRECTORY=`pwd`

# DOTPATHの設定
set +u
if [ -z ${DOTPATH} ]; then
  export DOTPATH=~/.dotfiles
fi
set -u

DOT_TARBALL="https://github.com/a-kobori/dotfiles/tarball/master"
REMOTE_URL="git@github.com:a-kobori/dotfiles.git"

# ディレクトリがなければダウンロード（と解凍）する
echo "Downloading dotfiles..."
mkdir ${DOTPATH}

if type "git" > /dev/null 2>&1; then
  git clone --recursive "${REMOTE_URL}" "${DOTPATH}"
else
  curl -fsSLo ${HOME}/dotfiles.tar.gz ${DOT_TARBALL}
  tar -zxf ${HOME}/dotfiles.tar.gz --strip-components 1 -C ${DOTPATH}
  rm -f ${HOME}/dotfiles.tar.gz
fi
echo $(tput setaf 2)Download dotfiles complete!. ✔︎$(tput sgr0)

# 初期設定、イニシャライズ
bash initialize.sh

# デプロイ
bash deploy.sh

cd $CURRENT_DIRECTORY
