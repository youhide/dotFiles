local map = vim.keymap.set

-- ============================================================
--  VSCode / Sublime style (Ctrl). Cmd equivalents are mapped in
--  the iTerm2 "Neovim" dynamic profile, which sends these same keys.
-- ============================================================

-- Save (needs `stty -ixon`, set in files/shell/3_aliases.sh)
map({ "n", "i", "v", "s" }, "<C-s>", "<cmd>silent! write<cr>", { desc = "Save file" })

-- Select all
map("n", "<C-a>", "ggVG", { desc = "Select all" })
map("i", "<C-a>", "<Esc>ggVG", { desc = "Select all" })
-- (vim's increment lives on <C-a>; it is still reachable via g<C-a> in visual)

-- Comment. nvim 0.12 ships gc/gcc natively; these just add the VSCode key.
-- Terminals send Ctrl+/ as 0x1f (<C-_>); iTerm2 with CSI-u may send <C-/>.
map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<C-_>", "gc", { remap = true, desc = "Toggle comment" })
map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })

-- Move lines (Alt+Up/Down). Requires iTerm2 Option = Esc+.
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Duplicate line (VSCode: Shift+Alt+Down)
map("n", "<A-S-Down>", "<cmd>t.<cr>", { desc = "Duplicate line" })
map("v", "<A-S-Down>", ":t'><cr>gv", { desc = "Duplicate selection" })

-- Indent without losing the selection
map("v", "<Tab>", ">gv", { desc = "Indent" })
map("v", "<S-Tab>", "<gv", { desc = "Outdent" })
map("n", "<S-Tab>", "<<", { desc = "Outdent" })

-- ============================================================
--  Editing comfort
-- ============================================================

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear highlight" })

-- Keep cursor centered when jumping
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
map("n", "<C-f>", "<C-f>zz", { desc = "Page down" })
-- <C-b> is NOT mapped here: it belongs to the file explorer (plugins/ui.lua).
-- Page up is <C-u> / <PageUp>.

-- Paste over selection without clobbering the register
map("v", "p", '"_dP', { desc = "Paste (keep register)" })

-- Move by visual line when wrapped
map({ "n", "v" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Undo break-points: makes undo granular while typing
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- ============================================================
--  Windows / splits
-- ============================================================
-- C-h/j/k/l are owned by vim-tmux-navigator (see plugins/editor.lua)
map("n", "<leader>|", "<C-w>v", { desc = "Split right" })
map("n", "<leader>-", "<C-w>s", { desc = "Split below" })
map("n", "<leader>wd", "<C-w>c", { desc = "Close split" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Taller" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Shorter" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Narrower" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Wider" })

-- ============================================================
--  Buffers (bufferline)
-- ============================================================
-- <C-w> is left alone: it is vim's window prefix. Cmd+W closes a buffer
-- (mapped in the iTerm2 profile to <leader>bd).
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "<leader>bd", "<cmd>lua require('bufferline').unpin_and_close()<cr>", { desc = "Close buffer" })
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close other buffers" })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Pin buffer" })

-- ============================================================
--  Diagnostics
-- ============================================================
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })

-- ============================================================
--  Misc
-- ============================================================
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>m", "<cmd>Mason<cr>", { desc = "Mason" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ============================================================
--  Cmd (⌘) keys — iTerm2 "Neovim" profile only
--
--  The profile's Keyboard Map turns each ⌘ combo into a CSI-u escape
--  sequence with the "super" bit set (e.g. ⌘P -> ESC[112;9u). nvim 0.12
--  decodes that as <D-p>, so these work in a plain terminal -- no GUI
--  needed. They do NOT work through tmux (tmux has no super bit), which
--  is fine: the profile launches nvim directly. Use the Ctrl keys there.
--  ⌘C / ⌘V are deliberately unmapped so iTerm2 keeps native copy/paste.
-- ============================================================
map({ "n", "i", "v", "s" }, "<D-s>", "<Esc><cmd>write<cr>", { desc = "Save file" })
map({ "n", "i", "v" }, "<D-p>", "<Esc><cmd>Telescope find_files<cr>", { desc = "Find file" })
map({ "n", "i", "v" }, "<D-P>", "<Esc><cmd>Telescope commands<cr>", { desc = "Command palette" })
map({ "n", "i", "v" }, "<D-F>", "<Esc><cmd>Telescope live_grep<cr>", { desc = "Grep project" })
map("n", "<D-f>", "/", { desc = "Search in file" })
map({ "n", "i", "v" }, "<D-b>", "<Esc><cmd>Neotree toggle<cr>", { desc = "Toggle explorer" })
map({ "n", "i", "v" }, "<D-w>", "<Esc><cmd>lua require('bufferline').unpin_and_close()<cr>", { desc = "Close buffer" })
map("n", "<D-a>", "ggVG", { desc = "Select all" })
map("i", "<D-a>", "<Esc>ggVG", { desc = "Select all" })
map("n", "<D-z>", "u", { desc = "Undo" })
map("i", "<D-z>", "<C-o>u", { desc = "Undo" })
map("n", "<D-Z>", "<C-r>", { desc = "Redo" })
map("n", "<D-/>", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<D-/>", "gc", { remap = true, desc = "Toggle comment" })
map({ "n", "i" }, "<D-`>", "<Esc><cmd>ToggleTerm direction=float<cr>", { desc = "Toggle terminal" })
