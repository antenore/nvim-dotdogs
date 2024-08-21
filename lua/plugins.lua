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
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  -- Core plugins
  { 'lewis6991/impatient.nvim' },
  { 'nvim-lua/popup.nvim' },
  { 'nvim-lua/plenary.nvim' },

  -- UI enhancements
  {
    'kyazdani42/nvim-web-devicons',
    config = function() require("nvim-web-devicons").setup() end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function() require('config.lualine') end,
  },
  {
    'goolord/alpha-nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function() require('config.alpha') end,
  },

  -- Syntax and language support
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function() require('config.treesitter') end,
  },
  {
    'nathom/filetype.nvim',
    config = function()
      require("filetype").setup {
        overrides = {
          extensions = {
            tf = "terraform",
            tfvars = "terraform",
            tfstate = "json",
          },
          function_extensions = {
              sh = function()
                  vim.cmd("runtime! syntax/sh.vim")
                  return "sh"
              end,
          },
          complex = {
              [".bashrc"] = "sh",
              ["*.bash*"] = "sh",
              ["*.ksh*"] = "sh",
              ["*.profile"] = "sh",
              [".zprofile"] = "zsh",
              [".zlogin"] = "zsh",
              [".zlogout"] = "zsh",
              ["*.zsh*"] = "zsh",
              [".kshrc"] = "sh",
              ["*.ksh*"] = "sh",
              [".profile"] = "sh",
              ["PKGBUILD"] = "sh",
          },
        },
      }
    end,
  },

  -- LSP and completion
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'tamago324/nlsp-settings.nvim',
      'folke/lsp-colors.nvim',
      'nvim-lua/lsp_extensions.nvim',
    },
    config = function() require('config.lsp') end,
  },
  { 'ray-x/lsp_signature.nvim' },
  { 'p00f/clangd_extensions.nvim' },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc', 'hrsh7th/cmp-nvim-lua', 'hrsh7th/cmp-look',
      'hrsh7th/cmp-cmdline', 'ray-x/cmp-treesitter', 'f3fora/cmp-spell',
      'hrsh7th/cmp-emoji', 'saadparwaiz1/cmp_luasnip',
      'quangnguyen30192/cmp-nvim-tags', 'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function() require('config.cmp').setup() end,
  },

  -- Snippets
  { 'rafamadriz/friendly-snippets' },
  {
    'L3MON4D3/LuaSnip',
    dependencies = { 'rafamadriz/friendly-snippets' },
    config = function() require('config.luasnip') end,
  },

  -- File navigation and search
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('config.telescope') end,
  },
  { 'nvim-telescope/telescope-ui-select.nvim' },
  { 'nvim-telescope/telescope-symbols.nvim' },
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function() require('config.nvim-tree') end,
  },

  -- Git integration
  {
    'TimUntersberger/neogit',
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' }
  },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require("gitsigns").setup() end
  },

  -- Editing support
  { 'windwp/nvim-autopairs' },
  { 'chrisbra/csv.vim' },
  {
    'ludovicchabant/vim-gutentags',
    config = function() require('config.gutentags') end,
  },
  {
    'liuchengxu/vista.vim',
    config = function()
      vim.g.vista_default_executive = "nvim_lsp"
      vim.keymap.set("n", "<F8>", ":Vista!!<CR>", { silent = true })
    end,
  },
  {
    'junegunn/vim-easy-align',
    config = function()
      vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")
      vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
      vim.keymap.set("v", "<Leader>\\", ":EasyAlign*<Bar><Enter>")
    end,
  },
  {
    'kylechui/nvim-surround',
    version = "*",
    config = function() require("nvim-surround").setup{} end,
  },

  -- Language specific
  { 'cuducos/yaml.nvim' },
  { 'ixru/nvim-markdown', config = function() require('config.nvim-markdown').setup() end },
  { 'lervag/vimtex' },
  { 'editorconfig/editorconfig-vim' },
  { 'elzr/vim-json' },
  { 'mrk21/yaml-vim' },
  { 'vim-ruby/vim-ruby' },

  -- Colorscheme and visual enhancements
  { 'rktjmp/lush.nvim' },
   {
    'mcchrish/zenbones.nvim',
    dependencies = { 'rktjmp/lush.nvim' },
    config = function()
      vim.g.zenbones_darkness = "warm"
      vim.g.zenbones_lightness = "dim"
      vim.opt.termguicolors = true
      vim.opt.background = "dark"
      vim.cmd('colorscheme tokyobones')
    end
  },
  {
    'norcalli/nvim-colorizer.lua',
    config = function() require('config.nvim-colorizer') end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function() require('config.indent-blanklines') end,
  },

  -- Misc utilities
  { 'neomake/neomake', cmd = 'Neomake' },
  {
    'jbyuki/venn.nvim',
    config = function() require('config.venn') end,
  },
  { 'tmux-plugins/vim-tmux' },
  { 'ryanoasis/vim-devicons' },
  { 'PProvost/vim-ps1' },
  {
    "cappyzawa/trim.nvim",
    config = function()
      require("trim").setup{
        patterns = {
          [[%s/\(\n\n\)\n\+/\1/]],
        },
        trim_on_write = false,
      }
    end
  },
  --{ vim.fn.expand("$HOME/software/myvim/plugins/mdview.nvim") },

  -- Formerly null-ls, now none-ls
  {
    'nvimtools/none-ls.nvim',
    config = function() require('config.none-ls') end,
  },
})

-- Additional configurations
require('config.neomake')
require('config.vimtex')