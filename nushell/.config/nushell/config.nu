# config.nu
#
# Installed by:
# version = "0.112.2"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

def --env fgh [] {
  let target = (ghq list -p | fzf | str trim)
  if ($target | is-not-empty) {
    cd $target
  }
}

def rpstx-jj  [] {
  let bookmark = (jj bookmark list -r @ | awk '{print $1}' | sed 's/://')

  if ($bookmark | is-empty) {
    print 'Bookmark is not found'
    return
  }


  bash git_rpstx.sh $bookmark
}

def rpst-jj  [] {
  let bookmark = (jj bookmark list -r @ | awk '{print $1}' | sed 's/://')

  if ($bookmark | is-empty) {
    print 'Bookmark is not found'
    return
  }


  bash git_rpst.sh $bookmark
}
source ~/.zoxide.nu

$env.PATH = (
  $env.PATH
  | prepend ($env.HOME | path join ".local" "scripts")
  | prepend "opt/homebrew/bin"
  | uniq
)

alias fssh = ^fuzzy-ssh-selector.sh

def "nu-complete npm scripts" [] {
  try {
    open package.json
    | get scripts
    | transpose value description
  } catch {
    []
  }
}

extern "npm run" [
    script?: string@"nu-complete npm scripts"
    ...args: string
]

use ~/.config/nushell/completions-jj.nu *
use ~/.config/nushell/git-completions.nu *
