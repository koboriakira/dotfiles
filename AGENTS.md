# AGENTS.md

このファイルは、AIコーディングエージェント（Codex、Claude Code、Copilotなど）がこのリポジトリで作業する際のガイドラインを定義するものです。

## リポジトリ概要

`koboriakira/dotfiles` — macOS / Linux 向けの dotfiles 管理リポジトリ。シェル設定、エディタ設定、各種ツールのインストールスクリプトを一元管理している。

## ディレクトリ構成

```
.dotfiles/
├── install.sh          # エントリポイント: clone → initialize → deploy
├── initialize.sh       # 初期セットアップ（brew, アプリ, mise, zinit 等）
├── deploy.sh           # ドットファイルを $HOME にシンボリックリンク
├── initialize/         # 各ツールのインストールスクリプト群
│   ├── apps/           # brew / brew cask によるアプリインストール
│   ├── github/         # リポジトリの clone
│   └── python/         # Python パッケージ管理ツール（uv）のセットアップ
├── .zsh/               # Zsh 設定ファイル群（alias, git, keybind, etc.）
├── .zshrc              # Zsh メインエントリポイント
├── .zshenv             # 環境変数の定義
├── .config/            # アプリケーション設定（nvim, starship, mise, etc.）
├── .claude/            # Claude Code 用設定・コマンド
├── claude/             # Claude Desktop 設定
├── scripts/            # ユーティリティスクリプト
├── python/             # Python スクリプト
├── docker_setup_*.sh   # Docker 環境向けセットアップ
└── .env.template       # 環境変数テンプレート
```

## ツールバージョン管理（mise）

[mise](https://mise.jdx.dev/) を使用して開発ツールのバージョンを一元管理している。

- **設定ファイル**: `.config/mise/config.toml` にグローバルなツールバージョンを宣言的に定義する。
- **管理対象ツール**: Node.js, Python, Rust 等。新しいツールを追加する場合は `config.toml` の `[tools]` セクションに追記する。
- **シェル統合**: `.zshrc` で `mise activate zsh` を実行し、シェルセッションでツールを自動的に利用可能にしている。
- **プロジェクト固有のバージョン**: 各プロジェクトに `mise.toml` を配置すれば、プロジェクト単位でツールバージョンを上書きできる。
- **旧ツールとの関係**: Volta（Node.js）、pyenv（Python）、rustup（Rust）は mise に統合済み。

## 重要な規約

### 言語

- コード中のコメント・ドキュメントは **日本語** で記述すること。
- コミットメッセージも日本語を使用すること。

### セキュリティ

- `.env` には機密情報が含まれる。Git にコミットしない（`.gitignore` 済み）。
- SSH 秘密鍵やトークン等の認証情報をコードに含めないこと。
- `.env.template` を更新する場合、実際の値を含めないこと。

### シェルスクリプト

- シェルは **Bash** (`#!/bin/bash`) を使用する。
- 環境変数 `$DOTPATH` はリポジトリのルート（デフォルト: `~/.dotfiles`）を指す。スクリプト内ではこの変数を使ってパスを参照すること。
- macOS / Linux の互換性を意識する。OS 固有の処理は `test -e /etc/os-release` で分岐する。

### Zsh 設定

- `.zshrc` は各設定ファイルを `source` で読み込むだけの構成。個別の設定は `.zsh/` 配下のファイルに分離すること。
- `.zsh/.zsh__temporary.zsh` は端末依存の設定を保存するファイル。Git 管理外。
- 新しい設定カテゴリを追加する場合は `.zsh/.zsh_<カテゴリ名>.zsh` を作成し、`.zshrc` に `source` 行を追加する。

### デプロイ（シンボリックリンク）

- `deploy.sh` はリポジトリのルートにあるドットファイル・ドットディレクトリ（`.??*`）を `$HOME` にシンボリックリンクする。
- `.git`, `.gitignore`, `.devcontainer`, `.DS_Store`, `.ssh` は除外される。
- 新しいドットファイルを追加する場合、除外対象でないことを確認すること。

## テスト

- このリポジトリにはテストフレームワークはない。
- スクリプトの変更はローカル環境で手動確認する。破壊的変更に注意すること。

## 開発ワークフロー

1. 変更は既存のファイル構成・命名規約に従う。
2. 新しいインストールスクリプトは `initialize/` 配下に配置し、`initialize.sh` から呼び出す。
3. 変更後は `deploy.sh` の挙動に影響がないか確認する。
