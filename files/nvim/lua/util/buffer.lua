local M = {}

-- Which buffer a window should fall back to once `bufnr` is gone: the nearest
-- listed neighbour, so closing a tab lands on the one beside it, the order
-- bufferline draws them in.
local function neighbour(bufnr)
  local before, after
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= bufnr and vim.bo[b].buflisted and vim.api.nvim_buf_is_loaded(b) then
      if b < bufnr then
        before = b
      elseif not after then
        after = b
      end
    end
  end
  return after or before
end

-- What a window should show when there is no file left to put in it: the
-- dashboard, the same thing a bare `nvim` and `v .` start on. Its buffer is
-- unlisted, so the tabline goes empty -- a plain empty buffer here would be
-- listed and sit in the tabline as a `[No Name]` tab whose X can never close
-- it, since closing it only ever creates the next one.
function M.show_empty(win)
  local ok, dashboard = pcall(function()
    return Snacks.dashboard.open({ win = win })
  end)
  if ok and dashboard and vim.api.nvim_buf_is_valid(dashboard.buf) then
    return dashboard.buf
  end

  -- snacks missing or disabled: an unlisted but still editable buffer.
  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_win_set_buf(win, buf)
  return buf
end

-- Closing a buffer must never take Neovim down with it, and must not throw
-- away unsaved work. bufferline's default is a bare `bdelete!`, which force-
-- discards changes and leaves nothing behind when it was the last file.
--
-- Every close path goes through here: bufferline's close button and right
-- click (plugins/ui.lua), <leader>bd and <D-w> (config/keymaps.lua).
function M.close_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if vim.bo[bufnr].modified then
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
    local answer =
      vim.fn.confirm("Save changes to " .. (name ~= "" and name or "[No Name]") .. "?", "&Yes\n&No\n&Cancel", 1)
    if answer == 1 then
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("write")
      end)
    elseif answer ~= 2 then
      return
    end
  end

  -- nvim_buf_delete *closes* every window showing the buffer -- unlike
  -- `:bdelete`, which keeps the window and puts another buffer in it. Paired
  -- with neo-tree's close_if_last_window that took the whole session down:
  -- the file window closed, the tree was left as the last window, closed
  -- itself, and Neovim exited. So give those windows another buffer first --
  -- the dashboard when this was the last file open.
  local replacement = neighbour(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      if replacement then
        vim.api.nvim_win_set_buf(win, replacement)
      else
        replacement = M.show_empty(win)
      end
    end
  end

  pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
end

return M
