FROM ubuntu:20.04

ENV LANG=jp_JP
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV TZ=Asia/Tokyo

RUN apt update \
  && apt upgrade -y \
  && apt install -y \
  autoconf -y \
  build-essential \
  curl \
  # git \
  unzip \
  wget \
  sudo \
  zsh \
  && apt clean

# rootのパスワードを設定
RUN echo "root:root" | chpasswd

# ユーザーを作成
ARG username=doboriakira
RUN useradd -m "${username}" && \
  echo "${username}:${username}" | chpasswd && \
  echo "%${username}    ALL=(ALL)   NOPASSWD:    ALL" > /etc/sudoers.d/${username} && \
  chmod 0440 /etc/sudoers.d/${username}

CMD ["zsh"]
