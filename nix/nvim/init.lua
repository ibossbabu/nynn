_G.start_time = vim.uv.hrtime()
vim.loader.enable()
require("options")
require("keymaps")
require("quickswap")

require("lze").load {
  { "nvim-surround",
    event = "BufReadPost",
    after = function()
      require("nvim-surround").setup()
    end,
  },
  { "nvim-autopairs",
    event = "InsertEnter",
    after = function()
      require("nvim-autopairs").setup()
    end,
  },
  { import = "plugins/conform" },
  { import = "plugins/completion" },
  { import = "plugins/oil" },
  { import = "plugins/lsp-config" },
  { import = "plugins/mell" },
}
--vim.lsp.enable({ "lua-ls", "nixd" })
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local end_time = vim.uv.hrtime()
    local startup_time = (end_time - _G.start_time) / 1000000
    vim.defer_fn(function()
      print(string.format("⚡ MEOWeovim loaded in ~%.2fms", startup_time))
    end, 10)
  end,
})
