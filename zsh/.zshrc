# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
## plugin
plugins=(
    git
    # zsh-autosuggestions
    # zsh-autocomplete
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

eval "$(zoxide init zsh)"
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.volta/bin:$PATH"
export PATH="/usr/local/texlive/2024/bin/universal-darwin:$PATH"
# export PATH="$HOME/.rbenv/bin:$PATH"
# # rbenvの初期化
# eval "$(rbenv init - zsh)"
# export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
# export PATH="/opt/homebrew/opt/php@8.2/bin:$PATH"
# eval "$(thefuck --alias)"
# export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
# export PATH="$PATH:$(go env GOPATH)/bin" # for go
# source "$HOME/.cargo/env" # for cargo
# . "$HOME/.local/bin/env" # for uv
#
# # pnpm
# export PNPM_HOME="/home/taro/.local/share/pnpm"
# case ":$PATH:" in
#   *":$PNPM_HOME:"*) ;;
#   *) export PATH="$PNPM_HOME:$PATH" ;;
# esac
alias E='open /Applications/Emacs.app'
alias fssh='fuzzy-ssh-selector.sh'
. "$HOME/.cargo/env"

# bun completions
[ -s "/Users/taro_morita/.bun/_bun" ] && source "/Users/taro_morita/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH=$PATH:$(go env GOPATH)/bin

eval "$(~/.local/bin/mise activate)"
export LIBRARY_PATH=$LIBRARY_PATH:$(brew --prefix zstd)/lib/ # for rails error surpression of zstd
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
# pnpm end



ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
if [[ ! -d "$ZSH_CUSTOM/plugins/zeno" ]]; then
  git clone https://github.com/yuki-yano/zeno.zsh.git "$ZSH_CUSTOM/plugins/zeno"
fi
source $HOME/.oh-my-zsh/custom/plugins/zeno/zeno.zsh
export ZENO_HOME=~/.config/zeno
bindkey ' ' zeno-auto-snippet
bindkey '^m' zeno-auto-snippet-and-accept-line
bindkey '^i' zeno-completion
bindkey '^x^p' zeno-insert-snippet
bindkey '^r' zeno-history-selection
bindkey '^x^f' zeno-ghq-cd


export EDITOR="nvim"
export XDG_CONFIG_HOME="$HOME/.config"

# jj
jjn() {
    jj new $(jj bookmark list --all | fzf | awk '{print $2}')
}
