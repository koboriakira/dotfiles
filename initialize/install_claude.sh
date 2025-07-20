brew install --cask claude

# すでに存在する場合は削除してからシンボリックリンクを作成
if [ -e "$HOME/Library/Application Support/Claude/claude_desktop_config.json" ]; then
  rm "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
fi

# シンボリックリンクを作成
ln -s '/Users/a_kobori/.dotfiles/claude/claude_desktop_config.json' '/Users/a_kobori/Library/Application Support/Claude/claude_desktop_config.json'
