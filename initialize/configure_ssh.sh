# id_rsa_github_koboriakiraの設定
if grep -q private-github ~/.ssh/config; then
  : # do nothing
else
  echo private/private-github.conf >> ~/.ssh/config
fi
