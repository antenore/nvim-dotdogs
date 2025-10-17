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

-- Configure diagnostics with minimal virtual text
vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    spacing = 4,
    source = false,
    prefix = "●",
    severity = { min = vim.diagnostic.severity.ERROR },  -- Only show errors and warnings, no hints/info
    format = function(diagnostic)
      return string.gsub(diagnostic.message, "\n", " ")  -- Remove line breaks for cleaner display
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.HINT] = "⚑",
      [vim.diagnostic.severity.INFO] = "»",
    },
  },
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- On-attach function (MUST be defined BEFORE mason handlers)
local on_attach = function(client, bufnr)
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

    -- Context-aware document highlighting (disabled)
    -- require('config.context-highlight').enable_lsp_document_highlight(client, bufnr)
end

-- Capabilities (MUST be defined BEFORE mason handlers)
local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Set up Mason-LSPconfig
mason_lspconfig.setup {
    ensure_installed = {
        'lua_ls', 'cmake', 'jsonls', 'solargraph', 'vimls', 'bashls',
        'prosemd_lsp', 'pylsp', 'yamlls', 'html'
    },
    automatic_installation = true,
    -- Handlers for automatic setup
    handlers = {
        -- Default handler for most servers
        function(server_name)
            -- Skip servers with special configurations below
            local skip_servers = { "pylsp", "prosemd_lsp", "terraformls", "clangd" }
            for _, skip in ipairs(skip_servers) do
                if server_name == skip then
                    return
                end
            end

            -- Default setup for all other servers
            lspconfig[server_name].setup {
                on_attach = on_attach,
                capabilities = capabilities,
            }
        end,

        -- Special handler for lua_ls
        ["lua_ls"] = function()
            lspconfig.lua_ls.setup{
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = { version = 'LuaJIT' },
                        diagnostics = { globals = { 'vim' } },
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME,
                                "${3rd}/luv/library"
                            }
                        }
                    }
                }
            }
        end,
    },
}

-- Diagnostic toggle function
local virtual_text_enabled = true
local function toggle_virtual_text()
  virtual_text_enabled = not virtual_text_enabled
  vim.diagnostic.config({
    virtual_text = virtual_text_enabled and {
      enabled = true,
      spacing = 4,
      source = false,
      prefix = "●",
      severity = { min = vim.diagnostic.severity.ERROR },
      format = function(diagnostic)
        return string.gsub(diagnostic.message, "\n", " ")
      end,
    } or false,
  })
  print("Virtual text diagnostics: " .. (virtual_text_enabled and "enabled" or "disabled"))
end

-- Diagnostic mappings
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ direction = -1 }) end, opts)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ direction = 1 }) end, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
vim.keymap.set('n', '<leader>dt', toggle_virtual_text, { noremap = true, silent = true, desc = "Toggle diagnostic virtual text" })
vim.keymap.set('n', '<leader>dd', function() vim.diagnostic.enable(false, { bufnr = 0 }) end, { noremap = true, silent = true, desc = "Disable diagnostics for buffer" })
vim.keymap.set('n', '<leader>de', function() vim.diagnostic.enable(true, { bufnr = 0 }) end, { noremap = true, silent = true, desc = "Enable diagnostics for buffer" })
vim.keymap.set('n', '<leader>lr', function() vim.cmd('LspRestart') end, { noremap = true, silent = true, desc = "Restart LSP" })

-- Special LSP configurations (Mason handlers above set up the rest)
lspconfig.clangd.setup{ 
    on_attach = on_attach,
    capabilities = capabilities 
}

require("clangd_extensions").setup{ capabilities = capabilities }

-- lua_ls is configured via Mason handler above

lspconfig.prosemd_lsp.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { vim.fn.expand("$HOME/.cargo/bin/prosemd-lsp"), "--stdio" },
    filetypes = { "markdown" },
    root_dir = util.find_git_ancestor,
}

lspconfig.pylsp.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = { enabled = true, maxLineLength = 100 },
                pyflakes = { enabled = true },
                pylint = { enabled = false },
                black = { enabled = true },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                pylsp_mypy = { enabled = false },
                jedi_completion = {
                    enabled = true,
                    include_params = true,
                    include_class_objects = true,
                },
                jedi_hover = { enabled = true },
                jedi_references = { enabled = true },
                jedi_signature_help = { enabled = true },
                jedi_symbols = { enabled = true },
                pyls_isort = { enabled = false },
            }
        }
    }
}

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
