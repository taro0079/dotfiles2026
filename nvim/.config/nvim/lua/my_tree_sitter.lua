local parsers = require("nvim-treesitter.parsers").get_parser_configs()

parsers.smarty = {
  install_info = {
    url = "https://github.com/taro0079/tree-sitter-smarty",
    files = { "src/parser.c" },
    branch = "main",
  },
}
