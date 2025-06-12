-- https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
-- https://github.com/hrsh7th/nvim-cmp

vim.o.completeopt = "menu,menuone,noselect"

local M = {}

function M.setup()
	local cmp = require 'cmp'

	require 'cmp_emoji'

	local source_mapping = {
		nvim_lsp      = '[LSP]',
		ultisnips     = '[Snip]',
		-- tabnine    = '[T9]',
		buffer        = '[Buf]',
		treesitter    = '[TS]',
		path          = '[Path]',
		spell         = '[Spell]',
		tags          = '[Tags]',
		nvim_lua      = '[Lua]',
		latex_symbols = '[Latex]',
		cmdline       = '[Cmd]',
		luasnip       = '[Snip]',
		emoji         = '[Emoji]',
		zsh           = '[Zsh]',
	}

	local kind_icons = {
		-- if you change or add symbol here
		-- replace corresponding line in readme
		Text           = ' ',
		-- Text        = ' ',
		-- Method      = '',
		-- Method      = '',
		Method         = ' ',
		Function       = ' ',
		-- Constructor = '',
		Constructor    = ' ',
		Field          = 'ﰠ ',
		Variable       = ' ',
		Class          = 'ﴯ ',
		Interface      = ' ',
		Module         = ' ',
		-- Property    = 'ﰠ',
		Property       = '',
		Unit           = ' 塞',
		Value          = ' ',
		-- Enum        = '',
		Enum           = '了 ',
		-- Keyword     = '',
		Keyword        = ' ',
		-- Snippet     = '',
		Snippet        = ' ',
		Color          = ' ',
		File           = ' ',
		Reference      = ' ',
		Folder         = ' ',
		EnumMember     = '',
		-- Constant    = '',
		Constant       = ' ',
		Struct         = 'פּ ',
		Event          = ' ',
		Operator       = ' ',
		TypeParameter  = '  '
	}

    cmp.setup({
        snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<CR>'] = cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = false,
            }),
            ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's', 'c' }),
            ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's', 'c' }),
        }),
        formatting = {
            format = function(entry, vim_item)
                vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
                vim_item.menu = source_mapping[entry.source.name]
                return vim_item
            end
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'nvim_lsp_signature_help' },
            { name = 'luasnip' },
            { name = 'treesitter' },
            { name = 'buffer' },
            { name = 'tags' },
            { name = 'nvim_lua' },
            { name = 'path' },
            { name = 'spell' },
            { name = 'calc' },
            { name = 'look' },
            { name = 'zsh' },
            { name = 'emoji' },
        }),
        window = {
            documentation = {
                border = {'╭', '─', '╮', '│', '╯', '─', '╰', '│'},
            },
        },
    })

    -- `/` cmdline setup.
    cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' }
        }
    })

    -- `:` cmdline setup.
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            {
                name = 'cmdline',
                option = {
                    ignore_cmds = { 'Man', '!' }
                }
            }
        })
    })

    -- Disable cmp for Telescope
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "TelescopePrompt",
        callback = function()
            require('cmp').setup.buffer { enabled = false }
        end,
    })
end

return M