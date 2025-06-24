#!/bin/bash

# リポジトリ名の配列
repositories=(
    "applescript"
    "ocr-screenshot"
    "alfred_python"
    "selenium_tool"
    "pdf-tool"
    "blog-tool"
    "squoosh-cli"
    "chrome-extension-slack-link-post"
    "copy_camerarolls"
)

# ~/git ディレクトリが存在しない場合は作成
mkdir -p ~/git

# ~/git ディレクトリに移動
cd ~/git

# 各リポジトリをクローン
for repo in "${repositories[@]}"; do
    echo "Cloning $repo..."
    git clone git@github.com:koboriakira/$repo.git
done
