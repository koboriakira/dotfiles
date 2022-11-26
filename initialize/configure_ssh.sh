# id_rsa_github_koboriakiraの設定
if grep -q private-github ~/.ssh/config; then
  : # do nothing
else
  wget https://raw.githubusercontent.com/koboriakira/dotfiles/main/.ssh/private-github.conf ~/.ssh/private-github.conf
  echo private-github.conf >> ~/.ssh/config
fi
