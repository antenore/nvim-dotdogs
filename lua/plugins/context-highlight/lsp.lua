-- LSP integration for context-highlight plugin
-- Provides semantic symbol highlighting using LSP documentHighlight

local M = {}

local namespace = vim.api.nvim_create_namespace("context_highlight")

-- Check if any LSP client supports documentHighlight for the buffer
function M.get_document_highlight_client(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  for _, client in ipairs(clients) do
    if client.supports_method('textDocument/documentHighlight', { bufnr = bufnr }) then
      return client
    end
  end

  return nil
end

-- Highlight all occurrences of symbol under cursor using LSP
-- Returns true if successful, false if LSP unavailable
function M.highlight_symbol_lsp(bufnr, config, fallback_fn)
  if not config.use_lsp then
    if config.lsp_fallback_to_treesitter and fallback_fn then
      fallback_fn(bufnr)
    end
    return false
  end

  -- Check if LSP is available
  local client = M.get_document_highlight_client(bufnr)

  if not client then
    -- No LSP support, use fallback
    if config.lsp_fallback_to_treesitter and fallback_fn then
      fallback_fn(bufnr)
    end
    return false
  end

  -- Get cursor position in LSP format
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    position = { line = row, character = col }
  }

  -- Make async LSP request
  client.request('textDocument/documentHighlight', params, function(err, result, ctx)
    if err then
      -- LSP error, use fallback
      if config.lsp_fallback_to_treesitter and fallback_fn then
        vim.schedule(function()
          fallback_fn(bufnr)
        end)
      end
      return
    end

    if not result or #result == 0 then
      -- No highlights returned (cursor not on a symbol)
      return
    end

    -- Apply highlights from LSP
    vim.schedule(function()
      for _, highlight in ipairs(result) do
        local hl_group = "ContextHighlightSymbol"

        -- Use different colors for read vs write if configured
        if config.differentiate_read_write and highlight.kind then
          if highlight.kind == vim.lsp.protocol.DocumentHighlightKind.Write then
            hl_group = "ContextHighlightSymbolWrite"
          elseif highlight.kind == vim.lsp.protocol.DocumentHighlightKind.Read then
            hl_group = "ContextHighlightSymbolRead"
          end
        end

        local range = highlight.range
        local start_line = range.start.line
        local start_char = range.start.character
        local end_char = range['end'].character

        vim.api.nvim_buf_add_highlight(
          bufnr,
          namespace,
          hl_group,
          start_line,
          start_char,
          end_char
        )
      end
    end)
  end, bufnr)

  return true
end

return M
