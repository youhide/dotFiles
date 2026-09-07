return {
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000, -- load before everything else
    opts = {
      -- Match the iTerm2 Dracula profile exactly
      colors = {
        bg = "#1e1f29",
      },
      transparent_bg = false,
      italic_comment = true,
      lualine_bg_color = "#44475a",
      overrides = function(colors)
        return {
          -- Softer, less shouty diagnostics underline
          DiagnosticUnderlineError = { undercurl = true, sp = colors.red },
          DiagnosticUnderlineWarn = { undercurl = true, sp = colors.yellow },
          DiagnosticUnderlineInfo = { undercurl = true, sp = colors.cyan },
          DiagnosticUnderlineHint = { undercurl = true, sp = colors.cyan },
          -- Keep the gutter the same shade as the editor background
          SignColumn = { bg = colors.bg },
          LineNr = { fg = colors.comment },
          CursorLineNr = { fg = colors.purple, bold = true },
          -- Rounded float borders in the Dracula purple
          FloatBorder = { fg = colors.purple, bg = colors.bg },
          NormalFloat = { bg = colors.bg },
        }
      end,
    },
    config = function(_, opts)
      require("dracula").setup(opts)
      vim.cmd.colorscheme("dracula")
    end,
  },
}
