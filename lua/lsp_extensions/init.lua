local M = {}

M.setup_inlay_hints = function (opts)
  opts = opts or {}

  local callback = M.get_callback(opts)

  vim.lsp.callbacks['rust-analyzer/inlayHints'] = callback
  vim.lsp.callbacks['experimental/inlayHints'] = callback
end

local inlay_hints_ns = vim.api.nvim_create_namespace('lsp_extensions.inlay_hints')

M.get_callback = function(opts)
  local highlight = opts.highlight or 'Comment'
  local prefix = opts.prefix or " || "
  local aligned = opts.aligned or false

  return function (_, _, result, _, bufnr)
    if not result then
      print('[lsp_extensions.inlay_hints] No inlay hints found')
      return
    end

    local hint_store = {}
    local longest_line_len = -1

    vim.api.nvim_buf_clear_namespace(bufnr, inlay_hints_ns, 0, -1)

    for _, hint in ipairs(result) do
      local finish = hint.range['end'].line

      if not hint_store[finish] or hint.kind == 'ChainingHint' then
        hint_store[finish] = hint

        if aligned then
          local line_len = #vim.api.nvim_buf_get_lines(bufnr, finish, finish + 1, false)[1]
          longest_line_len = math.max(longest_line_len, line_len)
        end
      end
    end

    for _, hint in ipairs(hint_store) do
      local finish = hint.range['end'].line
      local text

      if aligned then
        local line_len = #vim.api.nvim_buf_get_lines(bufnr, finish, finish + 1, false)[1]
        local spaces_prefix = string.rep(' ', longest_line_len - line_len)
        text = spaces_prefix .. prefix .. hint.label
      else
        text = prefix .. hint.label
      end

      vim.api.nvim_buf_set_virtual_text(bufnr, inlay_hints_ns, finish, { { text, highlight } }, {})
    end
  end
end

M.inlay_params = function ()
  return {
    textDocument = vim.lsp.util.make_text_document_params()
  }
end

M.test = function ()
  M.setup_inlay_hints()
  vim.lsp.buf_request(0, 'rust-analyzer/inlayHints', M.inlay_params())
end

return M
