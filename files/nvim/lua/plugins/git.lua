return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      current_line_blame = false,
      current_line_blame_opts = { delay = 400, virt_text_pos = "eol" },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map("n", "]h", function()
          gs.nav_hunk("next")
        end, "Next hunk")
        map("n", "[h", function()
          gs.nav_hunk("prev")
        end, "Prev hunk")
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<cr>", "Stage hunk")
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<cr>", "Reset hunk")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>hd", gs.diffthis, "Diff this")
        map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle line blame")
      end,
    },
  },

  -- lazygit inside nvim
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitFilter" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  -- ---------------------------------------------------------------
  -- Diffs, file history, and 3-way conflict resolution.
  -- The merge tool IS the conflict resolver: opening a conflicted file
  -- during a merge/rebase gives <leader>co/ct/cb/ca (ours/theirs/base/all),
  -- cO/cT/cB/cA for the whole file, dx to drop a region, and [x / ]x to
  -- navigate. Those are buffer-local, so <leader>ca (code action) is
  -- shadowed inside merge buffers only.
  -- ---------------------------------------------------------------
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      enhanced_diff_hl = true,
      view = { merge_tool = { layout = "diff3_mixed" } },
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (this file)" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "File history (branch)" },
    },
  },
}
