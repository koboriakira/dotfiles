SSH_CONFIG_FILE=~/.ssh/config

if [ ! -f "$SSH_CONFIG_FILE" ]; then
  mkdir -p ~/.ssh
  touch $SSH_CONFIG_FILE
fi

# id_rsa_github_koboriakiraの設定
if grep -q private-github $SSH_CONFIG_FILE; then
  : # do nothing
else
  mkdir -p ~/.ssh/private
  cp -f $DOTPATH/.ssh/private/private-github.conf ~/.ssh/private/private-github.conf
  echo "Include private/private-github.conf" >> ~/.ssh/config
fi
