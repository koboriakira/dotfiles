# Python のバージョン管理は mise に移行済み
# 参照: initialize/install_mise.sh

# uv のインストール（Python パッケージ管理ツール）
curl -LsSf https://astral.sh/uv/install.sh | sh

# `source $HOME/.local/bin/env`を.zshrcに追加
if ! grep -q "source \$HOME/.local/bin/env" "$HOME/.zshrc"; then
  echo "source \$HOME/.local/bin/env" >> "$HOME/.zshrc"
fi

echo "$(tput setaf 2)Install uv: complete!. ✔︎$(tput sgr0)"
