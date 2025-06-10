#!/bin/bash

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
