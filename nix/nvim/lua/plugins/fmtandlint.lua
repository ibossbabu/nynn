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
    -- Haskell ==>
    ft("haskell"):fmt({
      cmd = 'ormolu',
      args = { '--color', 'never', '--stdin-input-file' },
      stdin = true,
      fname = true,
    }):lint({
      cmd = 'hlint',
      args = { '--json', '--no-exit-code' },
      fname = true,
      parse = function(result, bufnr)
        local diags = {}
        result = result ~= '' and vim.json.decode(result) or {}
        for _, d in ipairs(result) do
          local severity = d.severity:lower() == 'suggestion' and lint.severities.info
              or d.severity:lower() == 'warning' and lint.severities.warning
              or lint.severities.error
          table.insert(
            diags,
            lint.diag_fmt(
              bufnr,
              d.startLine > 0 and d.startLine - 1 or 0,
              d.startLine > 0 and d.startColumn - 1 or 0,
              d.hint .. (d.to ~= vim.NIL and (': ' .. d.to) or ''),
              severity,
              'hlint'
            )
          )
        end
        return diags
      end,
    })
    -- Rust ==>
    ft("rust"):fmt({
      cmd = 'rustfmt',
      args = { '--emit', 'stdout' },
      stdin = true,
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
