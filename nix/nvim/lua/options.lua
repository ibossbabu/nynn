--vim.wo.number = true
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.wo.signcolumn = 'yes'
--tabs & indentations
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.backspace = "indent,eol,start"
vim.opt.autoindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.cursorline = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true      -- True color support
vim.opt.clipboard = 'unnamedplus' -- Sync with system clipboard
vim.opt.swapfile = false          -- Don't create swap files
vim.opt.backup = false            -- Don't create backup files
vim.cmd [[autocmd VimEnter * clearjumps]]
vim.opt.viminfo:remove('j')       -- Prevent Neovim from saving jumplist when exiting
--FOR WINDOWS
--vim.opt.shell = "powershell.exe"
vim.cmd [[
  " augroup ForceBlackBackground
  "   autocmd!
  "   autocmd ColorScheme * highlight Normal guibg=#000000 ctermbg=NONE
  " augroup END
  " set background=dark
  " colorscheme default
  " highlight Normal guibg=#000000 ctermbg=NONE
]]
