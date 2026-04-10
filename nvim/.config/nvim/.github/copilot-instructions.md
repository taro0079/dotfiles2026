# Neovim Configuration - Copilot Instructions

## Architecture

This is a personal Neovim configuration using the **lazy.nvim** plugin manager. The structure follows a modular pattern:

- **init.lua**: Entry point that loads core modules in sequence
- **lua/options.lua**: Editor settings (tabs, search, undo, etc.)
- **lua/remap.lua**: Global keymaps (leader key is `<Space>`)
- **lua/lazy_init.lua**: Bootstraps lazy.nvim plugin manager
- **lua/awesometaro/init.lua**: Autocommands and LSP attach keybindings
- **lua/awesometaro/lazy/**: Plugin specifications (each file is a lazy.nvim plugin spec)

### Plugin Loading

All plugins are defined as separate files in `lua/awesometaro/lazy/`. lazy.nvim automatically loads all specs from this directory via `spec = "awesometaro.lazy"`.

## Key Conventions

### Plugin Organization

- Each plugin gets its own file in `lua/awesometaro/lazy/`
- Plugin files return a lazy.nvim spec table with setup/config
- Keybindings specific to a plugin live in that plugin's config function
- Global keybindings live in `lua/remap.lua`

### LSP Configuration

LSP setup is centralized in `lua/awesometaro/lazy/lsp.lua`:

- Uses **Mason** to manage language server installation
- Servers are auto-installed: `lua_ls`, `rust_analyzer`, `gopls`, `vtsls`, `tailwindcss`
- Custom server configs (like `lua_ls`, `tailwindcss`) use handler overrides
- LSP keybindings are set via `LspAttach` autocmd in `lua/awesometaro/init.lua`
- Completion via nvim-cmp with LuaSnip for snippets

### Formatting & Linting

- **conform.nvim** handles formatting with `format_on_save` enabled (5s timeout)
- Formatters per filetype: clang-format (C/C++), stylua (Lua), gofmt (Go), prettier (JS/TS), mix (Elixir)
- Manual format trigger: `<leader>f`
- **nvim-lint** runs linters on save/enter/leave insert mode
- Currently configured: phpstan for PHP

### Keybinding Patterns

Common patterns in `lua/remap.lua`:

- `<leader>pv`: Open file explorer (netrw)
- `<leader>pf`: Telescope find files
- `<C-p>`: Telescope git files
- `<leader>ps`: Telescope grep search (prompt)
- `<leader>pws`: Telescope grep word under cursor
- `<leader>pWs`: Telescope grep WORD under cursor
- `<leader>vh`: Telescope help tags
- `<leader>y`/`<leader>Y`: Yank to system clipboard
- `<leader>d`: Delete to black hole register
- `<leader><leader>`: Source current file
- `<leader>u`: Toggle undotree
- `<leader>zig`: Restart LSP
- Visual mode `J`/`K`: Move selected lines up/down

LSP keybindings (set on LspAttach in `lua/awesometaro/init.lua`):

- `gd`: Go to definition
- `K`: Hover documentation
- `<leader>vws`: Workspace symbol search
- `<leader>vd`: Open diagnostic float
- `<leader>vca`: Code actions
- `<leader>vrr`: References
- `<leader>vrn`: Rename
- `<C-h>` (insert mode): Signature help
- `[d`/`]d`: Next/previous diagnostic

Git keybindings (via Fugitive in `lua/awesometaro/lazy/fugitive.lua`):

- `<leader>gs`: Open Git status
- `<leader>p`: Git pull (in Fugitive buffer)
- `<leader>P`: Git push (in Fugitive buffer)
- `<leader>t`: Git push with upstream (prompts for branch)
- `gu`: Diff get left (merge conflict resolution)
- `gh`: Diff get right (merge conflict resolution)

Trouble keybindings:

- `<leader>tt`: Toggle Trouble
- `[t`/`]t`: Previous/next trouble item

Snippet keybindings (LuaSnip):

- `<C-s>e`: Expand snippet
- `<C-s>;`: Jump forward in snippet
- `<C-s>,`: Jump backward in snippet

### Language-Specific Setup

**Treesitter parsers**: Auto-installed for JavaScript, TypeScript, C, Lua, Rust, Bash, PHP, Go

**Custom parsers**: templ (Go template language) registered manually

**Treesitter optimizations**:
- HTML highlighting disabled
- Files >100KB have treesitter disabled for performance
- Markdown uses additional vim regex highlighting

### Autocommands

Set in `lua/awesometaro/init.lua`:

- Trim trailing whitespace on save for all files
- Yank highlight flash (40ms)
- LSP keybindings attached on LspAttach event

## File Editing

When modifying this configuration:

- Add new plugins as files in `lua/awesometaro/lazy/`
- Update language servers in the `ensure_installed` array in `lsp.lua`
- Add formatters to `formatters_by_ft` in `conform.lua`
- Add linters to `linters_by_ft` in `nvim-lint.lua`
- Global options go in `options.lua`
- Global keymaps go in `remap.lua`
- Plugin-specific keymaps go in the plugin's config function

### Important Editor Settings

From `lua/options.lua`:

- Tab width: 4 spaces
- Undo directory: `~/.vim/undodir` with persistent undo enabled
- No swap files or backup files
- Clipboard: system clipboard (`unnamedplus`)
- Mouse: disabled
- Color column at 80 characters
- Relative line numbers enabled
- No line wrapping

## Theme Configuration

Custom theme defined in `colors/pipboy.lua` and `lua/kurodake-green.lua`. Theme is loaded via plugin spec in `lua/awesometaro/lazy/pipboy.lua`.
