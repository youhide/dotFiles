local buffer = require("util.buffer")
local close_buffer = buffer.close_buffer

-- Give every window showing `buf` the dashboard instead, then drop `buf`.
local function drop_buffer(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      buffer.show_empty(win)
    end
  end
  pcall(vim.api.nvim_buf_delete, buf, { force = true })
end

local function is_listed(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and not vim.bo[buf].modified
end

-- The path Neovim was started on, when that path is a directory.
local function is_directory_buffer(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return is_listed(buf) and name ~= "" and vim.fn.isdirectory(name) == 1
end

-- The nameless, empty buffer Neovim falls back to whenever it has nothing
-- else to put in a window. Harmless in itself; bufferline gives it a
-- `[No Name]` tab.
local function is_blank_buffer(buf)
  return is_listed(buf)
    and vim.api.nvim_buf_get_name(buf) == ""
    and vim.bo[buf].buftype == ""
    and vim.api.nvim_buf_line_count(buf) == 1
    and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
end

-- Neovim has no notion of "opening a directory": it makes a buffer named
-- after the path and leaves it there, which bufferline shows as a `project/`
-- tab. A file explorer is expected to take that buffer over, and neo-tree's
-- netrw hijack does not reliably win that race -- under Neovide it fires
-- late, long after the tab is on screen, and puts the buffer back after it
-- has been dropped. So the hijack is off (`hijack_netrw_behavior` below) and
-- this replaces it: the directory buffer's window gets the dashboard, the
-- buffer goes, and the tree opens on that directory.
local function open_directory_buffers()
  local dir
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_directory_buffer(buf) then
      dir = vim.api.nvim_buf_get_name(buf)
      drop_buffer(buf)
    end
  end
  if dir then
    vim.cmd("Neotree focus dir=" .. vim.fn.fnameescape(dir))
  end
end

-- Dropping the directory buffer can leave a blank one in its place, and when
-- that happens is a matter of how fast the UI comes up: under Neovide it can
-- turn up after the sweep above has already run. So this runs a few times
-- while the project is coming up. It is idempotent, and it only ever fires
-- during startup -- a blank buffer later on is one that was asked for. The
-- mode check is for the dashboard's `n` (New file), which makes exactly such
-- a buffer and leaves insert mode behind.
local function sweep_blank_buffers()
  if vim.fn.mode() ~= "n" then
    return
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_blank_buffer(buf) then
      drop_buffer(buf)
    end
  end
end

return {
  -- ---------------------------------------------------------------
  -- File explorer (Ctrl+B)
  -- ---------------------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Neotree",
    -- `nvim <dir>` -- what `v .` runs -- comes up as the project: tree on the
    -- left with the cursor in it, dashboard on the right, empty tabline.
    init = function()
      local group = vim.api.nvim_create_augroup("youhide_directory_buffer", { clear = true })

      -- BufEnter is what actually catches `nvim <dir>` -- it fires before
      -- VimEnter -- and it is also what catches an `:edit some/dir` later on.
      -- VimEnter is still needed for the blank-buffer sweep, which has to run
      -- whether or not a directory buffer was ever seen from here.
      vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function(event)
          local name = vim.api.nvim_buf_get_name(event.buf)
          if name ~= "" and vim.fn.isdirectory(name) == 1 then
            vim.schedule(open_directory_buffers)
          end
        end,
      })
      vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        once = true,
        callback = function()
          vim.schedule(function()
            open_directory_buffers()
            sweep_blank_buffers()
            vim.defer_fn(sweep_blank_buffers, 100)
            vim.defer_fn(sweep_blank_buffers, 400)
          end)
        end,
      })

      -- Make the directory the working dir, like `code .` does, so Ctrl+P,
      -- grep and the LSP root all point at the project.
      if vim.fn.argc(-1) == 1 then
        local path = vim.fn.argv(0)
        local stat = vim.uv.fs_stat(path)
        if stat and stat.type == "directory" then
          vim.cmd.cd(vim.fn.fnameescape(path))
        end
      end
    end,
    keys = {
      { "<C-b>", "<cmd>Neotree toggle<cr>", desc = "Toggle explorer" },
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle explorer" },
      { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal current file" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      window = {
        position = "left",
        width = 32,
        mappings = {
          ["<space>"] = "none", -- leader stays leader
          ["l"] = "open",
          ["h"] = "close_node",
          ["<C-b>"] = "close_window",
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        bind_to_cwd = false,
        hijack_netrw_behavior = "disabled", -- see open_directory_buffers above
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = { ".DS_Store", ".git" },
        },
      },
      default_component_configs = {
        indent = { with_expanders = true },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "✖",
            renamed = "󰁕",
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          },
        },
      },
    },
  },

  -- ---------------------------------------------------------------
  -- Buffer tabs
  -- ---------------------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local s = {}
          if diag.error then
            s[#s + 1] = " " .. diag.error
          end
          if diag.warning then
            s[#s + 1] = " " .. diag.warning
          end
          return table.concat(s, " ")
        end,
        separator_style = "slant",
        always_show_bufferline = true,
        close_command = close_buffer,
        right_mouse_command = close_buffer,
        show_buffer_close_icons = true,
        show_close_icon = false,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    },
  },

  -- ---------------------------------------------------------------
  -- Statusline
  -- ---------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        theme = "dracula-nvim",
        globalstatus = true,
        component_separators = "",
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "neo-tree", "dashboard" } },
      },
      sections = {
        lualine_a = { { "mode", separator = { left = "" } } },
        lualine_b = { "branch" },
        lualine_c = {
          { "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = " " } },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = "  ", readonly = " ", unnamed = "" } },
        },
        lualine_x = {
          { "diff", symbols = { added = " ", modified = " ", removed = " " } },
        },
        lualine_y = { "progress" },
        lualine_z = { { "location", separator = { right = "" } } },
      },
      extensions = { "neo-tree", "lazy", "mason", "toggleterm", "quickfix" },
    },
  },

  -- ---------------------------------------------------------------
  -- Indent guides
  -- ---------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = {
          "help",
          "neo-tree",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "checkhealth",
          "dashboard",
          "man",
        },
      },
    },
  },

  -- ---------------------------------------------------------------
  -- Prettier notifications / inputs / cmdline
  -- ---------------------------------------------------------------
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true }, -- disable heavy features on huge files
      indent = { enabled = false }, -- indent-blankline handles this
      input = { enabled = true }, -- nice vim.ui.input
      notifier = { enabled = true, timeout = 2500 },
      quickfile = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = true }, -- highlight other refs of word under cursor
      dashboard = {
        enabled = true,
        preset = {
          header = [[
      .__    .__    .___     ________          __
      |  |__ |__| __| _/____ \_____  \  __ ___/  |_
      |  |  \|  |/ __ |/ __ \ /   |   \|  |  \   __\
      |   Y  \  / /_/ \  ___//    |    \  |  /|  |
      |___|  /__\____ |\___  >_______  /____/ |__|
           \/        \/    \/        \/
]],
          keys = {
            { icon = " ", key = "f", desc = "Find file", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New file", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Grep text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
            },
            { icon = " ", key = "s", desc = "Restore session", section = "session" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
  },

  -- ---------------------------------------------------------------
  -- Markdown rendering
  -- (this config used to be pasted inside treesitter's opts, where it
  --  was silently discarded)
  -- ---------------------------------------------------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      render_modes = { "n", "c" },
      heading = {
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
      },
      checkbox = {
        checked = { icon = " " },
        unchecked = { icon = " " },
      },
    },
  },
}
