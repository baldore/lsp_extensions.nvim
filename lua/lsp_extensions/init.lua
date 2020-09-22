local extensions = {}

extensions.setup_inlay_hints = function ()
  local callback = function (err, method, params, client_id)
    print(vim.inspect(params))
  end

  vim.lsp.callbacks['rust-analyzer/inlayHints'] = callback
  vim.lsp.callbacks['experimental/inlayHints'] = callback
end

extensions.inlay_params = function ()
  return {
    textDocument = vim.lsp.util.make_text_document_params()
  }
end

local inlay_hints_ns = vim.api.nvim_create_namespace('lsp_extensions.inlay_hints')

extensions.test = function (highlight)
  highlight = highlight or 'Comment'

  extensions.setup_inlay_hints()

  vim.lsp.buf_request(0, 'rust-analyzer/inlayHints', extensions.inlay_params(), function (err, method, result, client_id, bufnr)
    if not result then
      return
    end

    vim.api.nvim_buf_clear_namespace(0, inlay_hints_ns, 0, -1)

    local hint_store = {}

    for _, hint in ipairs(result) do
      local finish = hint.range['end'].line
      if not hint_store[finish] then
        hint_store[finish] = hint
      elseif hint.kind == 'ChainingHint' then
        hint_store[finish] = hint
      end
    end

    for _, hint in ipairs(hint_store) do
      print(vim.inspect(hint))
      vim.api.nvim_buf_set_virtual_text(0, inlay_hints_ns, hint.range['end'].line, { { hint.label, highlight } }, {})
    end
   end)
end

return extensions
