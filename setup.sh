#!/bin/bash

DOT_FILES=( .bash_profile .zshrc .zshrc.path .zshrc.alias .gitconfig .vimrc )

for file in ${DOT_FILES[@]}
do
  if [[ ! -e $HOME/$file ]]; then
    ln -s $HOME/dotfiles/$file $HOME/$file
  fi
done

# Homebrew restore
brew bundle install --file=.brewfile

# VSCode User Settings
ln -s $HOME/dotfiles/vscode/User/settings.json ~/Library/Application\ Support/Code/User/settings.json

# VSCode Extentions
cat ./vscode/extensions.txt | while read line
do
  code --install-extension $line
done
