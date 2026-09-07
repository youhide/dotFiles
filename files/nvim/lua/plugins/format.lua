return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    init = function()
      vim.g.autoformat = false
    end,
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
      {
        "<leader>uf",
        function()
          vim.g.autoformat = not vim.g.autoformat
          vim.notify("Format on save " .. (vim.g.autoformat and "ON" or "OFF"))
        end,
        desc = "Toggle format on save",
      },
    },
    opts = {
      formatters_by_ft = {
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        rust = { "rustfmt" },
        go = { "goimports", "gofumpt" },
        python = { "ruff_organize_imports", "ruff_format" },
        lua = { "stylua" },
        sh = { "shfmt" },
        terraform = { "terraform_fmt" },
        hcl = { "terraform_fmt" },
      },
      -- Format-on-save is OFF by default, same as VSCode. With it on, saving a
      -- JS/TS file in a project that has no prettier config reformats the whole
      -- file to prettier's defaults, which makes enormous diffs.
      --   <leader>cf  format now
      --   <leader>uf  toggle format-on-save for this session
      format_on_save = function(bufnr)
        if not vim.g.autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
    },
  },
}
