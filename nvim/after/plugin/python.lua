-- Python REPL integration: open a terminal running python3, then send the
-- current line, the visual selection, or everything up to the cursor to it.
--
-- Same behaviour as the article's python.lua, with the helpers kept local
-- instead of leaking OpenTerminalBuffer/SendToTerminal as globals, and with a
-- guard against picking a dead terminal buffer.

local function open_terminal(cmd)
  vim.cmd("belowright split | term")
  local term_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_chan_send(vim.api.nvim_get_option_value("channel", { buf = term_buf }), cmd .. "\r")
end

-- Move the cursor to the next line that starts at column 0 (i.e. the next
-- top-level statement), so repeated sends walk through the file.
local function next_top_level_line()
  local current = vim.api.nvim_win_get_cursor(0)[1]
  local total = vim.api.nvim_buf_line_count(0)
  for i = current + 1, total do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    if line and line:match("^%S") then
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      return
    end
  end
end

local function find_terminal()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_is_loaded(buf) then
      local ok, chan = pcall(vim.api.nvim_get_option_value, "channel", { buf = buf })
      if ok and chan and chan > 0 then
        return buf, chan
      end
    end
  end
end

---@param mode "selection"|"to_cursor"|"line"
local function send_to_terminal(mode)
  local text
  if mode == "selection" then
    vim.cmd('normal! gv"xy')
    text = vim.fn.getreg("x")
    vim.api.nvim_exec2(":'>", {})
  elseif mode == "to_cursor" then
    local ln = vim.api.nvim_win_get_cursor(0)[1]
    text = table.concat(vim.api.nvim_buf_get_lines(0, 0, ln, false), "\n")
  else
    text = vim.api.nvim_get_current_line()
  end

  next_top_level_line()

  local _, chan = find_terminal()
  if not chan then
    vim.notify("No terminal buffer found -- open one with <leader><leader>py", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_chan_send(chan, text .. "\r")
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("python_repl", { clear = true }),
  pattern = "python",
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "<leader><leader>py", function() open_terminal("python3") end,
      vim.tbl_extend("force", opts, { desc = "Python: open REPL" }))
    vim.keymap.set({ "v", "x" }, "<BSlash>d", function() send_to_terminal("selection") end,
      vim.tbl_extend("force", opts, { desc = "Python: send selection to REPL" }))
    vim.keymap.set("n", "<BSlash>d", function() send_to_terminal("line") end,
      vim.tbl_extend("force", opts, { desc = "Python: send line to REPL" }))
    vim.keymap.set("n", "<BSlash>aa", function() send_to_terminal("to_cursor") end,
      vim.tbl_extend("force", opts, { desc = "Python: send up to cursor to REPL" }))
  end,
})
