vim.cmd.packadd 'vim-tmux-navigator'

require('lze').load({
  "vim-tmux-navigator",
  keys = {
    { "<c-h>",  "<CMD>TmuxNavigateLeft<CR>" },
    { "<c-j>",  "<CMD>TmuxNavigateDown<CR>" },
    { "<c-k>",  "<CMD>TmuxNavigateUp<CR>" },
    { "<c-l>",  "<CMD>TmuxNavigateRight<CR>" },
    { "<c-\\>", "<CMD>TmuxNavigatePrevious<CR>" },
  },
})
