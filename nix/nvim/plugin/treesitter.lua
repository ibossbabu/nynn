--vim.cmd.packadd 'nvim-treesitter'
--vim.opt.runtimepath:prepend(vim.fn.expand("~/.local/share/nvim/treesitter"))
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    --parser_install_dir = vim.fn.expand("~/.local/share/nvim/treesitter/parser/"),
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
