require "utils"

local fn = vim.fn

--- Check if a file or directory exists in this path
local function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

--- Check if a directory exists in this path
local function isdir(path)
   -- "/" works on both Unix and Windows
   return exists(path.."/")
end


-- Automatically install packer
local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system {
		"git",
		"clone",
		"--depth",
		"1",
		'https://github.com/wbthomason/packer.nvim',
		install_path,
	}
	print "Installing packer close and reopen Neovim..."
	vim.cmd [[packadd packer.nvim]]
end

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init {
	display = {
		open_fn = function()
			return require("packer.util").float { border = "rounded" }
		end,
		working_sym = '', -- The symbol for a plugin being installed/updated
		error_sym = '✗',   -- The symbol for a plugin with an error in installation/updating
		done_sym = '✓',    -- The symbol for a plugin which has completed installation/updating
		removed_sym = '-', -- The symbol for an unused plugin which was removed
		moved_sym = '→',   -- The symbol for a plugin which was moved (e.g. from opt to start)
		header_sym = '━',  -- The symbol for the header line in packer's display
	}
}

-- Install your plugins here
local use = require('packer').use
require('packer').startup(function()
	use ({ 'wbthomason/packer.nvim' }) -- Have packer manage itself
	use ({ 'lewis6991/impatient.nvim' })
	use ({
		"nathom/filetype.nvim",
		config = function()
			require("filetype").setup {
				overrides = {
					extensions = {
						tf = "terraform",
						tfvars = "terraform",
						tfstate = "json",
					},
				},
			}
		end,
	})
	use ({ 'nvim-lua/popup.nvim' })    -- An implementation of the Popup API from vim in Neovim
	use ({ 'nvim-lua/plenary.nvim' })  -- Useful lua functions used by lots of plugins
	use ({ 'windwp/nvim-autopairs' })  -- Autopairs, integrates with both cmp and treesitter
	use ({ 'rktjmp/lush.nvim' })       -- color scheme aid plugin
	use ({
		'kyazdani42/nvim-web-devicons',
		config = function()
			require("nvim-web-devicons").setup()
		end
	})
	use ({
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons', opt = true },
		config = [[require('config.lualine')]],
	})
	use ({
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate',
		config = [[require('config.treesitter')]],
	})
	use ({
		'jose-elias-alvarez/null-ls.nvim',
		config = [[require('config.null-ls')]],
	})
	-- LSP
	use ({
		'neovim/nvim-lspconfig',
		requires = {
			-- 'williamboman/nvim-lsp-installer',
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'tamago324/nlsp-settings.nvim',
			'folke/lsp-colors.nvim',
			'nvim-lua/lsp_extensions.nvim',
		},
		config = [[require('config.lsp')]],
	})

	-- https://github.com/ray-x/lsp_signature.nvim
	use 'ray-x/lsp_signature.nvim'

	-- nvim-cmp
	use ({
		'hrsh7th/cmp-cmdline',
		commit = "e1ba818534a357b77494597469c85030c7233c16",
	})

	use ({
		'hrsh7th/nvim-cmp',
		requires = {
			'quangnguyen30192/cmp-nvim-tags',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-nvim-lsp-signature-help',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-calc',
			'hrsh7th/cmp-nvim-lua',
			'hrsh7th/cmp-look',
			--'hrsh7th/cmp-cmdline',
			'ray-x/cmp-treesitter',
			'f3fora/cmp-spell',
			'hrsh7th/cmp-emoji',
		},
		config = [[require('config.cmp').setup()]],
	})
	use ({ 'rafamadriz/friendly-snippets' })
	use ({
		'L3MON4D3/LuaSnip',
		requires = { 'rafamadriz/friendly-snippets' },
		config = [[require('config.luasnip')]],
	})
	use 'saadparwaiz1/cmp_luasnip'

	use ({ 'p00f/clangd_extensions.nvim' })
	use ({ 'cuducos/yaml.nvim' })

	-- FZF setup
	-- use ({
		-- 'junegunn/fzf',
		-- dir = '~/.fzf',
		-- run = { './install --all' },
	-- })
	-- use ({
		-- 'junegunn/fzf.vim',
		-- -- Adding the config here and not requiring at the end, break telescope-ui-select
		-- config = [[require('config.fzf')]],
	-- })

	-- Telescope https://github.com/nvim-telescope/telescope.nvim
	use ({
		'nvim-telescope/telescope.nvim',
		requires = {
			{'nvim-lua/plenary.nvim'},
		},
		config = [[require('config.telescope')]],
	})
	use ({ 'nvim-telescope/telescope-ui-select.nvim' })
	use ({ 'nvim-telescope/telescope-symbols.nvim' })

	-- Easily comment stuff
	-- use ({
	-- 	'numToStr/Comment.nvim',
	-- 	config = function() require("Comment").setup() end
	-- })
	use ({ 'chrisbra/csv.vim' })
	use ({
		'ludovicchabant/vim-gutentags',
		config = [[require('config.gutentags')]],
	})
	use ({
		'liuchengxu/vista.vim',
		config = function()
			vim.g.vista_default_executive = "nvim_lsp"
			nnoremap { "<F8>", ":Vista!!<CR>" }
		end,
	})
	use ({
		'junegunn/vim-easy-align',
		config = function()
			-- Start interactive EasyAlign for a motion/text object (e.g. gaip)
			nmap { "ga", "<Plug>(EasyAlign)" }
			-- Start interactive EasyAlign in visual mode (e.g. vipga)
			xmap { "ga", "<Plug>(EasyAlign)" }
			-- Align GitHub-flavored Markdown tables
			-- https://thoughtbot.com/blog/align-github-flavored-markdown-tables-in-vim
			vmap { "<Leader><Bslash>", ":EasyAlign*<Bar><Enter>" }
		end,
	})
	-- use ({ 'mboughaba/i3config.vim' })
	use ({
		'ixru/nvim-markdown',
		config = [[require('config.nvim-markdown').setup()]],
	})

	use ({
		'kyazdani42/nvim-tree.lua',
		requires = { 'kyazdani42/nvim-web-devicons' },
		config = [[require('config.nvim-tree')]],
	})

	-- Git
	use ({
		'TimUntersberger/neogit',
		requires = {
			'nvim-lua/plenary.nvim',
			'sindrets/diffview.nvim'
		}
	})
	use ({
		'lewis6991/gitsigns.nvim',
		requires = { 'nvim-lua/plenary.nvim' },
		config = function() require("gitsigns").setup() end
	})
	--[[
	https://github.com/norcalli/nvim-colorizer.lua
	Given a text like #800080 it will show the real color
	It supports the following code and you can write your own parser
	  DEFAULT_OPTIONS = {
	    RGB      = true;         -- #RGB hex codes
	    RRGGBB   = true;         -- #RRGGBB hex codes
	    names    = true;         -- "Name" codes like Blue
	    RRGGBBAA = false;        -- #RRGGBBAA hex codes
	    rgb_fn   = false;        -- CSS rgb() and rgba() functions
	    hsl_fn   = false;        -- CSS hsl() and hsla() functions
	    css      = false;        -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
	    css_fn   = false;        -- Enable all CSS *functions*: rgb_fn, hsl_fn
	    -- Available modes: foreground, background
	    mode     = 'background'; -- Set the display mode.
      }
	With files that are not automatically detected you use ColorizerAttachToBuffer
	--]]
	use ({
		'norcalli/nvim-colorizer.lua',
		config = [[require('config.nvim-colorizer')]],
	})
	-- https://github.com/glepnir/indent-guides.nvim
	-- use ({
	-- 	'glepnir/indent-guides.nvim',
	-- 	config = [[require('config.indent-guides')]],
	-- })
	use ({
		"lukas-reineke/indent-blankline.nvim",
		config = [[require('config.indent-blanklines')]],
	})
	use ({
		"kylechui/nvim-surround",
		tag = "*", -- Use for stability; omit to use `main` branch for the latest features
		config = function()
			-- Otherwise it will compalin that is missing the surround options
			---@diagnostic disable-next-line
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
		-- event = "BufEnter",
	})
	use ({ 'tmux-plugins/vim-tmux' })
	use ({ 'ryanoasis/vim-devicons' })
	use ({ 'PProvost/vim-ps1' })
	if isdir(vim.fn.expand("$HOME/software/myvim/plugins/mdview.nvim")) then
		use ({
			vim.fn.expand("$HOME/software/myvim/plugins/mdview.nvim"),
		})
	end
	-- if isdir(vim.fn.expand("$HOME/software/myvim/plugins/jaflpl.nvim")) then
	--   use ({ vim.fn.expand("$HOME/software/myvim/plugins/jaflpl.nvim") })
	-- end
	use ({
		'mcchrish/zenbones.nvim',
		requires = { 'rktjmp/lush.nvim', opt = true },
		config = [[
						vim.g.zenbones_darkness = "warm"
						vim.g.zenbones_lightness = "dim"
						vim.opt.termguicolors = true
						vim.opt.background = "dark"
						vim.cmd('colorscheme tokyobones')
		]]
	})
	-- iusei ({ 'ewilazarus/preto' })
	-- use ({
	-- 	'luochen1990/rainbow',
	-- 	config = [[require('config.rainbow')]],
	-- })
	-- Not maintained anymore use ({ 'p00f/nvim-ts-rainbow' })
	use ({ 'lervag/vimtex' })
	use ({ 'neomake/neomake', cmd = 'Neomake' })
	use ({
		'jbyuki/venn.nvim',
		config = [[require('config.venn')]],
	})
	use ({
		'goolord/alpha-nvim',
		requires = { 'kyazdani42/nvim-web-devicons' },
		config = [[require('config.alpha')]],
	})

	-- terraform
	use ({'hashivim/vim-terraform' })
	-- Puppet requirements
	use ({'editorconfig/editorconfig-vim' }) -- For filetype management.
	use ({'elzr/vim-json' })
	use ({'mrk21/yaml-vim' })
	use ({'vim-ruby/vim-ruby' })
	use ({'rodjek/vim-puppet' })
	use ({ 'puppetlabs/puppet-syntax-vim' })
	use ({
		"cappyzawa/trim.nvim",
		config = function()
			require("trim").setup({
				-- if you want to ignore markdown file.
				-- you can specify filetypes.
				-- ft_blocklist = {"markdown"},

				-- if you want to remove multiple blank lines
				patterns = {
					[[%s/\(\n\n\)\n\+/\1/]],   -- replace multiple blank lines with a single line
				},

				-- if you want to disable trim on write by default
				trim_on_write = false,
			})
		end
	})

	-- Automatically set up your configuration after cloning packer.nvim
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)

-- require('config.fzf')
require('config.neomake')
require('config.vimtex')
