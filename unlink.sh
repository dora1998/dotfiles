#!/bin/bash

source src/dotfiles.sh

for file in ${DOT_FILES[@]}
do
  if [[ ! -e $HOME/$file ]]; then
    unlink $HOME/$file
  fi
done

unlink ~/Library/Application\ Support/Code/User/settings.json