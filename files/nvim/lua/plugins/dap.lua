-- Debugging. Adapters are installed through mason, but note that mason v2
-- has no `ensure_installed` of its own -- mason-nvim-dap provides it, and it
-- is used here as an installer only: every handler is neutered so the
-- language plugins below stay in charge of defining the adapters.
--
-- First run needs the adapters fetched once:
--   :DapInstall delve codelldb js python
-- Prompt for command-line arguments before launching, VSCode's "Run with
-- arguments". Returns the config unchanged if the user cancels.
local function with_args(config)
  local args_string = vim.fn.input("Run with args: ")
  config = vim.deepcopy(config)
  config.args = vim.split(vim.trim(args_string), " +", { trimempty = true })
  return config
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      { "theHamsta/nvim-dap-virtual-text", opts = {} },
      "jay-babu/mason-nvim-dap.nvim",
    },
    -- stylua: ignore
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>da", function() require("dap").continue({ before = with_args }) end, desc = "Continue with args" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down stack" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up stack" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
      -- VSCode-style function keys. <F2>/<F12> stay with the LSP (buffer-local).
      { "<F5>", function() require("dap").continue() end, desc = "Continue" },
      { "<S-F5>", function() require("dap").terminate() end, desc = "Terminate" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Step out" },
    },
    config = function()
      local dap = require("dap")

      -- Dracula-flavoured signs
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
      local signs = {
        Breakpoint = { "", "DiagnosticError" },
        BreakpointCondition = { "", "DiagnosticWarn" },
        BreakpointRejected = { "", "DiagnosticError" },
        LogPoint = { "", "DiagnosticInfo" },
        Stopped = { "", "DiagnosticWarn", "DapStoppedLine" },
      }
      for name, sign in pairs(signs) do
        vim.fn.sign_define("Dap" .. name, {
          text = sign[1],
          texthl = sign[2],
          linehl = sign[3],
          numhl = sign[3],
        })
      end

      -- Read .vscode/launch.json, comments and all
      local ok, json = pcall(require, "plenary.json")
      if ok then
        require("dap.ext.vscode").json_decode = function(str)
          return vim.json.decode(json.json_strip_comments(str))
        end
      end

      -- ---------------------------------------------------------------
      -- JS / TS. nvim-dap-vscode-js is dead (last release 2023), so the
      -- js-debug-adapter server is wired up by hand instead.
      -- ---------------------------------------------------------------
      for _, adapter in ipairs({ "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal" }) do
        dap.adapters[adapter] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "js-debug-adapter",
            args = { "${port}" },
          },
        }
      end
      -- launch.json files written for VSCode use the unprefixed names
      for _, adapter in ipairs({ "node", "chrome", "msedge" }) do
        dap.adapters[adapter] = function(cb, config)
          local native = config.type == "node" and "pwa-node" or ("pwa-" .. config.type)
          config.type = native
          local resolved = dap.adapters[native]
          if type(resolved) == "function" then
            resolved(cb, config)
          else
            cb(resolved)
          end
        end
      end

      local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
      local vscode = require("dap.ext.vscode")
      vscode.type_to_filetypes["node"] = js_filetypes
      vscode.type_to_filetypes["pwa-node"] = js_filetypes

      for _, ft in ipairs(js_filetypes) do
        dap.configurations[ft] = dap.configurations[ft] or {}
        table.insert(dap.configurations[ft], {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        })
        table.insert(dap.configurations[ft], {
          type = "pwa-node",
          request = "attach",
          name = "Attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        })
      end

      -- mason-nvim-dap runs last, once every adapter above exists
      require("mason-nvim-dap").setup({
        ensure_installed = { "delve", "codelldb", "js", "python" },
        automatic_installation = false,
        handlers = {
          delve = function() end,
          codelldb = function() end,
          js = function() end,
          python = function() end,
        },
      })
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dapui").toggle({}) end, desc = "Toggle debug UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Eval expression" },
    },
    opts = {},
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
      end
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason-org/mason.nvim" },
    cmd = { "DapInstall", "DapUninstall" },
    -- setup() is called from nvim-dap's config, after the adapters exist
    config = function() end,
  },

  {
    "leoluz/nvim-dap-go",
    ft = "go",
    opts = {},
  },

  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    -- stylua: ignore
    keys = {
      { "<leader>dpm", function() require("dap-python").test_method() end, ft = "python", desc = "Debug method" },
      { "<leader>dpc", function() require("dap-python").test_class() end, ft = "python", desc = "Debug class" },
    },
    config = function()
      -- Recent debugpy ships a `debugpy-adapter` executable, which avoids
      -- having to guess the right virtualenv python.
      require("dap-python").setup("debugpy-adapter")
    end,
  },
}
