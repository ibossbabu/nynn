vim.cmd.packadd 'catppuccin-nvim'
return {
  {
    "catppuccin-nvim",
    colorscheme = "catppuccin",
  },
  vim.cmd.colorscheme("catppuccin-mocha")
}
