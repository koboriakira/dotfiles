#!/bin/bash
set -eu

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
curl -fsSLo ${HOME}/dotfiles.tar.gz ${DOT_TARBALL}
mkdir -p ${DOTPATH}
tar -zxf ${HOME}/dotfiles.tar.gz --strip-components 1 -C ${DOTPATH}
rm -f ${HOME}/dotfiles.tar.gz
echo $(tput setaf 2)Download dotfiles complete!. ✔︎$(tput sgr0)

# 初期設定、イニシャライズ
bash ${DOTPATH}/initialize.sh

# デプロイ
bash ${DOTPATH}/deploy.sh

# 環境変数を書き込み
echo "export DOTPATH=${DOTPATH}" >> ~/.zsh/.zsh__temporary.zsh

cd $CURRENT_DIRECTORY
