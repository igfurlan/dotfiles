local ok, builtin = pcall(require, "telescope.builtin")
if not ok then return end

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope: find files" })
vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Telescope: git files" })
vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string({ search = vim.fn.input(":Grep > ") })
end, { desc = "Telescope: grep for input" })
