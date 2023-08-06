# docker build -t dotfiles ./docker
# docker run -it --rm dotfiles
FROM ubuntu:22.04

# curlは入れておく
RUN apt update \
  && apt upgrade -y \
  && apt install -y curl \
  && apt clean

# セットアップ
RUN curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/docker_setup_debian.sh | bash -s

# シェルの設定
RUN curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/install.sh | bash -s

CMD ["zsh"]
