#!/bin/bash

# 相対パスを使うためにcd
SCRIPT_DIR=`dirname $0`
cd $SCRIPT_DIR

source src/bootstrap.sh

prompt '🍺 Install Homebrew?'
if [[ $? -eq 0 ]]; then
  source src/install/brew.sh
fi

# Homebrew restore
prompt '📦 Restore Homebrew packages?'
if [[ $? -eq 0 ]]; then
  source src/install/brew_packages.sh $1
fi

# VSCode Extentions
prompt '✍️  Install VSCode Extensions?'
if [[ $? -eq 0 ]]; then
  source src/install/vscode.sh
fi
