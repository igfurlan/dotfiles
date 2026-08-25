-- Rust, via rustaceanvim (which starts rust-analyzer itself -- no lspconfig
-- setup needed, and rust_analyzer is excluded from mason's automatic_enable).
--
-- Fixes vs the article:
--   * it does `local bufnr = vim.api.nvim_get_current_buf()` at FILE scope, so
--     every buffer-local keymap is bound to whatever buffer existed at startup
--     (usually buffer 1) instead of the Rust buffer. Uses args.buf here.
--   * `vim.cmd('explainError')` is not a command; it is vim.cmd.RustLsp('explainError').
--   * the DAP key is `stopAtBeginningOfMainSubprogram`, not
--     `stopAtBegginingOfMainSubProgram` (which nvim-dap silently ignores).

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("rust_keymaps", { clear = true }),
  pattern = "rust",
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "<leader>rr", ":RustLsp run<CR>",
      vim.tbl_extend("force", opts, { desc = "Rust: run" }))
    vim.keymap.set("n", "<leader>ca", function() vim.cmd.RustLsp("codeAction") end,
      vim.tbl_extend("force", opts, { desc = "Rust: code action" }))
    vim.keymap.set("n", "<leader>K", function() vim.cmd.RustLsp({ "hover", "actions" }) end,
      vim.tbl_extend("force", opts, { desc = "Rust: hover actions" }))
    vim.keymap.set("n", "<leader>e", function() vim.cmd.RustLsp("explainError") end,
      vim.tbl_extend("force", opts, { desc = "Rust: explain error" }))
    vim.keymap.set("n", "<leader>dr", function() vim.cmd.RustLsp("debuggables") end,
      vim.tbl_extend("force", opts, { desc = "Rust: debuggables" }))
  end,
})

-- gdb debug adapter (requires gdb >= 14 for the `-i dap` interface).
local ok, dap = pcall(require, "dap")
if not ok then return end

dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "-i", "dap" },
}

dap.configurations.rust = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
}

vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "DAP: toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end, { desc = "DAP: continue" })
vim.keymap.set("n", "<leader>ds", function() require("dap").step_over() end, { desc = "DAP: step over" })
vim.keymap.set("n", "<leader>di", function() require("dap").step_into() end, { desc = "DAP: step into" })
