eval "$(zoxide init zsh)"
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.volta/bin:$PATH"
export PATH="/usr/local/texlive/2024/bin/universal-darwin:$PATH"
alias E='open /Applications/Emacs.app'
alias fssh='fuzzy-ssh-selector.sh'
. "$HOME/.cargo/env"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH=$PATH:$HOME/go/bin

export PATH="$HOME/.local/share/mise/shims:$PATH" # to faster
if [[ "$(uname -s)" == "Darwin" ]]; then
  export LIBRARY_PATH=$LIBRARY_PATH:/opt/homebrew/zstd/lib/ # for rails error surpression of zstd
fi

alias cdp='cd $HOME/ghq/$(ghq list | fzf)'

fbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# pnpm
export PNPM_HOME="/Users/taro_morita/Library/pnpm"
# mysql client
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

export LDFLAGS="-L/opt/homebrew/opt/mysql-client/lib"
export CPPFLAGS="-I/opt/homebrew/opt/mysql-client/include"

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export EDITOR="nvim"
export XDG_CONFIG_HOME="$HOME/.config"

# jj
jjn() {
    jj new $(jj bookmark list --all | fzf | awk '{print $2}')
}


# completions
fpath=(
  "$HOME/.zsh/completion"
  ~/.zsh/completion
  /opt/homebrew/share/zsh-completions
  /opt/homebrew/share/zsh/site-functions
  /opt/homebrew/share/zsh/functions
  $fpath
)
autoload -Uz compinit && compinit -i

# bun completions (must be after compinit because it uses compdef)
[ -s "/Users/taro_morita/.bun/_bun" ] && source "/Users/taro_morita/.bun/_bun"

bindkey -e

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000
setopt share_history
setopt hist_ignore_all_dups
setopt auto_cd
setopt auto_pushd

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# rpst-planning-installer
export PATH="${HOME}/.local/bin:${PATH}"
eval "$("$HOME/.local/bin/mise" activate zsh)"
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
