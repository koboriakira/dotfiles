#!/bin/bash
mkdir -p ${HOME}/Downloads/.screencapture
defaults write com.apple.screencapture location ${HOME}/Downloads/.screencapture
killall SystemUIServer
