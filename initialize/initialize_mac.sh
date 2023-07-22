#!/bin/bash

# sudo mdutil -a -i off # Spotlight検索をオフ

# Dock
defaults write com.apple.dock persistent-apps -array # Dock に標準で入っている全てのアプリを消す
defaults write com.apple.dock autohide -bool true # Dockを自動的に隠す
defaults write com.apple.dock magnification -bool false # フォーカスによるアイコンの大きさを変えない
defaults write com.apple.dock showhidden -bool YES # 隠しアプリを半透明化

# Finder
defaults write com.apple.finder AppleShowAllFiles YES # 隠しファイルを表示
defaults write com.apple.finder ShowStatusBar -bool true # ステータスバーを表示
defaults write com.apple.finder ShowPathbar -bool true # パスバーを表示
defaults write com.apple.finder ShowTabView -bool true # タブバーを表示
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true # タイトルにフルパスを表示
defaults write com.apple.finder AnimateWindowZoom -bool false # フォルダを開くときのアニメーションを無効
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false # ファイルを開くときのアニメーションを無効
defaults write com.apple.finder DisableAllAnimations -bool true # Finderのアニメーション効果を全て無効にする
defaults write -g NSScrollViewRubberbanding -bool no # スクロールバーの弾むアニメーションを無効にする
defaults write -g NSWindowResizeTime 0.1 # ダイアログ表示やウィンドウリサイズ速度を高速化
chflags nohidden ~/Library # 「ライブラリ」を常に表示
# スクリーンキャプチャ
mkdir -p ${HOME}/Downloads/.screencapture
defaults write com.apple.screencapture name screenshot # スクリーンキャプチャのファイル名を変更
defaults write com.apple.screencapture location ${HOME}/Downloads/.screencapture # スクリーンキャプチャの保存先を変更

# 設定
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true # ネットワークディスクで、`.DS_Store` ファイルを作らない
defaults write com.apple.menuextra.battery ShowPercent -string "YES" # バッテリー残量を数値で表示
defaults write com.apple.menuextra.clock DateFormat -string "M\u6708d\u65e5(EEE)  H:mm:ss" # 日付や時刻を表示
defaults write com.apple.dashboard mcx-disabled -bool true # Dashboardを無効にする
defaults write com.apple.dock mcx-expose-disabled -bool true # Mission Controlを無効にする
defaults write com.apple.CrashReporter DialogType none # クラッシュリポーターを無効にする
defaults write NSGlobalDomain AppleShowScrollBars -string "Always" # スクロールバーを常に表示

# キーボード
defaults write NSGlobalDomain KeyRepeat -int 2 # キーのリピート
defaults write NSGlobalDomain InitialKeyRepeat -int 15 # リピート入力認識までの時間

# トラックパッド
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true # スクロール方向をナチュラルに


# 設定を反映
killall SystemUIServer
killall Finder
killall Dock
