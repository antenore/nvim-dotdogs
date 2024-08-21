local lspconfig = require('lspconfig')
local util = require('lspconfig/util')
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local cmp_nvim_lsp = require('cmp_nvim_lsp')

-- Set up Mason
mason.setup {
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        }
    }
}

-- Set up Mason-LSPconfig
mason_lspconfig.setup {
    ensure_installed = {
        'lua_ls', 'cmake', 'jsonls', 'solargraph', 'vimls', 'bashls',
        'prosemd_lsp', 'jedi_language_server', 'yamlls', 'html'
    },
    automatic_installation = true,
}

-- Mappings
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

-- On-attach function
local on_attach = function(_, bufnr)
    local bufopts = { buffer=bufnr, silent=true }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- Capabilities
local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Set up LSP servers
local servers = {
    'lua_ls', 'cmake', 'jsonls', 'solargraph', 'vimls', 'bashls',
    'prosemd_lsp', 'jedi_language_server', 'yamlls', 'html'
}

for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

-- Special configurations
lspconfig.clangd.setup{ capabilities = capabilities }

require("clangd_extensions").setup{ capabilities = capabilities }

lspconfig.lua_ls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = { globals = {'vim'} },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
        },
    },
}

lspconfig.prosemd_lsp.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { vim.fn.expand("$HOME/.cargo/bin/prosemd-lsp"), "--stdio" },
    filetypes = { "markdown" },
    root_dir = util.find_git_ancestor,
}

lspconfig.pyright.setup { on_attach = on_attach }

lspconfig.terraformls.setup{
    on_attach = on_attach,
    root_dir = util.find_git_ancestor,
    capabilities = capabilities
}

-- Autoformat Terraform files
vim.api.nvim_create_autocmd({"BufWritePre"}, {
    pattern = {"*.tf", "*.tfvars"},
    callback = function() vim.lsp.buf.format() end,
})

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        update_in_insert = true,
    }
)