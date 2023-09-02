
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)



require("lazy").setup({
    'EdenEast/nightfox.nvim',
    'chriskempson/base16-vim',
    'nvim-treesitter/nvim-treesitter',

    {
        'nvim-telescope/telescope.nvim', tag = '0.1.2',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-project.nvim',
            'nvim-telescope/telescope-file-browser.nvim',
            'nvim-telescope/telescope-github.nvim',
        }
    },

    {
        'pwntester/octo.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
            'kyazdani42/nvim-web-devicons',
        }
    },
    
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'kyazdani42/nvim-web-devicons', opt = true }
    },

    {
        'SmiteshP/nvim-gps',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        config = function()
            require("nvim-gps").setup()
        end,
    },
    
    'neovim/nvim-lspconfig',
    
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip'
        }
    },
    
    'lewis6991/gitsigns.nvim',
    'lukas-reineke/lsp-format.nvim',
    'akinsho/toggleterm.nvim',
    {
        'folke/noice.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim',
            'rcarriga/nvim-notify'
        }
    },
})


require('plugins.tree-sitter')
require('plugins.telescope')
require('plugins.octo')
require('plugins.lualine')
require('plugins.lspconfig')
require('plugins.cmp')
require('plugins.gitsigns')
require('plugins.toggleterm')
require('plugins.noice')
