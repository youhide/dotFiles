local function augroup(name)
  return vim.api.nvim_create_augroup("youhide_" .. name, { clear = true })
end

-- Flash the text you just yanked
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

-- Reopen a file where you left off
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_position"),
  callback = function(event)
    local exclude = { "gitcommit", "gitrebase" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_pos then
      return
    end
    vim.b[buf].last_pos = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Optional autosave when the terminal loses focus. OFF by default: writing
-- a file you did not ask to write is surprising, and it used to also fire on
-- every buffer switch. Turn it on with :lua vim.g.autosave = true
vim.g.autosave = false
vim.api.nvim_create_autocmd("FocusLost", {
  group = augroup("autosave"),
  callback = function(event)
    if not vim.g.autosave then return end
    local buf = event.buf
    if vim.bo[buf].modified and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      vim.api.nvim_buf_call(buf, function() vim.cmd("silent! write") end)
    end
  end,
})

-- Pick up external changes when focus returns
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
})

-- Close scratch-ish windows with plain `q`
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help", "man", "qf", "lspinfo", "checkhealth", "startuptime",
    "notify", "query", "gitsigns-blame",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Resize splits when the terminal window changes size
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

-- Create missing parent directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_mkdir"),
  callback = function(event)
    if event.match:match("^%w%w+://") or vim.bo[event.buf].buftype ~= "" then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Wrap for prose. Spell check is off by default: with only the English
-- dictionary installed it underlines every Portuguese word, and asking for a
-- language whose .spl file is missing makes Neovim warn on every buffer.
--   <leader>us          toggle spell for this buffer
--   :lua vim.g.spell_langs = "en,pt"   after installing the pt dictionary
vim.g.spell_langs = vim.g.spell_langs or "en"

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("prose"),
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})

vim.keymap.set("n", "<leader>us", function()
  if not vim.wo.spell then
    -- Only ask for languages whose .spl actually exists, so this never warns.
    local ok = {}
    for lang in vim.gsplit(vim.g.spell_langs, ",", { trimempty = true }) do
      lang = vim.trim(lang)
      if #vim.api.nvim_get_runtime_file("spell/" .. lang .. ".*.spl", true) > 0 then
        ok[#ok + 1] = lang
      end
    end
    if #ok == 0 then
      return vim.notify("No spell dictionary installed", vim.log.levels.WARN)
    end
    vim.opt_local.spelllang = table.concat(ok, ",")
  end
  vim.wo.spell = not vim.wo.spell
  vim.notify("Spell " .. (vim.wo.spell and "on (" .. vim.o.spelllang .. ")" or "off"))
end, { desc = "Toggle spell check" })
