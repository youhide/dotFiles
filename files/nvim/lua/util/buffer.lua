local M = {}

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

  -- If this was the last listed buffer, put an empty one in its windows first,
  -- so deleting it cannot close the last window and exit Neovim.
  local others = vim.tbl_filter(function(b)
    return b ~= bufnr and vim.bo[b].buflisted and vim.api.nvim_buf_is_loaded(b)
  end, vim.api.nvim_list_bufs())

  if #others == 0 then
    local empty = vim.api.nvim_create_buf(true, false)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == bufnr then
        vim.api.nvim_win_set_buf(win, empty)
      end
    end
  end

  pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
end

return M
