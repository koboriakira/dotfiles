# koboriakira/dotfiles

## インストール

環境変数DOTPATHを設定可能。デフォルトは`~/.dotfiles`

```shell
curl -fsSL https://raw.githubusercontent.com/a-kobori/dotfiles/master/install.sh?token=AVIKQWA6NRGKEVT5BMOEVKLBQ43WO | bash -s
```

gitが使えるなら、下記でもOK

```shell
git clone git@github.com:a-kobori/dotfiles.git && bash dotfiles/install.sh && cd .. && rm -fr dotfiles
```

# 工程の概要

- brewをインストール
  - Linuxでもlinuxbrewとして利用できるようなのでこれを採用
  - もしかしたら各OSごとに書き分けるかも
- アプリをインストール
  - 詳細は後述のbrew, brew caskを参照
  - そのほかzinit, starshipも入れている
