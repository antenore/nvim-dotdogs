require "utils"

local util = require 'lspconfig/util'
-- {{{ ===== lsp-colors.nvim ====================================================
require("lsp-colors").setup({})
-- }}}
-- -- {{{ ===== nvim-lsp-installer =================================================
-- require("nvim-lsp-installer").setup({
--     automatic_installation = true,
--     ui = {
--         icons = {
--             server_installed = "✓",
--             server_pending = "➜",
--             server_uninstalled = "✗",
--         }
--     }
-- })

require("mason").setup {
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		}
	}
}
require("mason-lspconfig").setup {
	ensure_installed = {
		'lua_ls',
		'cmake',
		'jsonls',
		'solargraph',
		'eslint',
		'tsserver',
		'vimls',
		'bashls',
		'marksman',
		'prosemd_lsp',
		'jedi_language_server',
		-- 'puppet',
		'terraformls',
		'yamlls',
		'html',
	},
	automatic_installation = true,
}

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
nnoremap {'<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', silent=true }
nnoremap {'[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', silent=true }
nnoremap {']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', silent=true }
nnoremap {'<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', silent=true }

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	-- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopt = { buffer=bufnr, silent=true }
	nnoremap { 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>',bufopt }
	nnoremap { 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>',bufopt }
	nnoremap { 'K', '<cmd>lua vim.lsp.buf.hover()<CR>',bufopt }
	nnoremap { 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>',bufopt }
	nnoremap { '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>',bufopt }
	nnoremap { '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',bufopt }
	nnoremap { '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',bufopt }
	nnoremap { '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',bufopt }
	nnoremap { '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>',bufopt }
	nnoremap { '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>',bufopt }
	nnoremap { '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',bufopt }
	nnoremap { 'gr', '<cmd>lua vim.lsp.buf.references()<CR>',bufopt }
	nnoremap { '<leader>f','<cmd>lua vim.lsp.buf.formatting()<CR>',bufopt }
end

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local lspconfig = require('lspconfig')

local servers = { 'cmake', 'jsonls', 'solargraph', 'eslint', 'tsserver', 'vimls', 'bashls', 'marksman' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig.clangd.setup{
  -- on_attach = on_attach,
  capabilities = capabilities
}

require("clangd_extensions").setup{
  -- on_attach = on_attach,
  capabilities = capabilities
}

-- Lua
lspconfig.lua_ls.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
			--[[
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT',
				path = vim.split(package.path, ";")
			},
			]]--
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim' },
        },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
				--library = {[vim.fn.expand("$VIMRUNTIME/lua")] = true, [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true}
        },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
        },
      },
    },
}

lspconfig.prosemd_lsp.setup{
  on_attach = on_attach,
  capabilities = capabilities,
    cmd = { vim.fn.expand("$HOME/.cargo/bin/prosemd-lsp"), "--stdio" },
    filetypes = { "markdown" },
    root_dir = function(fname)
      return util.find_git_ancestor(fname) or vim.fn.getcwd()
    end,
    settings = {},
}

--[[
if vim.fn.has("win64") == 1 then
	lspconfig.puppet.setup {
		on_attach = on_attach,
		capabilities = capabilities,
		-- DEBUG add '--stdio', '--debug=/tmp/puppet-lsp-debug.log'
		command = { "ruby" },
		args = { vim.fn.expand("$HOME\\software\\puppet-editor-services\\puppet-languageserver"), '--stdio' },
		filetypes = { 'puppet' },
		root_dir = function(fname)
			local root_files = {
				"manifests",
				"metadata.json",
				".git"
			}
			return util.root_pattern(unpack(root_files))(fname) or util.path.dirname(fname)
		end,
	}
else
	lspconfig.puppet.setup {
		on_attach = on_attach,
		capabilities = capabilities,
		-- DEBUG add '--stdio', '--debug=/tmp/puppet-lsp-debug.log'
		cmd = { vim.fn.expand("$HOME/software/puppet-editor-services/puppet-languageserver"), '--stdio' },
		filetypes = { 'puppet' },
		root_dir = function(fname)
			local root_files = {
				"manifests",
				"metadata.json",
				".git"
			}
			return util.root_pattern(unpack(root_files))(fname) or util.path.dirname(fname)
		end,
	}
end
]]--

-- Python
--lspconfig.jedi_language_server.setup {
--	on_attach = on_attach
--}
lspconfig.pyright.setup {
	on_attach = on_attach
}
--lspconfig.ruff_lsp.setup {
--  on_attach = on_attach,
--  init_options = {
--    settings = {
--      -- Any extra CLI arguments for `ruff` go here.
--      args = {},
--    }
--  }
--}
-- terraform
lspconfig.terraformls.setup{
	--cmd = { "terraform-ls", "serve" },
  on_attach = on_attach,
	root_dir = function(fname)
		return util.find_git_ancestor(fname) or vim.fn.getcwd()
	end,
  capabilities = capabilities
}
local buf_group = vim.api.nvim_create_augroup(
	"BufGroup",
	{ clear = true }
)
vim.api.nvim_create_autocmd({"BufWritePre"}, {
	group = buf_group,
  pattern = {"*.tf", "*.tfvars"},
  callback = function ()
		vim.lsp.buf.format()
	end
})

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
