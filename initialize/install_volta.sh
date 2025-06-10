#!/bin/bash

# Voltaのインストール
curl https://get.volta.sh | bash
echo "export VOLTA_HOME=\$HOME/.volta" >> $DOTPATH/.zsh/.zsh__temporary.zsh
echo "export PATH=\$VOLTA_HOME/bin:\$PATH" >> $DOTPATH/.zsh/.zsh__temporary.zsh
echo $(tput setaf 2)Install Volta: complete!. ✔︎$(tput sgr0)
