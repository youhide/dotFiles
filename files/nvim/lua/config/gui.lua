-- Neovide, the GUI the shell's `v` opens (files/shell/9_functions.sh).
-- Everything here is a no-op in a terminal: vim.g.neovide is set by the GUI.
if not vim.g.neovide then
  return
end

-- Same font and grid the iTerm2 "Neovim" profile used before Neovide.
vim.o.guifont = "JetBrainsMono Nerd Font Mono:h13"
vim.o.linespace = 1

vim.g.neovide_theme = "dark" -- the colorscheme is Dracula; never follow macOS
vim.g.neovide_opacity = 1.0 -- the old profile had Transparency 0, Blur off
-- `v` passes --grid=160x44 on every launch, so remembering a size would only
-- fight it. Resize freely; the next `v` starts from 160x44 again.
vim.g.neovide_remember_window_size = false
vim.g.neovide_padding_top = 8
vim.g.neovide_padding_bottom = 8
vim.g.neovide_padding_left = 8
vim.g.neovide_padding_right = 8

vim.g.neovide_cursor_animation_length = 0.08
vim.g.neovide_cursor_trail_size = 0.5
vim.g.neovide_scroll_animation_length = 0.2
vim.g.neovide_hide_mouse_when_typing = true

-- The iTerm2 profile translated Alt+Arrow into Esc-prefixed sequences by hand.
-- Here the left Option key has to be Meta, or <A-Up> and friends never arrive
-- (config/keymaps.lua: move and duplicate lines).
vim.g.neovide_input_macos_option_key_is_meta = "only_left"

local map = vim.keymap.set

-- iTerm2 handled Cmd+C / Cmd+V natively; Neovide binds nothing by default.
map({ "n", "v" }, "<D-c>", '"+y', { desc = "Copy" })
map("v", "<D-x>", '"+d', { desc = "Cut" })
map({ "n", "i", "v", "t" }, "<D-v>", function()
  vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end, { desc = "Paste" })
map("c", "<D-v>", "<C-r>+", { desc = "Paste" })

-- Zoom, like every other macOS app.
local function zoom(by)
  vim.g.neovide_scale_factor = math.min(math.max((vim.g.neovide_scale_factor or 1) * by, 0.6), 3)
end
map("n", "<D-=>", function()
  zoom(1.1)
end, { desc = "Zoom in" })
map("n", "<D-->", function()
  zoom(1 / 1.1)
end, { desc = "Zoom out" })
map("n", "<D-0>", function()
  vim.g.neovide_scale_factor = 1
end, { desc = "Reset zoom" })
