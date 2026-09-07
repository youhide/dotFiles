local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"        -- always reserve gutter, text never jumps
opt.cursorline = true

-- Indentation: 2 spaces, no tabs
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.breakindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true          -- capital letter in query -> case sensitive
opt.hlsearch = true
opt.incsearch = true
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"

-- System clipboard (pbcopy on macOS)
opt.clipboard = "unnamedplus"

-- Mouse: select, scroll, resize splits by dragging
opt.mouse = "a"
opt.mousemoveevent = true
opt.mousescroll = "ver:2,hor:4"

-- Shift+Arrow selects, like every other editor. selectmode="" means it starts
-- VISUAL (not SELECT), so vim operators still work on the selection.
opt.keymodel = "startsel,stopsel"
opt.selectmode = ""

-- Splits open where you expect
opt.splitright = true
opt.splitbelow = true

-- Persistent undo: survives closing the file
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false

-- UI
opt.termguicolors = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.showmode = false          -- lualine already shows it
opt.laststatus = 3            -- one global statusline
opt.cmdheight = 1
opt.pumheight = 12
opt.winborder = "rounded"     -- nvim 0.11+: rounded floats everywhere
opt.fillchars = { eob = " " }
opt.list = true
opt.listchars = { tab = "› ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }
opt.conceallevel = 2          -- render-markdown needs >= 2
opt.splitkeep = "screen"
opt.shortmess:append("cCI")   -- no completion noise, no intro screen

-- Timing
opt.updatetime = 200
opt.timeoutlen = 400

-- Behaviour
opt.confirm = true            -- ask instead of failing on unsaved quit
opt.autoread = true
opt.completeopt = "menu,menuone,noselect"
opt.virtualedit = "block"
opt.inccommand = "split"      -- live preview of :substitute
opt.jumpoptions = "view"

-- Folding via treesitter, but open by default
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldtext = ""

-- Disable unused providers (faster startup, cleaner :checkhealth)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

-- Node is lazy-loaded via nvm in zsh, so nvim does not inherit it.
-- Resolve the nvm default and put it on PATH for Mason / node-based LSPs.
local function nvm_bin()
  local nvm = vim.env.HOME .. "/.nvm"
  local alias = vim.fn.readfile(nvm .. "/alias/default")[1]
  if not alias then return nil end
  -- alias may be "node", "lts/*" or a concrete version
  local dir = nvm .. "/versions/node/" .. alias .. "/bin"
  if vim.fn.isdirectory(dir) == 1 then return dir end
  local versions = vim.fn.glob(nvm .. "/versions/node/*/bin", false, true)
  table.sort(versions)
  return versions[#versions]
end

local function prepend_path(dir)
  if dir and vim.uv.fs_stat(dir) and not (":" .. vim.env.PATH .. ":"):find(":" .. dir .. ":", 1, true) then
    vim.env.PATH = dir .. ":" .. vim.env.PATH
  end
end

local ok, bin = pcall(nvm_bin)
if ok and bin then prepend_path(bin) end

-- gopls and golangci-lint live here but the shell never puts it on PATH
prepend_path(vim.env.HOME .. "/go/bin")
prepend_path(vim.env.HOME .. "/.local/bin")
