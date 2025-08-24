return {
  {
    "luasnip",
    event = "InsertEnter",
    after = function() require("luasnip.loaders.from_snipmate").lazy_load({ path = "./snippets" }) end,
  },
  {
    "blink.cmp",
    event = "InsertEnter",
    after = function()
      require("blink.cmp").setup({
        keymap = {
          preset = 'default',
          ["<C-e>"] = { "show", "show_documentation", "hide_documentation" },
        },
        completion = {
          keyword = { range = 'full' },
          accept = { auto_brackets = { enabled = false }, },
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        snippets = {
          preset = "luasnip",
        },
      })
    end,
  }
}
