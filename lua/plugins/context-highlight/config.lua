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

  -- What minimal elements to highlight within active scope
  minimal_highlights = {
    keywords = true,     -- if, for, return, function, etc.
    operators = true,    -- +, -, =, ==, etc.
    strings = true,      -- String literals
    numbers = false,     -- Number literals
    comments = false,    -- Comments
  },
}

return M
