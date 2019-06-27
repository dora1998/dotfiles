fpath=(/usr/local/share/zsh-completions $fpath)
fpath=($HOME/.zsh/completion $fpath)
source $HOME/.bash_profile

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

# コマンドの打ち間違いを指摘してくれる
setopt correct
SPROMPT="correct: $RED%R$DEFAULT -> $GREEN%r$DEFAULT ? [Yes/No/Abort/Edit] => "

# https://github.com/sindresorhus/pure
autoload -U promptinit; promptinit
prompt pure

#export GO111MODULE=on
eval "$(goenv init -)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/mtakeuchi/Projects/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/mtakeuchi/Projects/google-cloud-sdk/path.zsh.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/Users/mtakeuchi/Projects/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/mtakeuchi/Projects/google-cloud-sdk/completion.zsh.inc'; fi

# direnv
eval "$(direnv hook zsh)"

# bat theme
export BAT_THEME="GitHub"

export LDFLAGS="-L/usr/local/opt/ruby/lib"
export CPPFLAGS="-I/usr/local/opt/ruby/include"
export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"

# pipenv
export PIPENV_VENV_IN_PROJECT=true
