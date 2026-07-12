return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "css",
        "dockerfile",
        "gitignore",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "sql",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },

      highlight = {
        enable = true,
      },

      indent = {
        enable = true,
      },

      opts = {
        render_modes = { "n", "c" },
        heading = {
          icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
        },
        checkbox = {
          checked = {
            icon = " ",
          },
          unchecked = {
            icon = " ",
          },
        },
      }
    },
  },
}
