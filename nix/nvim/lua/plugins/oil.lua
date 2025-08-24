return {
  {
    "oil.nvim",
    keys = {
      { "-",         "<CMD>Oil<CR>",                               desc = "Open parent directory" },
      { "<leader>-", function() require("oil").toggle_float() end, desc = "Toggle Oil float" },
    },
    after = function()
      require("oil").setup({
        default_file_explorer = true,
        keymaps = {
          ["g?"] = { "actions.show_help", mode = "n" },
        },
        float = {
          padding = 4,
          max_width = 110,
          max_height = 40,
          border = "rounded",
          get_win_title = nil,
          preview_split = "auto",
          override = function(conf)
            return conf
          end,
        },
      })
    end,
  },
}
