for file in ${DOT_FILES[@]}
do
  if [[ ! -e $HOME/$file ]]; then
    ln -s $HOME/dotfiles/config/$file $HOME/$file
  fi
done

# VSCode User Settings
ln -s $HOME/dotfiles/config/vscode/User/settings.json ~/Library/Application\ Support/Code/User/settings.json
