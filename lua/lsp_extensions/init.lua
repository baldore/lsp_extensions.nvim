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
    textDocument =  vim.lsp.util.make_text_document_params()
  }
end

extensions.test = function ()
  extensions.setup_inlay_hints()
  vim.lsp.buf_request(0, 'rust-analyzer/inlayHints', extensions.inlay_params())
end

return extensions
