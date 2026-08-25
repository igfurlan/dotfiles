-- NOTE: rewritten for mason-lspconfig 2.x.
-- The article passes a `handlers = { function(server_name) ... end }` table to
-- mason-lspconfig.setup(). That option was REMOVED in 2.x -- passing it silently
-- configures nothing. 2.x instead calls vim.lsp.enable() for every installed
-- server automatically (`automatic_enable`, on by default), and shared settings
-- go through vim.lsp.config("*", ...).

local ok_mason, mason = pcall(require, "mason")
if not ok_mason then return end
mason.setup({})

-- Advertise nvim-cmp's completion capabilities to every server.
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  vim.lsp.config("*", { capabilities = cmp_lsp.default_capabilities() })
end

require("mason-lspconfig").setup({
  -- Servers to install automatically on first launch, e.g. { "lua_ls", "pyright" }.
  -- Left empty so startup never blocks on a download; install on demand with
  -- :Mason or :MasonInstall lua-language-server
  ensure_installed = {},

  -- rustaceanvim starts and owns its own rust-analyzer client. If mason also
  -- enabled rust_analyzer you would get two clients attached to every Rust
  -- buffer -- duplicate diagnostics, duplicate completions.
  automatic_enable = { exclude = { "rust_analyzer" } },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach_keymaps", { clear = true }),
  callback = function(args)
    local opts = { buffer = args.buf, remap = false }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>h", vim.lsp.buf.signature_help, opts)

    -- The article maps [d -> goto_next and ]d -> goto_prev, which is backwards
    -- from the Vim convention ([ = previous, ] = next). Corrected here, and
    -- using vim.diagnostic.jump() since goto_next/goto_prev are deprecated.
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
  end,
})
