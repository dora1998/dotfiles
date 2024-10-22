# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
ARCH=$(uname -m)
if [[ $ARCH == arm64 ]]; then
	eval $(/opt/homebrew/bin/brew shellenv)
elif [[ $ARCH == x86_64 ]]; then
	eval $(/usr/local/bin/brew shellenv)
fi

# Added by OrbStack: command-line tools and integration
[[ -f "$HOME/.orbstack/shell/init.zsh" ]] && source $HOME/.orbstack/shell/init.zsh 2>/dev/null || :

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
