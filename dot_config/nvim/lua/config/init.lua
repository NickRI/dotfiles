local set = vim.opt

set.autoindent = true
set.expandtab = false
set.smarttab = true
set.shiftwidth = 4
set.tabstop = 4

set.hlsearch = true
set.incsearch = true
set.ignorecase = true
set.smartcase = true

set.splitbelow = true
set.splitright = true
set.wrap = false
set.scrolloff = 5
set.fileencoding = 'utf-8'
set.termguicolors = true

set.relativenumber = true
set.cursorline = true
set.number = true 

set.hidden = true

vim.opt.completeopt={"menu", "menuone", "noselect"}

-- for neovide
if vim.fn['g:neovide'] then
	vim.g.neovide_transparency = 0.8
	vim.g.neovide_remember_window_size = true
end
