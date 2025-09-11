return {
  "guard.nvim",
  before = function()
    vim.g.guard_config = {
      fmt_on_save = true,
      lsp_as_default_formatter = true,
      save_on_fmt = true,
      auto_lint = true,
      lint_interval = 1000,
      refresh_diagnostic = true,
    }
  end,
  after = function()
    local ft = require("guard.filetype")
    local lint = require("guard.lint")
    -- Nix ==>
    ft("nix"):fmt({
      cmd = 'alejandra',
      args = { '--quiet' },
      stdin = true,
      ignore_error = true,
    })
    -- C ==>
    ft('c'):fmt({
      cmd = "clang-format",
      args = { "--style={IndentWidth: 4}" },
      stdin = true,
    }):lint({
      cmd = "clang-tidy",
      args = { "--quiet" },
      fname = true,
      parse = lint.from_regex({
        source = "clang-tidy",
        regex = ":(%d+):(%d+):%s+(%w+):%s+(.-)%s+%[(.-)%]",
        groups = { "lnum", "col", "severity", "message", "code" },
        severities = {
          information = lint.severities.info,
          hint = lint.severities.info,
          note = lint.severities.style,
        },
      }),
    })
    -- Ruby ==>
    ft("ruby"):fmt({
      cmd = 'bundle',
      args = { 'exec', 'rubocop', '-A', '-f', 'quiet', '--stderr', '--stdin' },
      stdin = true,
      fname = true,
    }):lint({
      cmd = 'bundle',
      args = { 'exec', 'rubocop', '--format', 'json', '--force-exclusion', '--stdin' },
      stdin = true,
      env = { BUNDLE_GEMFILE = vim.fn.getcwd() .. '/Gemfile' },
      parse = lint.from_json({
        get_diagnostics = function(...)
          return vim.json.decode(...).files[1].offenses
        end,
        attributes = {
          lnum = 'location.line',
          col = 'location.column',
          code = 'cop_name',
        },
        severities = {
          convention = lint.severities.info,
          refactor = lint.severities.style,
          fatal = lint.severities.error,
        },
      }),
    })
  end,
  vim.keymap.set({ "n", "v" }, "<leader>gf", "<cmd>Guard fmt<cr>",
    { noremap = true, silent = true, desc = "Guard format" })
}
