FROM ubuntu:20.04

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV TZ=Asia/Tokyo

RUN apt update \
  && apt upgrade -y \
  && apt install -y \
  build-essential \
  curl \
  git \
  unzip \
  wget \
  && apt clean

RUN curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/install.sh | bash -s
