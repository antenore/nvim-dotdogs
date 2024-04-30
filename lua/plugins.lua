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

local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.runtimepath:prepend(lazypath)





require("lazy").setup({
	{
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
	},
	{ 'nvim-lua/popup.nvim' },    -- An implementation of the Popup API from vim in Neovim
	{ 'nvim-lua/plenary.nvim' },  -- Useful lua functions used by lots of plugins
	{ 'windwp/nvim-autopairs' },  -- Autopairs, integrates with both cmp and treesitter
	{ 'rktjmp/lush.nvim' },       -- color scheme aid plugin
	{
		'kyazdani42/nvim-web-devicons',
		config = function()
			require("nvim-web-devicons").setup()
		end
	},
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'kyazdani42/nvim-web-devicons', opt = true },
		config = function()
			require('config.lualine')
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate',
		config = function()
			require('config.treesitter')
		end,
	},
	{
		'jose-elias-alvarez/null-ls.nvim',
		config = function()
			require('config.null-ls')
		end,
	},
	-- LSP
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			-- 'williamboman/nvim-lsp-installer',
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'tamago324/nlsp-settings.nvim',
			'folke/lsp-colors.nvim',
			'nvim-lua/lsp_extensions.nvim',
		},
		config = function()
			require('config.lsp')
		end,
	},

	-- https://github.com/ray-x/lsp_signature.nvim
	{'ray-x/lsp_signature.nvim'},

	-- nvim-cmp
	{
		'hrsh7th/cmp-cmdline',
		commit = "e1ba818534a357b77494597469c85030c7233c16",
	},

	{
		'hrsh7th/nvim-cmp',
		dependencies = {
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
		config = function()
			require('config.cmp').setup()
		end,
	},
	{ 'rafamadriz/friendly-snippets' },
	{
		'L3MON4D3/LuaSnip',
		dependencies = { 'rafamadriz/friendly-snippets' },
		config = function()
			require('config.luasnip')
		end,
	},
	{'saadparwaiz1/cmp_luasnip'},

	{ 'p00f/clangd_extensions.nvim' },
	{ 'cuducos/yaml.nvim' },

	-- FZF setup
	-- {
	-- 'junegunn/fzf',
	-- dir = '~/.fzf',
	-- run = { './install --all' },
	-- },
	-- {
	-- 'junegunn/fzf.vim',
	-- -- Adding the config here and not requiring at the end, break telescope-ui-select
	-- config = function()
	--require('config.fzf')
	--end,
	-- },

	-- Telescope https://github.com/nvim-telescope/telescope.nvim
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			{'nvim-lua/plenary.nvim'},
		},
		config = function()
			require('config.telescope')
		end,
	},
	{ 'nvim-telescope/telescope-ui-select.nvim' },
	{ 'nvim-telescope/telescope-symbols.nvim' },

	-- Easily comment stuff
	-- {
	-- 	'numToStr/Comment.nvim',
	-- 	config = function() require("Comment").setup() end
	-- },
	{ 'chrisbra/csv.vim' },
	{
		'ludovicchabant/vim-gutentags',
		config = function()
			require('config.gutentags')
		end,
	},
	{
		'liuchengxu/vista.vim',
		config = function()
			vim.g.vista_default_executive = "nvim_lsp"
			nnoremap { "<F8>", ":Vista!!<CR>" }
		end,
	},
	{
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
	},
	-- { 'mboughaba/i3config.vim' },
	{
		'ixru/nvim-markdown',
		config = function()
			require('config.nvim-markdown').setup()
		end,
	},

	{
		'kyazdani42/nvim-tree.lua',
		dependencies = { 'kyazdani42/nvim-web-devicons' },
		config = function()
			require('config.nvim-tree')
		end,
	},

	-- Git
	{
		'TimUntersberger/neogit',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'sindrets/diffview.nvim'
		}
	},
	{
		'lewis6991/gitsigns.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function() require("gitsigns").setup() end
	},
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
	{
		'norcalli/nvim-colorizer.lua',
		config = function()
			require('config.nvim-colorizer')
		end,
	},
	-- https://github.com/glepnir/indent-guides.nvim
	-- {
	-- 	'glepnir/indent-guides.nvim',
	-- 	config = function()
	--require('config.indent-guides')
	--end,
	-- },
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require('config.indent-blanklines')
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		config = function()
			-- Otherwise it will compalin that is missing the surround options
			---@diagnostic disable-next-line
			require("nvim-surround").setup{
				-- Configuration here, or leave empty to use defaults
			}
		end,
		-- event = "BufEnter",
	},
	{ 'tmux-plugins/vim-tmux' },
	{ 'ryanoasis/vim-devicons' },
	{ 'PProvost/vim-ps1' },
	-- if isdir(vim.fn.expand("$HOME/software/myvim/plugins/jaflpl.nvim")) then
	--   "$HOME/software/myvim/plugins/jaflpl.nvim") },
	-- end
	{
		'mcchrish/zenbones.nvim',
		dependencies = { 'rktjmp/lush.nvim', opt = true },
		config = function()
			vim.g.zenbones_darkness = "warm"
			vim.g.zenbones_lightness = "dim"
			vim.opt.termguicolors = true
			vim.opt.background = "dark"
			vim.cmd('colorscheme tokyobones')
		end,
	},
	-- { 'ewilazarus/preto' },
	-- {
	-- 	'luochen1990/rainbow',
	-- 	config = function()
	--require('config.rainbow')
	--end,
	-- },
	-- Not maintained anymore { 'p00f/nvim-ts-rainbow' },
	{ 'lervag/vimtex' },
	{ 'neomake/neomake', cmd = 'Neomake' },
	{
		'jbyuki/venn.nvim',
		config = function()
			require('config.venn')
		end,
	},
	{
		'goolord/alpha-nvim',
		dependencies = { 'kyazdani42/nvim-web-devicons' },
		config = function()
			require('config.alpha')
		end,
	},

	-- terraform
	{'hashivim/vim-terraform' },
	-- Puppet requirements
	{'editorconfig/editorconfig-vim' }, -- For filetype management.
	{'elzr/vim-json' },
	{'mrk21/yaml-vim' },
	{'vim-ruby/vim-ruby' },
	{'rodjek/vim-puppet' },
	{ 'puppetlabs/puppet-syntax-vim' },
	{
		"cappyzawa/trim.nvim",
		config = function()
			require("trim").setup{
				-- if you want to ignore markdown file.
				-- you can specify filetypes.
				-- ft_blocklist = {"markdown"},

				-- if you want to remove multiple blank lines
				patterns = {
					[[%s/\(\n\n\)\n\+/\1/]],   -- replace multiple blank lines with a single line
				},

				-- if you want to disable trim on write by default
				trim_on_write = false,
			}
		end
	},
	-- { vim.fn.expand("$HOME/software/myvim/plugins/mdview.nvim") },


})

-- require('config.fzf')
require('config.neomake')
require('config.vimtex')
