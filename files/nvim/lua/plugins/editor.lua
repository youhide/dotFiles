return {
  -- ---------------------------------------------------------------
  -- Seamless nvim <-> tmux pane navigation (C-h/j/k/l).
  -- The tmux side is the matching plugin in tmux.conf.
  -- ---------------------------------------------------------------
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left split/pane" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to below split/pane" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to above split/pane" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right split/pane" },
    },
  },

  -- ---------------------------------------------------------------
  -- Multi-cursor. Ctrl+D adds a cursor at the next occurrence, like
  -- VSCode. Vim's half-page-down stays available on <C-u>/<C-f>.
  -- ---------------------------------------------------------------
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      -- <C-d> in the terminal, <D-d> in the iTerm2 "Neovim" profile.
      for _, key in ipairs({ "<C-d>", "<D-d>" }) do
        vim.keymap.set({ "n", "v" }, key, function()
          mc.matchAddCursor(1)
        end, { desc = "Add cursor at next match" })
      end

      vim.keymap.set({ "n", "v" }, "<C-S-d>", function()
        mc.matchSkipCursor(1)
      end, { desc = "Skip this match" })

      vim.keymap.set({ "n", "v" }, "<leader>mk", function()
        mc.lineAddCursor(-1)
      end, { desc = "Add cursor above" })

      vim.keymap.set({ "n", "v" }, "<leader>mj", function()
        mc.lineAddCursor(1)
      end, { desc = "Add cursor below" })

      vim.keymap.set({ "n", "v" }, "<leader>ma", mc.matchAllAddCursors, { desc = "Add cursor to all matches" })

      -- Esc clears the extra cursors
      mc.addKeymapLayer(function(layer)
        layer({ "n", "v" }, "<Esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
    end,
  },

  -- ---------------------------------------------------------------
  -- Auto-close brackets/quotes, and HTML/JSX tags
  -- ---------------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true, fast_wrap = {} },
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascriptreact", "typescriptreact", "xml", "markdown" },
    opts = {},
  },

  -- ---------------------------------------------------------------
  -- Surround: cs"' ds" ysiw"
  -- ---------------------------------------------------------------
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {},
  },

  -- ---------------------------------------------------------------
  -- Keybinding hints after pressing <leader>
  -- ---------------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>a", group = "ai" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>dp", group = "python" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunk" },
        { "<leader>m", group = "multicursor" },
        { "<leader>o", group = "open" },
        { "<leader>q", group = "session" },
        { "<leader>t", group = "test" },
        { "<leader>u", group = "toggle" },
        { "<leader>w", group = "window" },
        { "<leader>x", group = "diagnostics" },
        { "<leader>e", desc = "Toggle explorer" },
        { "<leader>E", desc = "Reveal current file" },
        { "<leader>l", desc = "Lazy" },
        { "<leader>M", desc = "Mason" },
        { "<leader>|", desc = "Split right" },
        { "<leader>-", desc = "Split below" },
      },
    },
  },

  -- ---------------------------------------------------------------
  -- Terminal (Ctrl+\ toggles; Ctrl+` is not reliably deliverable
  -- by terminals, see README)
  -- ---------------------------------------------------------------
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { [[<C-\>]], desc = "Toggle terminal" },
      { "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Split terminal" },
    },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
      float_opts = { border = "rounded" },
      shade_terminals = false,
      start_in_insert = true,
    },
  },

  -- ---------------------------------------------------------------
  -- Highlight TODO / FIXME / NOTE
  -- ---------------------------------------------------------------
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
    },
    opts = {},
  },
}
