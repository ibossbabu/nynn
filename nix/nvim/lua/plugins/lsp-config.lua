return {
  {
    "nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    before = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(args)
          local c = vim.lsp.get_client_by_id(args.data.client_id)
          if not c then return end
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = args.buf, desc = desc })
          end
          map("<leader>K", vim.lsp.buf.hover, "Hover")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
          map("<leader>gd", vim.lsp.buf.definition, "Definition")
          map("<leader>gr", vim.lsp.buf.references, "References")
        end,
      })
      -- Function to jump with virtual line diagnostics
      ---@param jumpCount number
      local function jumpWithVirtLineDiags(jumpCount)
        pcall(vim.api.nvim_del_augroup_by_name, "jumpWithVirtLineDiags") -- prevent autocmd for repeated jumps
        vim.diagnostic.jump { count = jumpCount }
        local initialVirtTextConf = vim.diagnostic.config().virtual_text
        vim.diagnostic.config { virtual_text = false, virtual_lines = { current_line = true }, }
        vim.defer_fn(function() -- deferred to not trigger by jump itself
          vim.api.nvim_create_autocmd("CursorMoved", {
            desc = "User(once): Reset diagnostics virtual lines",
            once = true,
            group = vim.api.nvim_create_augroup("jumpWithVirtLineDiags", {}),
            callback = function()
              vim.diagnostic.config { virtual_lines = false, virtual_text = initialVirtTextConf }
            end,
          })
        end, 1)
      end
      vim.keymap.set("n", "]d", function() jumpWithVirtLineDiags(1) end, { desc = "󰒕 Next diagnostic" })
      vim.keymap.set("n", "[d", function() jumpWithVirtLineDiags(-1) end, { desc = "󰒕 Prev diagnostic" })
    end,
    after = function()
      local servers = {
        ruby_lsp = true,
        nixd = true,
        hls = true,
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = true,
              check = {
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
              },
              cargo = {
                allFeatures = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                version = 'LuaJIT',
              },
              diagnostics = {
                globals = { 'vim', 'require' },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
              },
            }
          }
        }
      }
      for server, config in pairs(servers) do
        if config == true then
          require("lspconfig")[server].setup({})
        else
          require("lspconfig")[server].setup(config)
        end
      end
    end,
  }
}
