# Neovim Configuration

Modern Neovim configuration with LSP, Treesitter, and essential plugins.

## Requirements

### System Dependencies

**Arch Linux:**
```bash
# Core requirements
sudo pacman -S neovim git curl unzip nodejs npm python python-pip ripgrep fd

# Optional but recommended
sudo pacman -S fortune-mod ctags the_silver_searcher fzf lazygit

# For clipboard support
sudo pacman -S xclip wl-clipboard

# For Telescope live_grep
sudo pacman -S ripgrep

# For Mason LSP servers
sudo pacman -S gcc make cmake
```

**Ubuntu/Debian:**
```bash
# Core requirements
sudo apt update && sudo apt upgrade
# neovim > 0.10 is required
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt install neovim git curl unzip nodejs npm python3 python3-pip ripgrep fd-find

# Optional but recommended
sudo apt install fortune-mod exuberant-ctags silversearcher-ag fzf

# For clipboard support
sudo apt install xclip wl-clipboard-tools

# For Mason LSP servers
sudo apt install build-essential cmake

# Note: fd-find is installed as 'fdfind' on Ubuntu
# Create symlink if needed: ln -s $(which fdfind) ~/.local/bin/fd
```

### Language Servers (Auto-installed via Mason)

The following LSP servers are automatically installed:
* `lua_ls` — Lua Language Server
* `pylsp` — Python LSP Server
* `cmake` — CMake Language Server
* `jsonls` — JSON Language Server
* `yamlls` — YAML Language Server
* `html` — HTML Language Server
* `bashls` — Bash Language Server
* `vimls` — VimScript Language Server
* `solargraph` — Ruby Language Server
* `prosemd_lsp` — Markdown Language Server (requires Rust/Cargo)

### Additional Tools

**For Markdown LSP (prosemd_lsp):**
```bash
# Install Rust if not already installed
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# Install prosemd-lsp
cargo install prosemd-lsp
```

## Installation

1. **Backup existing config:**
```bash
mv ~/.config/nvim ~/.config/nvim.backup
```

2. **Clone or copy this configuration:**
```bash
# If using git
git clone <your-repo> ~/.config/nvim

# Or copy your existing config
cp -r /path/to/this/config ~/.config/nvim
```

3. **Start Neovim:**
```bash
nvim
```

4. **Install plugins:**
Lazy.nvim will automatically install plugins on first startup.

5. **Install LSP servers:**
```vim
:Mason
```
Then press `i` to install servers, or they'll auto-install when opening relevant files.

## Key Features

* **LSP Integration** — Full language server support with diagnostics
* **Autocompletion** — nvim-cmp with multiple sources
* **Fuzzy Finding** — Telescope for files, grep, and more
* **Syntax Highlighting** — Treesitter with modern parsing
* **File Explorer** — nvim-tree for project navigation
* **Git Integration** — Gitsigns for git status in editor
* **Status Line** — Custom lualine configuration
* **Custom Dashboard** — Alpha.nvim with ASCII art

## Key Mappings

### Leader Key: `<Space>`

**File Operations:**
* `<leader>f` — Find files (Telescope)
* `<leader>t` — Live grep (Telescope)
* `<leader>r` — Recent files (Telescope)

**LSP:**
* `<leader>e` — Show diagnostics float
* `<leader>ca` — Code actions
* `<leader>rn` — Rename symbol
* `<leader>f` — Format buffer
* `gd` — Go to definition
* `gr` — Go to references
* `K` — Show hover information

**Diagnostics:**
* `<leader>dt` — Toggle virtual text diagnostics
* `<leader>dd` — Disable diagnostics for buffer
* `<leader>de` — Enable diagnostics for buffer
* `<leader>lr` — Restart LSP
* `[d` / `]d` — Navigate diagnostics

**Navigation:**
* `<leader>q` — Add diagnostics to location list

## Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Main configuration entry
├── lua/
│   ├── plugins.lua          # Plugin definitions
│   ├── general.lua          # General settings
│   ├── config/             # Plugin configurations
│   │   ├── lsp.lua         # LSP setup
│   │   ├── cmp.lua         # Completion setup
│   │   ├── telescope.lua   # Fuzzy finder
│   │   ├── treesitter.lua  # Syntax highlighting
│   │   └── ...             # Other plugin configs
│   └── utils/              # Utility functions
└── snippets/               # Code snippets
```

## Troubleshooting

**LSP not working:**
1. Check `:LspInfo` for server status
2. Ensure language server is installed via `:Mason`
3. Restart LSP with `<leader>lr`

**Missing icons:**
Install a Nerd Font and set it in your terminal.

**Python LSP issues:**
Ensure Python and pip are available:
```bash
python3 --version
pip3 --version
```

**Telescope not finding files:**
Ensure `ripgrep` and `fd` are installed and in PATH.

## Updating

```bash
# Update plugins
:Lazy sync

# Update LSP servers
:Mason
# Then 'U' to update all installed servers
```
