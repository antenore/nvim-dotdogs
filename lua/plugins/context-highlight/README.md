# context-highlight.nvim

Context-aware syntax highlighting for Neovim using TreeSitter and LSP.

## Overview

Hybrid highlighting system that combines:
- Multi-level scope-based dimming (innermost scope brightest, outer scopes progressively dimmer)
- Symbol reference highlighting via LSP or TreeSitter fallback
- Automatic color scheme integration

## Requirements

- Neovim >= 0.9.0
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- TreeSitter parser for target language
- LSP server (optional, for semantic highlighting)

## Installation

### lazy.nvim

```lua
{
  dir = "~/.config/nvim/lua/plugins/context-highlight",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require('plugins.context-highlight').setup({
      enabled = true,
      debounce_ms = 100,
      dim_opacity = 0.7,
      use_lsp = true,
      lsp_fallback_to_treesitter = true,
      differentiate_read_write = true,
    })
  end,
}
```

### packer.nvim

```lua
use {
  '~/.config/nvim/lua/plugins/context-highlight',
  requires = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('plugins.context-highlight').setup()
  end
}
```

### vim-plug

```vim
Plug 'nvim-treesitter/nvim-treesitter'
Plug '~/.config/nvim/lua/plugins/context-highlight'
```

```lua
require('plugins.context-highlight').setup()
```

### Native package manager (Neovim 0.8+)

```bash
mkdir -p ~/.local/share/nvim/site/pack/plugins/start
ln -s ~/.config/nvim/lua/plugins/context-highlight ~/.local/share/nvim/site/pack/plugins/start/
```

```lua
require('plugins.context-highlight').setup()
```

## Configuration

Default configuration:

```lua
{
  enabled = true,
  debounce_ms = 100,              -- Cursor movement debounce
  dim_opacity = 0.7,              -- 0.0 (max dim) to 1.0 (no dim)
  use_lsp = true,                 -- Use LSP documentHighlight
  lsp_fallback_to_treesitter = true,
  differentiate_read_write = true, -- Different colors for reads vs writes
}
```

## Usage

```lua
-- Toggle on/off
require('plugins.context-highlight').toggle()

-- Manual control
require('plugins.context-highlight').enable()
require('plugins.context-highlight').disable()

-- Debug information
require('plugins.context-highlight').debug()
```

## How It Works

1. **Scope Detection**: TreeSitter AST identifies nested scopes (functions, loops, conditionals)
2. **Multi-Level Dimming**: Applies progressive dimming based on scope hierarchy
   - Innermost scope (cursor location): 100% brightness
   - Parent scope: 85% brightness
   - Outer scopes: 70% brightness
   - Outside all scopes: 50% brightness
3. **Symbol Highlighting**: LSP `textDocument/documentHighlight` or TreeSitter fallback
4. **Color Integration**: Auto-detects background color and calculates dimmed variants

## Documentation

See `:help context-highlight` for complete documentation.

## License

MIT License - Copyright (c) 2025 Antenore Gatta
