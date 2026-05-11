#  This file should be sourced only once by session. It is not recommended to
# source it yourself; instead, when starting the KTS server, the binary will
# inject it directly into the session.

# kak-tree-sitter arguments used when invoking the command.
#
# This is mainly used to ensure we use the same arguments when invoking
# kak-tree-sitter from within Kakoune.
declare-option str-list tree_sitter_cli_args

# FIFO buffer path; this is used by Kakoune to write the content of buffers to
# update the tree-sitter representation on KTS side.
#
# Should only be set KTS side by buffer.
declare-option str tree_sitter_buf_fifo_path /dev/null

# Sentinel code used to delimit buffers in FIFOs.
declare-option str tree_sitter_buf_sentinel

# Highlight ranges used when highlighting buffers.
declare-option range-specs tree_sitter_hl_ranges

# Language a buffer uses. That option should be set at the buffer level.
declare-option str tree_sitter_lang

# Last known timestamp of previouses buffer updates.
declare-option int tree_sitter_buf_update_timestamp -1

# Wrapper for kak-tree-sitter.
define-command -hidden kak-tree-sitter -params .. %{
  evaluate-commands -no-hooks %sh{
    kak-tree-sitter $kak_opt_tree_sitter_cli_args -kr "$@"
  }
}

# Create a command to send to Kakoune for the current session.
#
# The parameter is the string to be used as payload.
define-command -hidden tree-sitter-request-with-session -params 1 %{
  kak-tree-sitter "{ ""metadata"": { ""session"": ""%val{session}"" }, ""payload"": { ""type"": ""%arg{1}"" } }"
}

# Create a command to send to Kakoune for the current session and client.
#
# The parameter is the string to be used as payload.
define-command -hidden tree-sitter-request-with-session-client -params 1 %{
  kak-tree-sitter "{ ""metadata"": { ""session"": ""%val{session}"", ""client"": ""%val{client}"" }, ""payload"": %arg{1} }"
}

# Create a command to send to Kakoune for the current session and buffer.
#
# The parameter is the string to be used as payload.
define-command -hidden tree-sitter-request-with-session-buffer -params 1 %{
  kak-tree-sitter "{ ""metadata"": { ""session"": ""%val{session}"", ""buffer"": ""%sh{
    if [ -n ""$kak_buffile"" ]; then
      printf '%s' ""$kak_buffile""
    else
      printf '%s' ""$kak_bufname""
    fi
  }"" }, ""payload"": %arg{1} }"}

# Create a command to send to Kakoune for the current session, client and buffer.
#
# The parameter is the string to be used as payload.
define-command -hidden tree-sitter-request-with-session-client-buffer -params 1 %{
  kak-tree-sitter "{ ""metadata"": { ""session"": ""%val{session}"", ""client"": ""%val{client}"", ""buffer"": ""%sh{
    if [ -n ""$kak_buffile"" ]; then
      printf '%s' ""$kak_buffile""
    else
      printf '%s' ""$kak_bufname""
    fi
  }"" }, ""payload"": %arg{1} }"}

# Notify KTS that a session exists.
define-command tree-sitter-session-begin %{
  tree-sitter-request-with-session 'session_begin'
}

# Notify KTS that the session is exiting.
define-command tree-sitter-session-end %{
  tree-sitter-request-with-session 'session_end'
  tree-sitter-remove-all
}

# Request KTS to reload its configuration (grammar, queries, etc.).
define-command tree-sitter-reload %{
  tree-sitter-request-with-session 'reload'
  tree-sitter-session-end
  tree-sitter-session-begin
}

# Request KTS to completely shutdown.
define-command tree-sitter-shutdown %{
  tree-sitter-request-with-session 'shutdown'
}

# Request KTS to update its metadata regarding a buffer.
define-command tree-sitter-buffer-metadata %{
  tree-sitter-request-with-session-buffer "{ ""type"": ""buffer_metadata"", ""lang"": ""%opt{tree_sitter_lang}"" }"
}

# Request KTS to update its buffer representation of the current buffer.
#
# The parameter is the language the buffer is formatted in.
define-command tree-sitter-buffer-update %{
  evaluate-commands -no-hooks %{
    write "%opt{tree_sitter_buf_fifo_path}"
    echo -to-file "%opt{tree_sitter_buf_fifo_path}" -- "%opt{tree_sitter_buf_sentinel}"
  }
}

# Request KTS to clean up resources of a closed buffer.
define-command tree-sitter-buffer-close %{
  tree-sitter-request-with-session-buffer "{ ""type"": ""buffer_close"" }"
}

# Request the kak-tree-sitter version used by the server.
define-command tree-sitter-version %{
  tree-sitter-request-with-session-client "{ ""type"": ""version"" }"
}

# Request KTS to apply text-objects on selections.
#
# First parameter is the pattern.
# Second parameter is the operation mode.
define-command tree-sitter-text-objects -params 2 %{
  tree-sitter-request-with-session-client-buffer "{ ""type"": ""text_objects"", ""pattern"": ""%arg{1}"", ""selections"": ""%val{selections_desc}"", ""mode"": ""%arg{2}"" }"
}

# Request KTS to apply “object-mode” text-objects on selections.
#
# First parameter is the pattern.
define-command tree-sitter-object-text-objects -params 1 %{
  tree-sitter-request-with-session-client-buffer "{ ""type"": ""text_objects"", ""pattern"": ""%arg{1}"", ""selections"": ""%val{selections_desc}"", ""mode"": { ""object"": { ""mode"": ""%val{select_mode}"", ""flags"": ""%val{object_flags}"" } } }"
}

# Request KTS to navigate the tree-sitter tree on selections.
#
# The first parameter is the direction to move to.
define-command tree-sitter-nav -params 1 %{
  tree-sitter-request-with-session-client-buffer "{ ""type"": ""nav"", ""selections"": ""%val{selections_desc}"", ""dir"": %arg{1} }"
}

# User-overrideable command called right after inserting the tree-sitter
# highlighter.
#
# Useful to introduce a highlighter with higher priority to prevent the
# tree-sitter highlighter from overriding it.
define-command tree-sitter-user-after-highlighter nop

# Install main hooks.
define-command -hidden tree-sitter-hook-install-session %{
  # Hook that runs when the session ends.
  hook -group tree-sitter global KakEnd .* %{
    tree-sitter-session-end
  }
}

# Install a hook that updates buffer content if it has changed.
define-command -hidden tree-sitter-hook-install-update %{
  # Since this hook can be installed several times (after each changes of the
  # tree_sitter_lang option; see tree-sitter-hook-install-main), it’s better
  # to first try to remove the hooks.
  remove-hooks buffer tree-sitter-update

  # Buffer update
  hook -group tree-sitter-update buffer NormalIdle .* %{ tree-sitter-exec-if-changed tree-sitter-buffer-update }
  hook -group tree-sitter-update buffer InsertIdle .* %{ tree-sitter-exec-if-changed tree-sitter-buffer-update }

  # Initial highlight
  tree-sitter-buffer-update

  # Buffer close
  hook -group tree-sitter-update buffer BufClose .* %{ tree-sitter-buffer-close }
}

# Set the tree_sitter_lang buffer-option for all known buffers.
#
# This command should only be used once the session is enabled, and permit to
# dynamically enable tree-sitter for a buffer that was opened and fully displayed
# before the session was KTS-enabled
define-command -hidden tree-sitter-initial-set-buffer-lang %{
  evaluate-commands -buffer "*" %{
    set-option buffer tree_sitter_lang "%opt{filetype}"
  }
}

# A helper function that executes its argument only if the buffer has changed.
define-command -hidden tree-sitter-exec-if-changed -params 1 %{
  set-option -remove buffer tree_sitter_buf_update_timestamp %val{timestamp}

  try %{
    evaluate-commands "tree-sitter-exec-nop-%opt{tree_sitter_buf_update_timestamp}"
    set-option buffer tree_sitter_buf_update_timestamp %val{timestamp}
  } catch %{
    # Actually run the command
    set-option buffer tree_sitter_buf_update_timestamp %val{timestamp}
    evaluate-commands %arg{1}
  }
}

# A helper function that does nothing.
#
# Used with tree-sitter-exec-if-changed to have a fallback when the buffer has
# not changed.
define-command -hidden tree-sitter-exec-nop-0 nop

# Remove every tree-sitter commands, hooks, options, etc.
define-command tree-sitter-remove-all %{
  remove-hooks global tree-sitter

  evaluate-commands -buffer * %{
    try %{
      remove-highlighter buffer/tree-sitter-highlighter
    }

    try %{
      remove-hooks buffer tree-sitter-update
    }

    unset-option buffer tree_sitter_lang
    unset-option buffer tree_sitter_buf_update_timestamp
    unset-option buffer tree_sitter_buf_fifo_path
    unset-option buffer tree_sitter_buf_sentinel
    unset-option buffer tree_sitter_hl_ranges
  }
}

declare-user-mode tree-sitter
declare-user-mode tree-sitter-search
declare-user-mode tree-sitter-search-rev
declare-user-mode tree-sitter-search-extend
declare-user-mode tree-sitter-search-extend-rev
declare-user-mode tree-sitter-find
declare-user-mode tree-sitter-find-rev
declare-user-mode tree-sitter-find-extend
declare-user-mode tree-sitter-find-extend-rev
declare-user-mode tree-sitter-select

map global tree-sitter /     ':enter-user-mode tree-sitter-search<ret>'                            -docstring 'search next'
map global tree-sitter <a-/> ':enter-user-mode tree-sitter-search-rev<ret>'                        -docstring 'search prev'
map global tree-sitter ?     ':enter-user-mode tree-sitter-search-extend<ret>'                     -docstring 'search(extend) next'
map global tree-sitter <a-?> ':enter-user-mode tree-sitter-search-extend-rev<ret>'                 -docstring 'search(extend) prev'
map global tree-sitter f     ':enter-user-mode tree-sitter-find<ret>'                              -docstring 'find next'
map global tree-sitter <a-f> ':enter-user-mode tree-sitter-find-rev<ret>'                          -docstring 'find prev'
map global tree-sitter F     ':enter-user-mode tree-sitter-find-extend<ret>'                       -docstring 'find(extend) next'
map global tree-sitter <a-F> ':enter-user-mode tree-sitter-find-extend-rev<ret>'                   -docstring 'find(extend) prev'
map global tree-sitter k     ':enter-user-mode tree-sitter-select<ret>'                            -docstring 'select'
map global tree-sitter s     ":tree-sitter-nav '""parent""'<ret>"                                  -docstring 'select parent'
map global tree-sitter t     ":tree-sitter-nav '""first_child""'<ret>"                             -docstring 'select first child'
map global tree-sitter <c-t> ":tree-sitter-nav '""last_child""'<ret>"                              -docstring 'select last child'
map global tree-sitter c     ":tree-sitter-nav '{ ""prev_sibling"": { ""cousin"": false } }'<ret>" -docstring 'select previous sibling'
map global tree-sitter r     ":tree-sitter-nav '{ ""next_sibling"": { ""cousin"": false } }'<ret>" -docstring 'select next sibling'
map global tree-sitter C     ":tree-sitter-nav '{ ""prev_sibling"": { ""cousin"": true } }'<ret>"  -docstring 'select previous sibling (cousin)'
map global tree-sitter R     ":tree-sitter-nav '{ ""next_sibling"": { ""cousin"": true } }'<ret>"  -docstring 'select next sibling (cousin)'
map global tree-sitter (     ":tree-sitter-nav '""first_sibling""'<ret>"                           -docstring 'select first sibling'
map global tree-sitter )     ":tree-sitter-nav '""last_sibling""'<ret>"                            -docstring 'select last sibling'
map global tree-sitter T     ':enter-user-mode tree-sitter-nav-sticky<ret>'                        -docstring 'sticky tree navigation'

map global tree-sitter-search f ':tree-sitter-text-objects function.around search_next<ret>'  -docstring 'function'
map global tree-sitter-search a ':tree-sitter-text-objects parameter.around search_next<ret>' -docstring 'parameter'
map global tree-sitter-search t ':tree-sitter-text-objects class.around search_next<ret>'     -docstring 'class'
map global tree-sitter-search c ':tree-sitter-text-objects comment.around search_next<ret>'   -docstring 'comment'
map global tree-sitter-search T ':tree-sitter-text-objects test.around search_next<ret>'      -docstring 'test'

map global tree-sitter-search-rev f ':tree-sitter-text-objects function.around search_prev<ret>'  -docstring 'function'
map global tree-sitter-search-rev a ':tree-sitter-text-objects parameter.around search_prev<ret>' -docstring 'parameter'
map global tree-sitter-search-rev t ':tree-sitter-text-objects class.around search_prev<ret>'     -docstring 'class'
map global tree-sitter-search-rev T ':tree-sitter-text-objects test.around search_prev<ret>'      -docstring 'test'

map global tree-sitter-search-extend f ':tree-sitter-text-objects function.around search_extend_next<ret>'  -docstring 'function'
map global tree-sitter-search-extend a ':tree-sitter-text-objects parameter.around search_extend_next<ret>' -docstring 'parameter'
map global tree-sitter-search-extend t ':tree-sitter-text-objects class.around search_extend_next<ret>'     -docstring 'class'
map global tree-sitter-search-extend T ':tree-sitter-text-objects test.around search_extend_next<ret>'      -docstring 'test'

map global tree-sitter-search-extend-rev f ':tree-sitter-text-objects function.around search_extend_prev<ret>'  -docstring 'function'
map global tree-sitter-search-extend-rev a ':tree-sitter-text-objects parameter.around search_extend_prev<ret>' -docstring 'parameter'
map global tree-sitter-search-extend-rev t ':tree-sitter-text-objects class.around search_extend_prev<ret>'     -docstring 'class'
map global tree-sitter-search-extend-rev T ':tree-sitter-text-objects test.around search_extend_prev<ret>'      -docstring 'test'

map global tree-sitter-find f ':tree-sitter-text-objects function.around find_next<ret>'  -docstring 'function'
map global tree-sitter-find a ':tree-sitter-text-objects parameter.around find_next<ret>' -docstring 'parameter'
map global tree-sitter-find t ':tree-sitter-text-objects class.around find_next<ret>'     -docstring 'class'
map global tree-sitter-find T ':tree-sitter-text-objects test.around find_next<ret>'      -docstring 'test'

map global tree-sitter-find-rev f ':tree-sitter-text-objects function.around find_prev<ret>'  -docstring 'function'
map global tree-sitter-find-rev a ':tree-sitter-text-objects parameter.around find_prev<ret>' -docstring 'parameter'
map global tree-sitter-find-rev t ':tree-sitter-text-objects class.around find_prev<ret>'     -docstring 'class'
map global tree-sitter-find-rev T ':tree-sitter-text-objects test.around find_prev<ret>'      -docstring 'test'

map global tree-sitter-find-extend f ':tree-sitter-text-objects function.around extend_next<ret>'  -docstring 'function'
map global tree-sitter-find-extend a ':tree-sitter-text-objects parameter.around extend_next<ret>' -docstring 'parameter'
map global tree-sitter-find-extend t ':tree-sitter-text-objects class.around extend_next<ret>'     -docstring 'class'
map global tree-sitter-find-extend T ':tree-sitter-text-objects test.around extend_next<ret>'      -docstring 'test'

map global tree-sitter-find-extend-rev f ':tree-sitter-text-objects function.around extend_prev<ret>'  -docstring 'function'
map global tree-sitter-find-extend-rev a ':tree-sitter-text-objects parameter.around extend_prev<ret>' -docstring 'parameter'
map global tree-sitter-find-extend-rev t ':tree-sitter-text-objects class.around extend_prev<ret>'     -docstring 'class'
map global tree-sitter-find-extend-rev T ':tree-sitter-text-objects test.around extend_prev<ret>'      -docstring 'test'

map global tree-sitter-select f ':tree-sitter-text-objects function.around select<ret>'  -docstring 'function'
map global tree-sitter-select a ':tree-sitter-text-objects parameter.around select<ret>' -docstring 'parameter'
map global tree-sitter-select t ':tree-sitter-text-objects class.around select<ret>'     -docstring 'class'
map global tree-sitter-select T ':tree-sitter-text-objects test.around select<ret>'      -docstring 'test'

map global object f '<a-;>tree-sitter-object-text-objects function<ret>'  -docstring 'function (tree-sitter)'
map global object t '<a-;>tree-sitter-object-text-objects class<ret>'     -docstring 'type (tree-sitter)'
map global object a '<a-;>tree-sitter-object-text-objects parameter<ret>' -docstring 'argument (tree-sitter)'
map global object T '<a-;>tree-sitter-object-text-objects test<ret>'      -docstring 'test (tree-sitter)'

# sticky mode for navigation
declare-user-mode tree-sitter-nav-sticky

define-command -hidden tree-sitter-nav-sticky-undo %{
  execute-keys "<a-u>"
  enter-user-mode tree-sitter-nav-sticky
}

define-command -hidden tree-sitter-nav-sticky-parent %{
  tree-sitter-nav '"parent"'
  enter-user-mode tree-sitter-nav-sticky
}

define-command -hidden tree-sitter-nav-sticky-first-child %{
  tree-sitter-nav '"first_child"'
  enter-user-mode tree-sitter-nav-sticky
}

define-command -hidden tree-sitter-nav-sticky-last-child %{
  tree-sitter-nav '"last_child"'
  enter-user-mode tree-sitter-nav-sticky
}

define-command -hidden tree-sitter-nav-sticky-prev-sibling -params 1 %{
  tree-sitter-nav "{ ""prev_sibling"": { ""cousin"": %arg{1} }}"
  enter-user-mode tree-sitter-nav-sticky
}

define-command -hidden tree-sitter-nav-sticky-next-sibling -params 1 %{
  tree-sitter-nav "{ ""next_sibling"": { ""cousin"": %arg{1} }}"
  enter-user-mode tree-sitter-nav-sticky
}

define-command -hidden tree-sitter-nav-sticky-first-sibling %{
  tree-sitter-nav '"first_sibling"'
  enter-user-mode tree-sitter-nav-sticky
}

define-command -hidden tree-sitter-nav-sticky-last-sibling %{
  tree-sitter-nav '"last_sibling"'
  enter-user-mode tree-sitter-nav-sticky
}

map global tree-sitter-nav-sticky s     ':tree-sitter-nav-sticky-parent<ret>'             -docstring 'select parent'
map global tree-sitter-nav-sticky t     ':tree-sitter-nav-sticky-first-child<ret>'        -docstring 'select first child'
map global tree-sitter-nav-sticky <c-t> ':tree-sitter-nav-sticky-first-child<ret>'        -docstring 'select last child'
map global tree-sitter-nav-sticky C     ':tree-sitter-nav-sticky-prev-sibling true<ret>'  -docstring 'select previous sibling (cousin)'
map global tree-sitter-nav-sticky R     ':tree-sitter-nav-sticky-next-sibling true<ret>'  -docstring 'select next sibling (cousin)'
map global tree-sitter-nav-sticky c     ':tree-sitter-nav-sticky-prev-sibling false<ret>' -docstring 'select previous sibling'
map global tree-sitter-nav-sticky r     ':tree-sitter-nav-sticky-next-sibling false<ret>' -docstring 'select next sibling'
map global tree-sitter-nav-sticky (     ':tree-sitter-nav-sticky-first-sibling<ret>'      -docstring 'select first sibling'
map global tree-sitter-nav-sticky )     ':tree-sitter-nav-sticky-last-sibling<ret>'       -docstring 'select last sibling'
map global tree-sitter-nav-sticky u     ':tree-sitter-nav-sticky-undo<ret>'               -docstring 'undo selection'

set-option global tree_sitter_cli_args
set-face global ts_attribute default
set-face global ts_comment default
set-face global ts_comment_block ts_comment
set-face global ts_comment_line ts_comment
set-face global ts_comment_unused ts_comment
set-face global ts_constant default
set-face global ts_constant_builtin ts_constant
set-face global ts_constant_builtin_boolean ts_constant_builtin
set-face global ts_constant_character ts_constant
set-face global ts_constant_character_escape ts_constant_character
set-face global ts_constant_macro ts_constant
set-face global ts_constant_numeric ts_constant
set-face global ts_constant_numeric_float ts_constant_numeric
set-face global ts_constant_numeric_integer ts_constant_numeric
set-face global ts_constructor default
set-face global ts_diff_delta ts_diff
set-face global ts_diff_delta_moved ts_diff_delta
set-face global ts_diff_minus ts_diff
set-face global ts_diff_plus ts_diff
set-face global ts_embedded default
set-face global ts_error default
set-face global ts_function default
set-face global ts_function_builtin ts_function
set-face global ts_function_macro ts_function
set-face global ts_function_method ts_function
set-face global ts_function_method_private ts_function_method
set-face global ts_function_special ts_function
set-face global ts_hint default
set-face global ts_include default
set-face global ts_info default
set-face global ts_keyword default
set-face global ts_keyword_conditional ts_keyword
set-face global ts_keyword_control ts_keyword
set-face global ts_keyword_control_conditional ts_keyword_control
set-face global ts_keyword_control_except ts_keyword_control
set-face global ts_keyword_control_exception ts_keyword_control
set-face global ts_keyword_control_import ts_keyword_control
set-face global ts_keyword_control_repeat ts_keyword_control
set-face global ts_keyword_control_return ts_keyword_control
set-face global ts_keyword_directive ts_keyword
set-face global ts_keyword_function ts_keyword
set-face global ts_keyword_operator ts_keyword
set-face global ts_keyword_special ts_keyword
set-face global ts_keyword_storage ts_keyword
set-face global ts_keyword_storage_modifier ts_keyword_storage
set-face global ts_keyword_storage_modifier_mut ts_keyword_storage_modifier
set-face global ts_keyword_storage_modifier_ref ts_keyword_storage_modifier
set-face global ts_keyword_storage_type ts_keyword_storage
set-face global ts_label default
set-face global ts_load default
set-face global ts_markup_bold ts_markup
set-face global ts_markup_heading ts_markup
set-face global ts_markup_heading_1 ts_markup_heading
set-face global ts_markup_heading_2 ts_markup_heading
set-face global ts_markup_heading_3 ts_markup_heading
set-face global ts_markup_heading_4 ts_markup_heading
set-face global ts_markup_heading_5 ts_markup_heading
set-face global ts_markup_heading_6 ts_markup_heading
set-face global ts_markup_heading_marker ts_markup_heading
set-face global ts_markup_italic ts_markup
set-face global ts_markup_link_label ts_markup_link
set-face global ts_markup_link_text ts_markup_link
set-face global ts_markup_link_uri ts_markup_link
set-face global ts_markup_link_url ts_markup_link
set-face global ts_markup_list_checked ts_markup_list
set-face global ts_markup_list_numbered ts_markup_list
set-face global ts_markup_list_unchecked ts_markup_list
set-face global ts_markup_list_unnumbered ts_markup_list
set-face global ts_markup_quote ts_markup
set-face global ts_markup_raw ts_markup
set-face global ts_markup_raw_block ts_markup_raw
set-face global ts_markup_raw_inline ts_markup_raw
set-face global ts_markup_strikethrough ts_markup
set-face global ts_namespace default
set-face global ts_operator default
set-face global ts_punctuation default
set-face global ts_punctuation_bracket ts_punctuation
set-face global ts_punctuation_delimiter ts_punctuation
set-face global ts_punctuation_special ts_punctuation
set-face global ts_special default
set-face global ts_string default
set-face global ts_string_escape ts_string
set-face global ts_string_regexp ts_string
set-face global ts_string_special ts_string
set-face global ts_string_special_path ts_string_special
set-face global ts_string_special_symbol ts_string_special
set-face global ts_string_symbol ts_string
set-face global ts_tag default
set-face global ts_tag_error ts_tag
set-face global ts_text default
set-face global ts_type default
set-face global ts_type_builtin ts_type
set-face global ts_type_enum_variant ts_type_enum
set-face global ts_type_enum_variant_builtin ts_type_enum_variant
set-face global ts_type_parameter ts_type
set-face global ts_variable default
set-face global ts_variable_builtin ts_variable
set-face global ts_variable_other_member ts_variable_other
set-face global ts_variable_other_member_private ts_variable_other_member
set-face global ts_variable_parameter ts_variable
set-face global ts_warning default

