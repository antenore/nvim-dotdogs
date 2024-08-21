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
        disable = { "latex" }
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
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
    }
}