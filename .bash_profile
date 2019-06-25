export PATH=/usr/local/bin:$PATH
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

if [ -f $HOME/.bashrc ]; then
    source $HOME/.bashrc
fi
