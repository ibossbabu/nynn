return {
  "conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "<leader>gf", desc = "Format with conform" },
  },
  after = function(_)
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        nix = { "alejandra" },
        c = { "clangformat" },
        rust = { "rustfmt", lsp_format = "fallback" },
      },
      formatters = {
        clangformat = {
          command = "clangformat",
          prepend_args = { "--enable-outside-detected-project" },
        },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      }
    })

    vim.keymap.set({ "n", "v" }, "<leader>gf", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format with conform" })
  end,
}
