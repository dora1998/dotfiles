# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
source $HOME/.zshrc.local

fpath=(/usr/local/share/zsh-completions $fpath)
fpath=($HOME/.zsh/completion $fpath)
fpath+=~/.zfunc

source $HOME/.zshrc.path
source $HOME/.zshrc.alias

# https://qiita.com/yoshikaw/items/e12e239afdbaaec78ec7
DIRSTACKSIZE=100
setopt AUTO_PUSHD

# 補完機能有効にする
autoload -U compinit
compinit -u
 
# 補完候補に色つける
autoload -U colors
colors
zstyle ':completion:*' list-colors "${LS_COLORS}"
 
# 単語の入力途中でもTab補完を有効化
setopt complete_in_word

zstyle ':completion:*' menu select
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*:descriptions' format '%BCompleting%b %U%d%u'
# キャッシュの利用による補完の高速化
zstyle ':completion::complete:*' use-cache true
# 大文字、小文字を区別せず補完する
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完リストの表示間隔を狭くする
setopt list_packed

# historyに重複を記録しない
setopt hist_ignore_dups

# direnv
eval "$(direnv hook zsh)"

# bat theme
export BAT_THEME="OneHalfDark"

export LDFLAGS="-L/usr/local/opt/ruby/lib"
export CPPFLAGS="-I/usr/local/opt/ruby/include"
export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/Projects/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/Projects/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/Projects/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/Projects/google-cloud-sdk/completion.zsh.inc'; fi

# zaw
source $HOME/Projects/github.com/zsh-users/zaw/zaw.zsh
bindkey '^R' zaw-history
bindkey '^g' zaw-git-recent-branches

# z
. $HOME/Projects/github.com/rupa/z/z.sh

# prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc

export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
