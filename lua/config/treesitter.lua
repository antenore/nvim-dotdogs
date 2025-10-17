require("nvim-treesitter.install").prefer_git = true

require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "lua", "vim", "python", "ruby", "bash",
		"json", "yaml", "dockerfile", "html", "comment", "vimdoc"
    },
    sync_install = false,
    ignore_install = { "latex" },
    highlight = {
        enable = true,
        disable = { "latex" },
        -- Use minimal highlighting - let context-highlight handle the rest
        additional_vim_regex_highlights = false,
	},
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection    = "gnn",
            node_incremental  = "grn",
            scope_incremental = "grc",
            node_decremental  = "grm",
        },
    },
    indent = { enable = true },
}

-- Context-aware highlighting (disabled - see lua/plugins/context-highlight/ for info)
-- require('config.context-highlight').setup({
--     minimal_highlights = {
--         strings = true,
--         comments = true,
--         numbers = false,
--         booleans = false,
--         keywords = false,
--     },
-- })