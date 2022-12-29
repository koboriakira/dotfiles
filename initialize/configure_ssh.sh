SSH_CONFIG_FILE=~/.ssh/config

if [ ! -f "$SSH_CONFIG_FILE" ]; then
  touch $SSH_CONFIG_FILE
fi

# id_rsa_github_koboriakiraの設定
if grep -q private-github $SSH_CONFIG_FILE; then
  : # do nothing
else
  echo "Include private/private-github.conf" >> ~/.ssh/config
fi
