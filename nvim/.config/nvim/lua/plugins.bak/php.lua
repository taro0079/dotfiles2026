-- PHP追加設定（LSPの切り替えはoptions.luaのvim.g.lazyvim_php_lspで行う）
return {
  -- intelephenseの詳細設定（必要に応じてカスタマイズ）
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000,
              },
              environment = {
                phpVersion = "8.2", -- 使用しているPHPバージョンに合わせて変更
              },
            },
          },
        },
      },
    },
  },
}
