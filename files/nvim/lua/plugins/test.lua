-- Test runner. Adapters are constructed explicitly here rather than through
-- a generic resolver, because the set is known up front.
--
-- neotest-golang v2 needs the Go parser from nvim-treesitter's `main` branch,
-- which this config already uses (plugins/treesitter.lua).
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "fredrikaverpil/neotest-golang", version = "*" },
      "nvim-neotest/neotest-python",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
    },
    -- stylua: ignore
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run tests in file" },
      { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run all tests" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run last test" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop test" },
      { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle watch" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
    },
    config = function()
      -- neotest-golang is a callable module, not a table -- calling it is
      -- required, and the single most common neotest setup mistake.
      local adapters = {
        require("neotest-golang")({
          go_test_args = { "-v", "-race", "-count=1" },
        }),
        require("neotest-python")({ runner = "pytest" }),
        require("neotest-vitest"),
        require("neotest-jest")({ jestCommand = "npm test --" }),
      }

      -- Rust tests come from rustaceanvim (plugins/rust.lua)
      local ok, rust = pcall(require, "rustaceanvim.neotest")
      if ok then
        table.insert(adapters, rust)
      end

      require("neotest").setup({
        adapters = adapters,
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = {
          open = function()
            local has_trouble, trouble = pcall(require, "trouble")
            if has_trouble then
              trouble.open({ mode = "quickfix", focus = false })
            else
              vim.cmd("copen")
            end
          end,
        },
      })
    end,
  },
}
