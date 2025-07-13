# koboriakira/dotfiles

## インストール

### 前提

- [Homebrew](https://brew.sh/)が動くこと
- git, gh, wget, rosettaが動くこと
  - 下記のコマンドでインストールがそれぞれ可能

```shell
# gitをインストールするために必要
xcode-select --install

# gh, wgetをインストールするために必要
brew install gh wget

# google-japanese-imeを入れるために必要
sudo softwareupdate --install-rosetta
```

### インストール手順

```shell
git clone git@github.com.koboriakira:koboriakira/dotfiles.git ~/.dotfiles
```

```shell
# 環境変数DOTPATHを設定可能。デフォルトは`~/.dotfiles`
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
git clone git@github.com:koboriakira/dotfiles.git && bash dotfiles/install.sh && cd .. && rm -fr dotfiles
```

## Docker環境のセットアップ

### Debian

```shell
curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/docker_setup_debian.sh | bash -s
```

### Redhat

```shell
curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/docker_setup_redhat.sh | bash -s
```

## 工程の概要

- brewをインストール
  - Linuxでもlinuxbrewとして利用できるようなのでこれを採用
  - もしかしたら各OSごとに書き分けるかも
- アプリをインストール
  - 詳細は後述のbrew, brew caskを参照
  - そのほかzinit, starship, vim-plugも入れている

## 参照

- [VSCode NeoVim拡張　使うまでに詰まったところ](https://zenn.dev/bun913/articles/02785aed0ba50e)
