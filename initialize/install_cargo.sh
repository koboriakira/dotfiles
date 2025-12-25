#!/bin/bash

# Rustのインストール (rustup経由でcargoも含む)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
echo "export CARGO_HOME=\$HOME/.cargo" >> $DOTPATH/.zsh/.zsh__temporary.zsh
echo "export PATH=\$CARGO_HOME/bin:\$PATH" >> $DOTPATH/.zsh/.zsh__temporary.zsh
echo $(tput setaf 2)Install Cargo: complete!. ✔︎$(tput sgr0)
