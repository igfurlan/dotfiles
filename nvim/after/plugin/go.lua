-- Go. go.nvim is loaded on the go/gomod filetypes and set up in its plugin
-- spec with lsp_cfg = false, so gopls comes from mason/lspconfig only.
-- Run :GoInstallBinaries once to fetch gofumpt, goimports, gomodifytags, etc.

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("go_keymaps", { clear = true }),
  pattern = { "go", "gomod" },
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "<leader>gr", "<cmd>GoRun<CR>", vim.tbl_extend("force", opts, { desc = "Go: run" }))
    vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<CR>", vim.tbl_extend("force", opts, { desc = "Go: test" }))
    vim.keymap.set("n", "<leader>gc", "<cmd>GoCoverage<CR>", vim.tbl_extend("force", opts, { desc = "Go: coverage" }))
    vim.keymap.set("n", "<leader>gi", "<cmd>GoImports<CR>", vim.tbl_extend("force", opts, { desc = "Go: fix imports" }))
  end,
})

-- Format + fix imports on save.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("go_format_on_save", { clear = true }),
  pattern = "*.go",
  callback = function()
    if pcall(require, "go.format") then
      require("go.format").goimports()
    end
  end,
})
