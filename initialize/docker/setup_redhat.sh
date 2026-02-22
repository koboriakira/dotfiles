# 最低限のライブラリをインストール
yum groupinstall -y "Development Tools"
yum install -y \
  autoconf \
  curl \
  git \
  kernel-devel \
  kernel-headers \
  tar \
  unzip \
  wget \
  sudo \
  zsh

# rootのパスワードを設定
echo "root:root" | chpasswd

# ユーザーを作成
username=doboriakira
useradd -m "${username}" && \
  echo "${username}:${username}" | chpasswd && \
  echo "%${username}    ALL=(ALL)   NOPASSWD:    ALL" > /etc/sudoers.d/${username} && \
  chmod 0440 /etc/sudoers.d/${username}
