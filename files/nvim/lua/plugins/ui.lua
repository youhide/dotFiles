-- Closing a buffer must never take Neovim down with it, and must not throw
-- away unsaved work. bufferline's default is a bare `bdelete!`, which force-
-- discards changes and leaves nothing behind when it was the last file.
local function close_buffer(bufnr)
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
    -- `nvim <dir>` must show the tree. netrw is disabled, so without this the
    -- directory just opens as an empty unnamed buffer.
    init = function()
      if vim.fn.argc(-1) == 1 then
        local path = vim.fn.argv(0)
        local stat = vim.uv.fs_stat(path)
        if stat and stat.type == "directory" then
          -- Make the directory the working dir, like `code .` does, so
          -- Ctrl+P, grep and the LSP root all point at the project.
          vim.cmd.cd(vim.fn.fnameescape(path))
          require("neo-tree")
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
        hijack_netrw_behavior = "open_default",
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
