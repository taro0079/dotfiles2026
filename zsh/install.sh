#!/usr/bin/env zsh

# zsh-autosuggestion
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

# zsh-syntaxhighlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

# cache for figlet
mkdir -p ~/.cache/zsh
printf 'This is\nTaro Morita\n' \
    | figlet -f roman -w 200 \
    | lolcat -f \
    > ~/.cache/zsh/banner

# cache for thefuck
mkdir -p ~/.cache/zsh
if command -v thefuck &>/dev/null; then
    thefuck --alias > ~/.cache/zsh/thefuck.zsh
fi

# install tldr
# npm install -g tldr
