# Homebrew
rm .brewfile
brew bundle dump --file=.brewfile

# VSCode
code --list-extensions > ./vscode/extensions.txt
