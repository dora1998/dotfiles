#!/bin/bash

DOT_FILES=( .zshrc .zshrc.path .zshrc.alias .gitconfig .vimrc )

for file in ${DOT_FILES[@]}
do
  if [[ ! -e $HOME/$file ]]; then
    ln -s $HOME/dotfiles/$file $HOME/$file
  fi
done

