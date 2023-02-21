#!/bin/bash

# フォントをインストールする
wget https://github.com/yuru7/PlemolJP/releases/download/v1.1.0/PlemolJP_NF_v1.1.0.zip
unzip PlemolJP_NF_v1.1.0.zip
mv PlemolJP_NF_v1.1.0/PlemolJPConsole_NF/* /Library/Fonts
mv PlemolJP_NF_v1.1.0/PlemolJP35Console_NF/* /Library/Fonts
rm -fr PlemolJP_NF_v1.1.0
rm -f PlemolJP_NF_v1.1.0.zip