#!/bin/bash

# miseのインストール
# https://mise.jdx.dev/
curl https://mise.run | sh
echo $(tput setaf 2)Install mise: complete!. ✔︎$(tput sgr0)

# グローバル設定ファイルのシンボリックリンクを作成
MISE_CONFIG_DIR="${HOME}/.config/mise"
mkdir -p "${MISE_CONFIG_DIR}"
if [ -e "${MISE_CONFIG_DIR}/config.toml" ]; then
  rm -f "${MISE_CONFIG_DIR}/config.toml"
fi
ln -snfv "${DOTPATH}/.config/mise/config.toml" "${MISE_CONFIG_DIR}/config.toml"

# mise でツールをインストール
export PATH="${HOME}/.local/bin:${PATH}"
mise install --yes
echo $(tput setaf 2)Install mise tools: complete!. ✔︎$(tput sgr0)
