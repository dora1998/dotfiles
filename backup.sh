# Homebrew
rm config/.brewfile.$1
brew bundle dump --file=config/.brewfile.$1

# VSCode
code --list-extensions > ./config/vscode/extensions.$1.txt
