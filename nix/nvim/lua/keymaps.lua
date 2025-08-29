vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- vim.keymap.set("i", "jk", "<ESC>", {})
vim.keymap.set("n", "<leader>cl", ":nohl<CR>", {})
vim.keymap.set("n", "<leader>cj", ":clearjumps<CR>", {})

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

local opts = { noremap = true, silent = true }

vim.keymap.set("n", "x", '"_x', opts)
-- Vertical scroll and center
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)
-- Quickfix
vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>", opts)
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>", opts)
-- Find and center
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)
-- Split
vim.keymap.set('n', '<C-w>s', ':vsplit<CR>', opts)
vim.keymap.set('n', '<C-w>v', ':split<CR>', opts)
-- Jump
vim.keymap.set("n", "<C-i>", "<C-i>zz", opts)
vim.keymap.set("n", "<C-o>", "<C-o>zz", opts)
-- Go to
vim.keymap.set("n", "g;", "g;zz", opts)
vim.keymap.set("n", "g,", "g,zz", opts)

--TERM
vim.keymap.set('t', '<C-q>', '<C-\\><C-n>', opts)

function OpenTerm()
  vim.cmd('10split')
  vim.cmd('lcd %:p:h')
  vim.cmd('term')
  vim.api.nvim_feedkeys('i', 'n', false)
end

vim.api.nvim_set_keymap('n', '<Leader>th', ':lua OpenTerm()<CR>', opts)
