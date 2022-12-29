if [ ! -d ~/Applications/Xcode.app ]; then
  echo 'XCodeをダウンロードしてください。'
  echo 'https://developer.apple.com/xcode/download/'
  exit 1
fi

# XCodeでなんかやってほしいらしい
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Flutterをインストール
version=2.10.0
cd ~
wget "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${version}-stable.zip"
unzip flutter_macos_${version}-stable.zip
rm -f flutter_macos_${version}-stable.zip
echo "export PATH=$PATH:$HOME/flutter/bin" >> ~/.dotfiles/.zsh/.zsh__temporary.zsh

# Android Studio, CocoaPodsをインストール
brew install --cask android-studio
brew install cocoapods

# flutter doctorを実行
export PATH=$PATH:$HOME/flutter/bin
flutter doctor

echo 'flutter doctor --android-licenses でAndroidのライセンスをなんとかすること'
