brew install --cask claude

# すでに存在する場合は削除してからシンボリックリンクを作成
if [ -e "$HOME/Library/Application Support/Claude/claude_desktop_config.json" ]; then
  rm -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
fi

# シンボリックリンクを作成
ln -s "$HOME/.dotfiles/claude/claude_desktop_config.json" "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
