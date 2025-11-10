#!/bin/bash

ZSHRC_LOCAL="$HOME/.zshrc.local"

if [ ! -f "$ZSHRC_LOCAL" ]; then
    echo "Creating $ZSHRC_LOCAL..."
    touch "$ZSHRC_LOCAL"
    echo "# Local zsh configuration" > "$ZSHRC_LOCAL"
    echo "# Add your local settings here" >> "$ZSHRC_LOCAL"
    echo "Created $ZSHRC_LOCAL"
else
    echo "$ZSHRC_LOCAL already exists, skipping..."
fi
