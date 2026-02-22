# 最低限のパッケージを取得
apt update \
  && apt upgrade -y \
  && apt install -y \
  autoconf \
  build-essential \
  curl \
  git \
  locales \
  unzip \
  wget \
  sudo \
  zsh \
  && apt clean

# rootのパスワードを設定
echo "root:root" | chpasswd

# ユーザーを作成
username=dockeruser
useradd -m "${username}" && \
  echo "${username}:${username}" | chpasswd && \
  echo "%${username}    ALL=(ALL)   NOPASSWD:    ALL" > /etc/sudoers.d/${username} && \
  chmod 0440 /etc/sudoers.d/${username}

# localeの設定
sed -i -E 's/# (en_US.UTF-8)/\1/' /etc/locale.gen
sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen
locale-gen
