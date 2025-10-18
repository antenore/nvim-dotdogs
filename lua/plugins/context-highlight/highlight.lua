-- Highlighting logic for context-highlight plugin
-- Handles color scheme integration, dimming, and TreeSitter-based symbol highlighting

local M = {}

local namespace = vim.api.nvim_create_namespace("context_highlight")
local dim_namespace = vim.api.nvim_create_namespace("context_highlight_dim")

-- Get current color scheme's normal background
local function get_normal_bg()
  local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })

  if normal_hl.bg then
    return normal_hl.bg
  end

  -- Fallback: check if we're in dark or light mode
  if vim.o.background == "dark" then
    return 0x1d2021  -- Dark background
  else
    return 0xfbf1c7  -- Light background
  end
end

-- Darken or lighten a color by a factor
local function adjust_color(color, factor)
  -- Extract RGB components (color is a number like 0x1d2021)
  local r = math.floor(color / 65536) % 256
  local g = math.floor(color / 256) % 256
  local b = color % 256

  -- Darken for dark themes, lighten for light themes
  if vim.o.background == "dark" then
    -- Darken: reduce values
    r = math.floor(r * factor)
    g = math.floor(g * factor)
    b = math.floor(b * factor)
  else
    -- Lighten: increase towards white
    r = math.floor(r + (255 - r) * (1 - factor))
    g = math.floor(g + (255 - g) * (1 - factor))
    b = math.floor(b + (255 - b) * (1 - factor))
  end

  -- Combine back to single number
  return r * 65536 + g * 256 + b
end

-- Setup all highlight groups
function M.setup_highlights(config)
  local cfg = config.minimal_highlights

  -- Get current background color
  local bg_color = get_normal_bg()

  -- Create multiple dimming levels based on current theme
  -- dim_opacity controls the dimming intensity for out-of-scope code

  -- Heavy dimming (outside all scopes)
  local dim_heavy = adjust_color(bg_color, config.dim_opacity * 0.5)
  vim.api.nvim_set_hl(0, "ContextHighlightDimHeavy", {
    bg = string.format("#%06x", dim_heavy),
  })

  -- Medium dimming (grandparent/outer scopes)
  local dim_medium = adjust_color(bg_color, config.dim_opacity * 0.7)
  vim.api.nvim_set_hl(0, "ContextHighlightDimMedium", {
    bg = string.format("#%06x", dim_medium),
  })

  -- Light dimming (parent scope)
  local dim_light = adjust_color(bg_color, config.dim_opacity * 0.85)
  vim.api.nvim_set_hl(0, "ContextHighlightDimLight", {
    bg = string.format("#%06x", dim_light),
  })

  -- Symbol highlighting groups
  -- Default symbol highlight (TreeSitter fallback or when Read/Write not differentiated)
  vim.api.nvim_set_hl(0, "ContextHighlightSymbol", {
    bg = "#504945",  -- Subtle background highlight
    bold = true,
    underline = true,
  })

  -- Read reference (LSP)
  vim.api.nvim_set_hl(0, "ContextHighlightSymbolRead", {
    bg = "#3d5a6b",  -- Blue-ish background for reads
    bold = true,
  })

  -- Write reference (LSP)
  vim.api.nvim_set_hl(0, "ContextHighlightSymbolWrite", {
    bg = "#6b5d3f",  -- Orange-ish background for writes
    bold = true,
    underline = true,
  })

  -- Define minimal highlights for active scope
  -- Make these stand out clearly against dimmed background
  local highlights = {
    -- Keywords - bright and bold
    ["@keyword"] = cfg.keywords and { fg = "#d5c4a1", bold = true } or { fg = "NONE" },
    ["@keyword.function"] = cfg.keywords and { fg = "#d5c4a1", bold = true } or { fg = "NONE" },
    ["@keyword.return"] = cfg.keywords and { fg = "#d5c4a1", bold = true } or { fg = "NONE" },
    ["@keyword.operator"] = cfg.keywords and { fg = "#d5c4a1", bold = true } or { fg = "NONE" },
    ["@keyword.conditional"] = cfg.keywords and { fg = "#d5c4a1", bold = true } or { fg = "NONE" },
    ["@keyword.repeat"] = cfg.keywords and { fg = "#d5c4a1", bold = true } or { fg = "NONE" },

    -- Operators - medium brightness
    ["@operator"] = cfg.operators and { fg = "#bdae93" } or { fg = "NONE" },

    -- Strings - subtle green
    ["@string"] = cfg.strings and { fg = "#b8bb26", italic = true } or { fg = "NONE" },
    ["@string.escape"] = cfg.strings and { fg = "#d5c4a1" } or { fg = "NONE" },
    ["@character"] = cfg.strings and { fg = "#b8bb26" } or { fg = "NONE" },

    -- Numbers - warm orange
    ["@number"] = cfg.numbers and { fg = "#fe8019" } or { fg = "NONE" },
    ["@number.float"] = cfg.numbers and { fg = "#fe8019" } or { fg = "NONE" },
    ["@boolean"] = cfg.numbers and { fg = "#fe8019" } or { fg = "NONE" },

    -- Comments - muted but visible
    ["@comment"] = cfg.comments and { fg = "#928374", italic = true } or { fg = "NONE" },
    ["@comment.documentation"] = cfg.comments and { fg = "#a89984", italic = true } or { fg = "NONE" },

    -- Everything else gets NO highlighting
    ["@variable"] = { fg = "NONE" },
    ["@variable.builtin"] = { fg = "NONE" },
    ["@variable.parameter"] = { fg = "NONE" },
    ["@variable.member"] = { fg = "NONE" },
    ["@function"] = { fg = "NONE" },
    ["@function.builtin"] = { fg = "NONE" },
    ["@function.call"] = { fg = "NONE" },
    ["@method"] = { fg = "NONE" },
    ["@method.call"] = { fg = "NONE" },
    ["@parameter"] = { fg = "NONE" },
    ["@property"] = { fg = "NONE" },
    ["@field"] = { fg = "NONE" },
    ["@type"] = { fg = "NONE" },
    ["@type.builtin"] = { fg = "NONE" },
    ["@constructor"] = { fg = "NONE" },
    ["@constant"] = { fg = "NONE" },
    ["@constant.builtin"] = { fg = "NONE" },
    ["@namespace"] = { fg = "NONE" },
    ["@module"] = { fg = "NONE" },
    ["@punctuation.bracket"] = { fg = "NONE" },
    ["@punctuation.delimiter"] = { fg = "NONE" },
    ["@punctuation.special"] = { fg = "NONE" },
    ["@tag"] = { fg = "NONE" },
    ["@tag.attribute"] = { fg = "NONE" },
    ["@tag.delimiter"] = { fg = "NONE" },
    ["@label"] = { fg = "NONE" },
    ["@attribute"] = { fg = "NONE" },
  }

  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Clear all highlights in the current buffer
function M.clear_highlights(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  vim.api.nvim_buf_clear_namespace(bufnr, dim_namespace, 0, -1)
end

-- Apply multi-level dimming based on scope hierarchy
function M.apply_multi_level_dimming(bufnr, scopes)
  if #scopes == 0 then
    -- No scopes detected, don't dim anything
    return
  end

  local total_lines = vim.api.nvim_buf_line_count(bufnr)

  -- Create a map of line numbers to their scope level
  -- level 0 = innermost scope (cursor location), higher = outer scopes
  local line_levels = {}

  for line = 0, total_lines - 1 do
    line_levels[line] = nil  -- Default: not in any scope (maximum dimming)

    -- Check which scope this line belongs to (use innermost)
    for level, scope in ipairs(scopes) do
      if line >= scope.start_row and line <= scope.end_row then
        if not line_levels[line] or level < line_levels[line] then
          line_levels[line] = level
        end
      end
    end
  end

  -- Apply dimming based on scope level
  for line = 0, total_lines - 1 do
    local level = line_levels[line]

    if level == nil then
      -- Outside all scopes: maximum dimming
      vim.api.nvim_buf_set_extmark(bufnr, dim_namespace, line, 0, {
        end_row = line,
        end_col = 0,
        hl_eol = true,
        line_hl_group = "ContextHighlightDimHeavy",
        priority = 100,
      })
    elseif level > 2 then
      -- Outer scopes (grandparent function, etc): medium dimming
      vim.api.nvim_buf_set_extmark(bufnr, dim_namespace, line, 0, {
        end_row = line,
        end_col = 0,
        hl_eol = true,
        line_hl_group = "ContextHighlightDimMedium",
        priority = 101,
      })
    elseif level == 2 then
      -- Parent scope: light dimming
      vim.api.nvim_buf_set_extmark(bufnr, dim_namespace, line, 0, {
        end_row = line,
        end_col = 0,
        hl_eol = true,
        line_hl_group = "ContextHighlightDimLight",
        priority = 102,
      })
    end
    -- level == 1 (innermost scope): no dimming
  end
end

--
-- TreeSitter-based symbol highlighting (fallback when LSP unavailable)
--

-- Get the text of a TreeSitter node
local function get_node_text(node, bufnr)
  local start_row, start_col, end_row, end_col = node:range()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)

  if #lines == 0 then
    return ""
  end

  if #lines == 1 then
    return lines[1]:sub(start_col + 1, end_col)
  end

  -- Multi-line node
  lines[1] = lines[1]:sub(start_col + 1)
  lines[#lines] = lines[#lines]:sub(1, end_col)
  return table.concat(lines, "\n")
end

-- Check if node is an identifier that we want to highlight
local function is_highlightable_identifier(node)
  if not node then
    return false
  end

  local node_type = node:type()

  -- Match identifier-like nodes (works across languages)
  return node_type == "identifier"
      or node_type:match("name$")
      or node_type == "field"
      or node_type == "property"
      or node_type == "variable"
end

-- Find all occurrences of an identifier in the buffer
local function find_symbol_occurrences(bufnr, symbol_text)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok then
    return {}
  end

  local tree = parser:parse()[1]
  if not tree then
    return {}
  end

  local root = tree:root()
  local occurrences = {}

  -- Traverse the tree and find all matching identifiers
  local function traverse(node)
    if not node then
      return
    end

    if is_highlightable_identifier(node) then
      local text = get_node_text(node, bufnr)
      if text == symbol_text then
        local start_row, start_col, end_row, end_col = node:range()
        table.insert(occurrences, {
          start_row = start_row,
          start_col = start_col,
          end_row = end_row,
          end_col = end_col,
        })
      end
    end

    -- Recursively traverse children
    for child in node:iter_children() do
      traverse(child)
    end
  end

  traverse(root)
  return occurrences
end

-- Highlight all occurrences of the symbol under cursor using TreeSitter
function M.highlight_symbol_treesitter(bufnr)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  -- Get TreeSitter node at cursor
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok then
    return
  end

  local tree = parser:parse()[1]
  if not tree then
    return
  end

  local root = tree:root()
  local node = root:descendant_for_range(row, col, row, col)

  if not is_highlightable_identifier(node) then
    return
  end

  local symbol_text = get_node_text(node, bufnr)
  if not symbol_text or symbol_text == "" or #symbol_text < 2 then
    return
  end

  -- Find and highlight all occurrences
  local occurrences = find_symbol_occurrences(bufnr, symbol_text)

  for _, occurrence in ipairs(occurrences) do
    vim.api.nvim_buf_add_highlight(
      bufnr,
      namespace,
      "ContextHighlightSymbol",
      occurrence.start_row,
      occurrence.start_col,
      occurrence.end_col
    )
  end
end

return M
