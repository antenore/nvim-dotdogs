-- Copyright (c) 2025 Antenore Gatta
-- Licensed under the MIT License. See LICENSE file in the project root for details.

-- Scope detection using TreeSitter for context-highlight plugin

local M = {}

-- Scope node types to recognize as containers
M.SCOPE_NODE_TYPES = {
  -- Exact matches (common across languages)
  "function_definition",
  "function_declaration",
  "method_definition",
  "class_definition",
  "class_declaration",
  "if_statement",
  "for_statement",
  "while_statement",
  "do_statement",
  "repeat_statement",
  "block",
  "lambda",
  "closure",
  "chunk",  -- Lua top-level
  -- Lua-specific
  "function",
  "local_function",
  "for_in_statement",
  "for_numeric_statement",
}

-- Check if a node type is a scope container
function M.is_scope_node(node)
  if not node then
    return false
  end

  local node_type = node:type()

  -- Check exact matches
  for _, scope_type in ipairs(M.SCOPE_NODE_TYPES) do
    if node_type == scope_type then
      return true
    end
  end

  -- Also check pattern matches for language-agnostic detection
  -- Match any node type ending in _statement, _function, _method, _class, _block
  if node_type:match("_statement$") or
     node_type:match("_function$") or
     node_type:match("_method$") or
     node_type:match("_class$") or
     node_type:match("_block$") then
    return true
  end

  return false
end

-- Find all scopes in hierarchy from cursor outward
-- Returns array of scopes: {{start_row, end_row, node_type}, ...}
-- Index 1 is innermost (cursor's immediate scope), higher indices are outer scopes
function M.get_scope_hierarchy(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  -- Check if treesitter is available for this buffer
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok then
    return {}
  end

  local tree = parser:parse()[1]
  if not tree then
    return {}
  end

  local root = tree:root()
  local node = root:descendant_for_range(row, col, row, col)

  local scopes = {}

  -- Walk up the tree and collect all scopes
  while node do
    if M.is_scope_node(node) then
      local start_row, _, end_row, _ = node:range()
      table.insert(scopes, {
        start_row = start_row,
        end_row = end_row,
        node_type = node:type(),
        node = node,
      })
    end
    node = node:parent()
  end

  return scopes
end

-- Find the innermost scope containing the cursor (for backwards compatibility)
function M.get_current_scope(bufnr)
  local scopes = M.get_scope_hierarchy(bufnr)
  if #scopes > 0 then
    return scopes[1].start_row, scopes[1].end_row
  end
  return nil, nil
end

return M
