-- nvim 0.11+ has native vim.lsp.config() / vim.lsp.enable(). nvim-lspconfig
-- 2.x ships each server's defaults as lsp/<name>.lua, which those natives
-- pick up automatically -- no require("lspconfig").x.setup{} anymore.

local servers = {
  -- TypeScript / JS / React
  vtsls = {
    settings = {
      typescript = {
        updateImportsOnFileMove = { enabled = "always" },
        inlayHints = {
          parameterNames = { enabled = "literals" },
          variableTypes = { enabled = false },
          functionLikeReturnTypes = { enabled = true },
        },
      },
      vtsls = {
        experimental = { completion = { enableServerSideFuzzyMatch = true } },
      },
    },
  },
  eslint = {},
  tailwindcss = {},

  -- Web
  html = {},
  cssls = {},
  jsonls = {},
  yamlls = {
    settings = { yaml = { keyOrdering = false } },
  },
  emmet_language_server = {},

  -- Systems
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        check = { command = "clippy" },
        inlayHints = { closingBraceHints = { enable = false } },
      },
    },
  },
  gopls = {
    settings = {
      gopls = {
        analyses = { unusedparams = true },
        staticcheck = true,
        gofumpt = true,
      },
    },
  },

  -- Scripting / infra
  pyright = {
    settings = {
      python = {
        analysis = { typeCheckingMode = "basic", autoSearchPaths = true },
      },
    },
  },
  ruff = {},
  bashls = {},
  dockerls = {},
  terraformls = {},
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        codeLens = { enable = true },
        hint = { enable = true },
        diagnostics = { globals = { "vim", "Snacks" } },
        telemetry = { enable = false },
      },
    },
  },
}

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },
      { "mason-org/mason-lspconfig.nvim" },
      { "b0o/schemastore.nvim" }, -- JSON/YAML schemas
    },
    config = function()
      -- ---------- diagnostics ----------
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          prefix = "●",
          source = "if_many",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
      })

      -- ---------- schemas ----------
      servers.jsonls.settings = {
        json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
      }
      servers.yamlls.settings.yaml.schemas = require("schemastore").yaml.schemas()

      -- ---------- register + enable ----------
      for name, cfg in pairs(servers) do
        vim.lsp.config(name, cfg)
      end

      require("mason").setup({ ui = { border = "rounded" } })
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = true,
      })

      -- ---------- on attach ----------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("youhide_lsp_attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local function nmap(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
          end

          -- nvim 0.12 already provides: K (hover), grn (rename), gra (code
          -- action), grr (references), gri (implementation), grt (type def).
          -- These are the extras.
          nmap("gd", vim.lsp.buf.definition, "Go to definition")
          nmap("gD", vim.lsp.buf.declaration, "Go to declaration")
          nmap("<leader>cr", vim.lsp.buf.rename, "Rename")
          nmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
          nmap("<F2>", vim.lsp.buf.rename, "Rename") -- VSCode
          nmap("<F12>", vim.lsp.buf.definition, "Definition") -- VSCode
          vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = buf, desc = "Signature help" })

          -- Inlay hints, toggleable
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
            nmap("<leader>uh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "Toggle inlay hints")
          end

          -- Highlight other references of the symbol under the cursor
          if client and client:supports_method("textDocument/documentHighlight") then
            local hl = vim.api.nvim_create_augroup("youhide_lsp_hl", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = hl,
              buffer = buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = hl,
              buffer = buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end,
  },
}
