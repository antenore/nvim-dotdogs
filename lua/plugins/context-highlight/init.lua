-- Copyright (c) 2025 Antenore Gatta
-- Licensed under the MIT License. See LICENSE file in the project root for details.

-- Context-aware syntax highlighting using TreeSitter and LSP
-- Dims code outside current scope, minimally highlights within scope
-- Philosophy: If everything is highlighted, nothing stands out

local M = {}

-- Import modules
local config_module = require('plugins.context-highlight.config')
local scope = require('plugins.context-highlight.scope')
local highlight = require('plugins.context-highlight.highlight')
local lsp = require('plugins.context-highlight.lsp')

-- Configuration (will be merged with user config)
M.config = vim.deepcopy(config_module.defaults)

local timer = nil

-- Initialize the context highlighting system
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  if not M.config.enabled then
    return
  end

  -- Setup highlight groups
  highlight.setup_highlights(M.config)

  -- Setup autocmds
  M.setup_autocmds()
end

-- Update highlighting based on current cursor position
function M.update_highlighting()
  if not M.config.enabled then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  -- Clear previous highlights
  highlight.clear_highlights(bufnr)

  -- Get the scope hierarchy
  local scopes = scope.get_scope_hierarchy(bufnr)

  -- Apply multi-level dimming
  highlight.apply_multi_level_dimming(bufnr, scopes)

  -- Highlight symbol under cursor
  -- Try LSP first, fallback to TreeSitter if unavailable
  local lsp_success = lsp.highlight_symbol_lsp(
    bufnr,
    M.config,
    highlight.highlight_symbol_treesitter
  )
end

-- Setup autocmds for context highlighting
function M.setup_autocmds()
  local group = vim.api.nvim_create_augroup("ContextHighlight", { clear = true })

  -- Reapply highlights when colorscheme changes
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      highlight.setup_highlights(M.config)
    end,
  })

  -- Update highlighting on cursor movement with debouncing
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    callback = function()
      if not M.config.enabled then
        return
      end

      -- Debounce the highlighting update
      if timer then
        timer:stop()
      end
      timer = vim.defer_fn(M.update_highlighting, M.config.debounce_ms)
    end,
  })

  -- Clear highlights when leaving a buffer
  vim.api.nvim_create_autocmd({ "BufLeave" }, {
    group = group,
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      highlight.clear_highlights(bufnr)
    end,
  })

  -- Update highlighting when entering a buffer
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = group,
    callback = function()
      if M.config.enabled then
        vim.defer_fn(M.update_highlighting, 50)
      end
    end,
  })
end

-- Toggle context highlighting on/off
function M.toggle()
  M.config.enabled = not M.config.enabled
  if M.config.enabled then
    highlight.setup_highlights(M.config)
    M.setup_autocmds()
    M.update_highlighting()
    print("Context highlighting enabled")
  else
    -- Clear all highlights
    local bufnr = vim.api.nvim_get_current_buf()
    highlight.clear_highlights(bufnr)
    print("Context highlighting disabled")
  end
end

-- Enable function for manual testing
function M.enable()
  M.config.enabled = true
  highlight.setup_highlights(M.config)
  M.setup_autocmds()
  M.update_highlighting()
end

-- Disable function
function M.disable()
  M.config.enabled = false
  local bufnr = vim.api.nvim_get_current_buf()
  highlight.clear_highlights(bufnr)
end

-- Debug function to show colors and extmarks
function M.debug_colors()
  local bufnr = vim.api.nvim_get_current_buf()

  print("=== HIGHLIGHT GROUPS & COLORS ===")

  -- Helper to format color
  local function fmt_color(c)
    if not c then return "nil" end
    return string.format("#%06x", c)
  end

  -- Helper to show highlight group
  local function show_hl(name)
    local hl = vim.api.nvim_get_hl(0, { name = name })
    print(string.format("  %s:", name))
    print(string.format("    fg=%s bg=%s bold=%s underline=%s",
      fmt_color(hl.fg), fmt_color(hl.bg),
      tostring(hl.bold or false), tostring(hl.underline or false)))
  end

  -- Show all relevant highlight groups
  print("\nNormal:")
  show_hl("Normal")

  print("\nDimming:")
  show_hl("ContextHighlightDimHeavy")
  show_hl("ContextHighlightDimMedium")
  show_hl("ContextHighlightDimLight")

  print("\nSymbol Highlighting:")
  show_hl("ContextHighlightSymbol")
  show_hl("ContextHighlightSymbolRead")
  show_hl("ContextHighlightSymbolWrite")

  print("\nColorscheme LSP groups (source):")
  show_hl("LspReferenceText")
  show_hl("LspReferenceRead")
  show_hl("LspReferenceWrite")

  print("\nColorscheme Search groups (fallback):")
  show_hl("Search")
  show_hl("IncSearch")

  print("\n=== EXTMARKS AT CURRENT LINE ===")
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1

  -- Check dimming namespace
  local dim_namespace = vim.api.nvim_create_namespace("context_highlight_dim")
  local dim_marks = vim.api.nvim_buf_get_extmarks(bufnr, dim_namespace, {row, 0}, {row, -1}, {details = true})
  if #dim_marks > 0 then
    print("\nDimming extmarks on line " .. (row + 1) .. ":")
    for _, mark in ipairs(dim_marks) do
      local details = mark[4]
      print(string.format("  priority=%d hl_group=%s", details.priority or 0, details.line_hl_group or details.hl_group or "none"))
    end
  end

  -- Check highlight namespace
  local highlight_namespace = vim.api.nvim_create_namespace("context_highlight")
  local hl_marks = vim.api.nvim_buf_get_extmarks(bufnr, highlight_namespace, {row, 0}, {row, -1}, {details = true})
  if #hl_marks > 0 then
    print("\nSymbol extmarks on line " .. (row + 1) .. ":")
    for _, mark in ipairs(hl_marks) do
      local details = mark[4]
      print(string.format("  col=%d-%d priority=%d hl_group=%s",
        mark[2], details.end_col or mark[2],
        details.priority or 0, details.hl_group or "none"))
    end
  else
    print("\nNo symbol extmarks on line " .. (row + 1))
  end

  print("\n=== BACKGROUND MODE ===")
  print("vim.o.background:", vim.o.background)
  print("==============================")
end

-- Debug function to test manually
function M.debug()
  local bufnr = vim.api.nvim_get_current_buf()
  print("=== Context Highlight Debug ===")
  print("Enabled:", M.config.enabled)
  print("Buffer:", bufnr)
  print("Dim opacity:", M.config.dim_opacity)
  print("LSP enabled:", M.config.use_lsp)
  print("Differentiate Read/Write:", M.config.differentiate_read_write)

  -- Check TreeSitter
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  print("TreeSitter available:", ok)
  if ok then
    print("Language:", parser:lang())
  end

  -- Check LSP
  local lsp_client = lsp.get_document_highlight_client(bufnr)
  print("LSP documentHighlight available:", lsp_client ~= nil)
  if lsp_client then
    print("LSP client:", lsp_client.name)
  end

  -- Check node under cursor and walk up tree
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  print("\nCursor position:", row + 1, col)

  if ok then
    local tree = parser:parse()[1]
    if tree then
      local root = tree:root()
      local node = root:descendant_for_range(row, col, row, col)

      print("\nNode hierarchy (from cursor up):")
      local depth = 0
      while node and depth < 10 do
        local node_type = node:type()
        local is_scope = scope.is_scope_node(node)
        local start_row, _, end_row, _ = node:range()
        print(string.format("  %d. %s (lines %d-%d) %s",
          depth, node_type, start_row + 1, end_row + 1,
          is_scope and "[SCOPE]" or ""))
        node = node:parent()
        depth = depth + 1
      end
    end
  end

  -- Check current scope
  local scopes = scope.get_scope_hierarchy(bufnr)
  if #scopes > 0 then
    print("\nScope hierarchy:")
    for i, s in ipairs(scopes) do
      print(string.format("  Level %d: %s (lines %d-%d)",
        i, s.node_type, s.start_row + 1, s.end_row + 1))
    end
  else
    print("\nNo scopes detected (entire buffer active)")
  end

  print("\nAttempting to update highlighting...")
  M.update_highlighting()
  print("Check for dimmed lines and symbol highlighting!")
  print("==============================")
end

return M
