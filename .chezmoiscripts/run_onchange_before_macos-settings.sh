#!/bin/bash

set -Eeufo pipefail

# https://macos-defaults.com
# https://github.com/mathiasbynens/dotfiles/blob/main/.macos
# https://github.com/h3y6e/dotfiles/blob/main/.chezmoiscripts/darwin/run_onchange_before_2-configure.sh

printf "\033[3;35m%s\033[m\n" "setting up configure..."

# Dockを自動的に表示/非表示
defaults write com.apple.dock autohide -bool true
# Dockのサイズ
defaults write com.apple.dock "tilesize" -int "33"
# 最近使用したアプリケーションを表示しない
defaults write com.apple.dock "show-recents" -bool "false"
# マウス 軌跡の速さ
defaults write NSGlobalDomain com.apple.mouse.scaling -float "1"
# リピート入力認識までの時間: 最短
defaults write -g InitialKeyRepeat -int 15
# キーのリピート: 最速
defaults write -g KeyRepeat -int 2
# 外部キーボードのF1, F2などのキーを標準のファンクションキーとして使用
defaults write -g com.apple.keyboard.fnState -bool true
# 🌏キーを押して: 入力ソースを変更
defaults write com.apple.HIToolbox AppleFnUsageType -int "1"
# キーボードショートカット > Spotlight検索を表示: オフ
# defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "{enabled=0;value={parameters=(65535,49,1048576);type='standard';};}"
# デスクトップ項目: オン
defaults write com.apple.finder CreateDesktop -bool true
# 時計: 24時間表示
defaults write com.apple.menuextra.clock Show24Hour -int 1
# 時計: 秒を表示
defaults write com.apple.menuextra.clock ShowSeconds -int 1
# 最新の使用状況に基づいて操作スペースを自動的に並べ替える: オフ
defaults write com.apple.dock "mru-spaces" -bool "false"
# ウィンドウをアプリケーションごとにグループ化: オフ
defaults write com.apple.dock "expose-group-apps" -bool "false"

# 文頭を自動的に大文字にする: オフ
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# スペースバーを2回押してピリオドを入力: オフ
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# スマート引用符: オフ
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
# スマートダッシュ: オフ
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# スペルチェック: オフ
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
