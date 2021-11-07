HISTFILE=$HOME/.zsh-history # 履歴を保存するファイル
HISTSIZE=100000             # メモリ上に保存する履歴のサイズ
SAVEHIST=1000000            # 上述のファイルに保存する履歴のサイズ
HISTTIMEFORMAT="[%Y/%M/%D %H:%M:%S] " #ヒストリの一覧を読みやすい形に変更

setopt inc_append_history   # 実行時に履歴をファイルにに追加していく
setopt share_history        # 履歴を他のシェルとリアルタイム共有する

setopt AUTO_CD # パスを直接入力してもcdする
setopt AUTO_PARAM_KEYS # 環境変数を補完
setopt AUTO_LIST # 曖昧な補完で、自動的に選択肢をリストアップ

setopt noclobber # リダイレクトで既存のファイルを上書きしない

autoload -Uz colors && colors # プロンプトをカラー表示する
autoload -Uz compinit && compinit # 保管機能を有効にして、実行する
