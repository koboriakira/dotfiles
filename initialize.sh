#!/bin/bash

# 端末依存用のrun commandを記録するためのスクリプトを作成
touch $DOTPATH/.zsh/.zsh__temporary.zsh

# brewのインストール
if type "brew" > /dev/null 2>&1; then
  : # do nothing
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if test -e /etc/os-release ; then
    # Linuxのときはlinuxbrewのevalを設定
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $DOTPATH/.zsh/.zsh__temporary.zsh
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $DOTPATH/.zsh/.zsh__temporary.zsh
  fi
fi

# アプリのインストール
bash ${DOTPATH}/initialize/apps/install.sh
echo $(tput setaf 2)Install applications: complete!. ✔︎$(tput sgr0)

# Voltaのインストール
curl https://get.volta.sh | bash
echo "export VOLTA_HOME=\$HOME/.volta" >> $DOTPATH/.zsh/.zsh__temporary.zsh
echo "export PATH=\$VOLTA_HOME/bin:\$PATH" >> $DOTPATH/.zsh/.zsh__temporary.zsh
echo $(tput setaf 2)Install Volta: complete!. ✔︎$(tput sgr0)

# zinitのインストール
mkdir ${HOME}/.zinit && cd $_
git clone https://github.com/zdharma-mirror/zinit.git ${HOME}/.zinit/bin
cd $HOME

# vim-plugをインストール
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# starshipのインストール
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

# Mac向けの初期設定を実行
if test -e /etc/os-release ; then
  :
else
  curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/initialize/fonts.sh | bash -s
  curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/initialize/configure_ssh.sh | bash -s
  curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/initialize/initialize_mac.sh | bash -s
fi
