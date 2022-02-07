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
    # Macのときは、brewの基本設定としてman8に書き込み権限を付与
    chown -R $(whoami) /usr/local/share/man/man1 && chmod u+w /usr/local/share/man/man1
    echo $(tput setaf 2)Install brew: complete!. ✔︎$(tput sgr0)
  fi
fi

# アプリのインストール
bash ${DOTPATH}/initialize/apps/install.sh
echo $(tput setaf 2)Install applications: complete!. ✔︎$(tput sgr0)

# nodebrewのインストール
curl -L git.io/nodebrew | perl - setup
echo $(tput setaf 2)Install nodebrew: complete!. ✔︎$(tput sgr0)
echo "export PATH=\$HOME/.nodebrew/current/bin:\$PATH" >> $DOTPATH/.zsh/.zsh__temporary.zsh

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
  curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/initialize/initialize_mac.sh | bash -s
fi
