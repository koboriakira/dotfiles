# uv のインストール
curl -LsSf https://astral.sh/uv/install.sh | sh

# `source $HOME/.local/bin/env`を.zshrcに追加
if ! grep -q "source \$HOME/.local/bin/env" "$HOME/.zshrc"; then
  echo "source \$HOME/.local/bin/env" >> "$HOME/.zshrc"
fi
