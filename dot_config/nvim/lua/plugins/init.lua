require('plugins.tree-sitter')
require('plugins.telescope')
require('plugins.octo')
require('plugins.lualine')
require('plugins.lspconfig')
require('plugins.cmp')
require('plugins.gitsigns')
require('plugins.toggleterm')
--require('plugins.noice')


return require('packer').startup(function()
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use 'EdenEast/nightfox.nvim'

	use 'chriskempson/base16-vim'
    
	use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        requires = { 
            {'nvim-lua/plenary.nvim'},
            {'nvim-telescope/telescope-project.nvim'},
            {'nvim-telescope/telescope-file-browser.nvim'},
            {'nvim-telescope/telescope-github.nvim'},
        }
    }

    use {
        'pwntester/octo.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
            'kyazdani42/nvim-web-devicons',
        }
    }

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    use {
        'SmiteshP/nvim-gps',
        requires = { 'nvim-treesitter/nvim-treesitter' },
        config = function()
            require("nvim-gps").setup()
        end,
    }

    use 'neovim/nvim-lspconfig'

    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip'
        }
    }

    use {
        'lewis6991/gitsigns.nvim',
        -- tag = 'release' -- To use the latest release
    }

	use {
		'lukas-reineke/lsp-format.nvim'
	}

	use {
		'akinsho/toggleterm.nvim'
	}

	use {
		'folke/noice.nvim',
		requires = {
			'MunifTanjim/nui.nvim',
			'rcarriga/nvim-notify'
		}
	}
end)
