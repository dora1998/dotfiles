cat config/vscode/extensions.$1.txt | while read line
do
  code --install-extension $line
done
