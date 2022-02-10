# koboriakira/dotfiles

## インストール

環境変数DOTPATHを設定可能。デフォルトは`~/.dotfiles`

```shell
curl -fsSL https://raw.githubusercontent.com/koboriakira/dotfiles/main/install.sh | bash -s
```

gitが使えるなら、下記でもOK

```shell
git clone git@github.com:a-koboriakira/dotfiles.git && bash dotfiles/install.sh && cd .. && rm -fr dotfiles
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
