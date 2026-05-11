# Kakoune Configuration

Personal Kakoune setup with LSP, tree-sitter, fzf integration, and assorted plugins.

## Layout

```
~/.config/kak/
├── kakrc                  # Main entry point
├── sqls.kak               # SQL Language Server (sqls) integration
├── refresh-cache.sh       # Regenerate startup caches (run after upgrades)
├── cache/                 # Generated startup caches (gitignored if you VCS this)
│   ├── kak-lsp.kak        # Cached output of `kak-lsp`
│   └── kak-tree-sitter.kak # Cached output of `kak-tree-sitter -dks --init`
├── colors/                # Colorschemes
├── autoload/              # Auto-loaded scripts (Kakoune default)
└── plugins/               # Cloned plugins (managed by plug.kak)
    ├── plug.kak/          # Plugin manager (loaded on demand only)
    ├── auto-pairs.kak/
    ├── kakoune-find/
    ├── kakoune-git-mode/
    ├── kakoune-lsp/       # Not sourced; only the binary `kak-lsp` is used
    ├── simple-git-gutter.kak/
    ├── smarttab.kak/
    └── tokyonight.kak/
```

## External binaries required

| Binary | Purpose | Install |
|---|---|---|
| `kak-lsp` | LSP client used by Kakoune | `brew install kak-lsp` |
| `kak-tree-sitter` | Syntax highlighting / text objects | `cargo install kak-tree-sitter` |
| `sqls` | SQL Language Server | `go install github.com/sqls-server/sqls@latest` |
| `fzf`, `fd`/`rg`, `bat` | Fuzzy file/grep pickers | `brew install fzf fd ripgrep bat` |
| `yazi` | File manager | `brew install yazi` |
| `herb-language-server` | ERB LSP | `npm i -g @herb-tools/language-server` |
| `vscode-html-language-server` | HTML LSP (used for Smarty) | `npm i -g vscode-langservers-extracted` |

## Startup-time optimisation

The original config took **~1000 ms cold (1.5 s)** to start. After the changes
documented here it starts in **~450–500 ms**. Two main techniques:

### 1. Cache slow `eval %sh{...}` invocations

Both `kak-lsp` and `kak-tree-sitter --init` print Kakoune commands at startup.
Their output is **session-independent**, so we cache it once to a file and
`source` that file instead of forking the binary every time Kakoune starts.

- `cache/kak-lsp.kak` ≈ 3175 lines, replaces `eval %sh{kak-lsp}`
- `cache/kak-tree-sitter.kak` ≈ 467 lines, replaces the init half of
  `eval %sh{ kak-tree-sitter -dks --init $kak_session }`

The tree-sitter daemon still needs to be running, so we spawn it in the
background (non-blocking):

```kak
nop %sh{ kak-tree-sitter -ds >/dev/null 2>&1 & }
```

### 2. Bypass `plug.kak` at startup

`plug.kak` and its 7 `plug ...` calls cost ~650 ms because plug iterates plugin
directories and runs FS checks. Plug's value is **install/update**, not daily
loading. We `source` each plugin's main `.kak` directly and only load `plug.kak`
on demand:

```kak
define-command plug-init -docstring '...' %{
    source "%val{config}/plugins/plug.kak/rc/plug.kak"
}
```

When you want to install/update plugins:
```
:plug-init
:plug-install      # or :plug-update, :plug-clean, :plug-list
```

## Refreshing the caches

Whenever you upgrade `kak-lsp` or `kak-tree-sitter`, regenerate the caches:

```sh
~/.config/kak/refresh-cache.sh
```

This rewrites both `cache/*.kak` files. Restart Kakoune to pick them up.

If you forget, you'll still get the *previous* version's command set — usually
fine, but commands added in the new version won't exist.

## Adding / removing plugins

### Add

1. `:plug-init` → `:plug-install` in Kakoune (after adding a `plug` line),
   **or** clone manually into `~/.config/kak/plugins/`.
2. Add a `source "%val{config}/plugins/NAME/MAIN.kak"` line in `kakrc` under
   the "Plugins (direct source...)" section, with any post-load setup
   (e.g. `enable-foo`, `colorscheme`, mappings).

### Remove

1. Delete the `source` line in `kakrc` and any related setup.
2. `rm -rf ~/.config/kak/plugins/NAME` (or `:plug-init` then `:plug-clean`).

## LSP

Servers are enabled per-filetype via:

```kak
hook global WinSetOption filetype=(php|go|ruby|typescript|erb|smarty|sql) %{
    lsp-enable-window
}
```

Connections to specific servers are configured by setting `lsp_servers` per
buffer. Examples in `kakrc`:

- **erb** → `herb-language-server`
- **smarty** → `vscode-html-language-server` (with format disabled)
- **sql** → `sqls` (defined in `sqls.kak`)

Standard `kak-lsp` filetype hooks (php, go, ruby, typescript) are loaded from
`cache/kak-lsp.kak` and don't need manual configuration.

### Keybindings (LSP)

| Key | Command |
|---|---|
| `<user>l` | Enter LSP user mode |
| `<goto>d` | `lsp-definition` |
| `<goto>r` | `lsp-references` |
| `<goto>i` | `lsp-implementation` |
| `<goto>y` | `lsp-type-definition` |
| `<user>a` | `lsp-code-actions` |
| `<user>R` | `lsp-rename-prompt` |
| `<a-a>` / `a` (object) | `lsp-object` (any symbol) |
| `f` (object) | `lsp-object Function Method` |
| `t` (object) | `lsp-object Class Interface Module Namespace Struct` |
| `d` / `D` (object) | `lsp-diagnostic-object` (warnings / errors) |

## SQL (sqls)

`sqls.kak` defines:

| Command | What it does |
|---|---|
| `:sqls-execute-query` | Execute the selected SQL |
| `:sqls-explain-query` | EXPLAIN the selected SQL |
| `:sqls-show-connections` | List connections from `~/.config/sqls/config.yml` |
| `:sqls-show-databases` | List databases on current connection |
| `:sqls-show-schemas` | List schemas |
| `:sqls-show-tables` | List tables |
| `:sqls-switch-connection N` | Switch to connection #N (1-based) |
| `:sqls-switch-database NAME` | Switch active database |

Bound under `<user>q` ("query mode"):

| Key | Action |
|---|---|
| `e` | Execute selected query |
| `x` | Explain selected query |
| `c` / `d` / `s` / `t` | Show connections / databases / schemas / tables |
| `C` | Switch connection (prompts for index) |
| `D` | Switch database (prompts for name) |

DB connection details live in `~/.config/sqls/config.yml` (sqls reads it
automatically; nothing in this repo).

## Other custom commands / keys

| Command | Use |
|---|---|
| `:fzf-file` (`<user>f f`) | Fuzzy file picker |
| `:fzf-buffer` (`<user>f b`) | Fuzzy buffer picker |
| `:fzf-grep` (`<user>f g`) | Live grep with preview |
| `:yazi` (`<user>e`) | Open yazi file manager and edit chosen file |
| `:php-cs-fix` | Run `php-cs-fixer` on the current buffer |
| `:rubocop` | Format current buffer with rubocop |
| `:send-rpstv2` | Sync current buffer to remote server (rpst-v2 only) |
| `:v2test` | Run remote PHPUnit test for current buffer |
| `:open-testrunner` | Open the rpst-x test runner in browser |
| `:pathcopy` | Copy current buffer path to clipboard |
| `:add-comma-to-end` (`<user>,`) | Append `,` to end of line |

### Window management

| Key | Action |
|---|---|
| `<C-w>` | Enter window user mode |
| `v` | Open horizontal tmux split with new Kakoune client |
| `s` | Open vertical tmux split with new Kakoune client |

### Misc

| Key | Action |
|---|---|
| `#` | Comment current line |
| `<user>y` | Yank to system clipboard (`pbcopy`) |
| `<tab>` / `<s-tab>` (in completion popup) | Next / previous completion |

## Auto-sync rpst-v2 on save

```kak
hook global BufWritePost .*/ghq/github.com/PRECS-Inc/rpst-v2/.* %{
    send-rpstv2
}
```

Saving any file under `.../rpst-v2/...` triggers `transport_rpstv2.rb` in the
background.

## Troubleshooting

| Symptom | Fix |
|---|---|
| LSP commands missing after upgrading kak-lsp | `~/.config/kak/refresh-cache.sh`, restart Kakoune |
| `lsp-enable-window` does nothing on a SQL file | Check `which sqls`; check `:lsp-show-error` |
| `:plug-install` undefined | Run `:plug-init` first |
| Tree-sitter highlighting missing | `pkill kak-tree-sitter`; restart Kakoune (daemon respawns) |
| sqls "required arguments were not provided" | Re-check the command's args list; some show* take a `[false]` "vertical" flag |

## Benchmarks (M-series Mac)

```sh
time kak -ui dummy -e quit
```

| Stage | Wall |
|---|---|
| Bare kak (`-n -ui dummy -e quit`) | ~10 ms |
| Bare + system rc only | ~100 ms |
| Original config | ~1000 ms (cold ~1500 ms) |
| After cache | ~870 ms |
| **After plug.kak bypass** | **~450–500 ms** |
