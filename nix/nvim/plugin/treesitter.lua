--local parser_dir = vim.fn.expand("~/.local/share/nvim/treesitter/parser/")
--vim.opt.runtimepath:prepend(parser_dir)
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    --parser_install_dir = parser_dir,
    modules = {},
    ignore_install = {},
    ensure_installed = {},
    sync_install = false
    , auto_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = false, },
  }
end, 1)
