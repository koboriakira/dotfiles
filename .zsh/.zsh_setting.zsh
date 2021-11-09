setopt inc_append_history   # 実行時に履歴をファイルにに追加していく
setopt share_history        # 履歴を他のシェルとリアルタイム共有する

setopt AUTO_CD # パスを直接入力してもcdする
setopt AUTO_PARAM_KEYS # 環境変数を補完
setopt AUTO_LIST # 曖昧な補完で、自動的に選択肢をリストアップ

setopt noclobber # リダイレクトで既存のファイルを上書きしない

autoload -Uz colors && colors # プロンプトをカラー表示する
autoload -Uz compinit && compinit -C # 保管機能を有効にして、実行する
# compinitが遅いので、-Cオプションをつけてセキュリティチェックを飛ばす
