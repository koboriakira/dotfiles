# docker build -t dotfiles docker
# docker build --no-chace -t dotfiles docker
FROM ubuntu:20.04

WORKDIR /tmp

# セットアップ
ADD docker_setup_debian.sh docker_setup_debian.sh
RUN bash docker_setup_debian.sh

# シェルの設定
RUN curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/install_non_git.sh | bash -s

CMD ["zsh"]
