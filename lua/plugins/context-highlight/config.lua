-- Default configuration for context-highlight plugin

local M = {}

M.defaults = {
  enabled = true,

  -- Debounce cursor movements to avoid excessive highlighting
  debounce_ms = 100,

  -- Dimming configuration (higher = less dimming, more visible)
  -- 1.0 = no dimming, 0.8 = subtle dimming, 0.5 = moderate, 0.2 = heavy dimming
  dim_opacity = 0.7,

  -- LSP integration
  use_lsp = true,  -- Use LSP documentHighlight when available
  lsp_fallback_to_treesitter = true,  -- Fallback to TreeSitter if LSP unavailable
  differentiate_read_write = true,  -- Use different colors for read vs write

  -- Note: Syntax highlighting in active scope uses your colorscheme's natural colors
  -- The plugin no longer overrides TreeSitter highlights to ensure compatibility
  -- with any colorscheme (light or dark). The dimming effect provides sufficient contrast.
}

return M
