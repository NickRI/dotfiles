local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

vim.g.mapleader = ' '

map('n', '<c-s>', ':w<CR>', {})
map('i', '<Esc>', '<Esc>:w<CR>', opts)
map('i', '<c-s>', '<Esc>:w<CR>a', {})


map('n', '<c-j>', '<c-w>j', opts)
map('n', '<c-h>', '<c-w>h', opts)
map('n', '<c-k>', '<c-w>k', opts)
map('n', '<c-l>', '<c-w>l', opts)


