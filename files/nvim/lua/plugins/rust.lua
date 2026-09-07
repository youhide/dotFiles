-- rustaceanvim replaces the plain rust_analyzer LSP setup. The deciding
-- reason is testing: neotest-rust was archived in 2025, so rustaceanvim's
-- own neotest adapter is the only maintained way to run Rust tests. It also
-- brings :RustLsp runnables/debuggables, which plain LSP cannot do.
--
-- It is configured through vim.g.rustaceanvim, NOT a setup() call, so lazy's
-- default `opts` handling would be a no-op here -- hence the explicit config.
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    ft = "rust",
    opts = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>cR", function()
            vim.cmd.RustLsp("codeAction")
          end, { buffer = bufnr, desc = "Rust code action" })
          -- <leader>dr is the dap REPL, so Rust debuggables take dR
          vim.keymap.set("n", "<leader>dR", function()
            vim.cmd.RustLsp("debuggables")
          end, { buffer = bufnr, desc = "Rust debuggables" })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true, buildScripts = { enable = true } },
            check = { command = "clippy" },
            procMacro = { enable = true },
            inlayHints = { closingBraceHints = { enable = false } },
          },
        },
      },
    },
    config = function(_, opts)
      -- llvm@22 ships no lldb, so mason's codelldb is the only source.
      local codelldb = vim.fn.exepath("codelldb")
      if codelldb ~= "" then
        local liblldb = vim.fn.expand("$MASON/packages/codelldb/extension/lldb/lib/liblldb.dylib")
        local ok, cfg = pcall(require, "rustaceanvim.config")
        if ok and vim.uv.fs_stat(liblldb) then
          opts.dap = { adapter = cfg.get_codelldb_adapter(codelldb, liblldb) }
        end
      end
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
    end,
  },
}
