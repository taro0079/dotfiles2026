# sqls (SQL Language Server) integration for kakoune-lsp.
# Connections are loaded from ~/.config/sqls/config.yml automatically.

hook global BufSetOption filetype=sql %{
    set-option buffer lsp_servers %{
        [sqls]
        command = "sqls"
        root_globs = [".git", ".sqls/config.yml"]
    }
}

# --- sqls custom workspace commands ---------------------------------------
# Run a SELECTED query / EXPLAIN it. sqls exposes these as code actions too,
# so :lsp-code-actions also works after selecting some SQL.
define-command sqls-execute-query %{
    lsp-execute-command executeQuery '[]'
}

define-command sqls-explain-query %{
    lsp-execute-command executeExplain '[]'
}

# Show helpers (output goes to the *debug* / lsp message buffer).
# All show* commands require a boolean "show vertical" argument.
define-command sqls-show-connections %{ lsp-execute-command showConnections '[false]' }
define-command sqls-show-databases   %{ lsp-execute-command showDatabases   '[false]' }
define-command sqls-show-schemas     %{ lsp-execute-command showSchemas     '[false]' }
define-command sqls-show-tables      %{ lsp-execute-command showTables      '[false]' }

# Switchers. Pass the connection index (1-based, from ~/.config/sqls/config.yml)
# or a database name.
define-command sqls-switch-connection -params 1 -docstring \
    "sqls-switch-connection <index>: switch to connection N from sqls config.yml" %{
    lsp-execute-command switchConnections "[""%arg{1}""]"
}

define-command sqls-switch-database -params 1 -docstring \
    "sqls-switch-database <name>: switch active database on current connection" %{
    lsp-execute-command switchDatabase "[""%arg{1}""]"
}

# Optional user-mode keybindings under <user>q (for "Query"):
#   <user>q e  -> execute selected query
#   <user>q x  -> explain selected query
#   <user>q c  -> list connections
#   <user>q d  -> list databases
declare-user-mode sqls
map global user q ':enter-user-mode sqls<ret>' -docstring 'sqls mode'
map global sqls e ':sqls-execute-query<ret>'    -docstring 'execute selected query'
map global sqls x ':sqls-explain-query<ret>'    -docstring 'explain selected query'
map global sqls c ':sqls-show-connections<ret>' -docstring 'show connections'
map global sqls d ':sqls-show-databases<ret>'   -docstring 'show databases'
map global sqls s ':sqls-show-schemas<ret>'     -docstring 'show schemas'
map global sqls t ':sqls-show-tables<ret>'      -docstring 'show tables'
map global sqls C ':sqls-switch-connection '    -docstring 'switch connection (index)'
map global sqls D ':sqls-switch-database '      -docstring 'switch database (name)'
