-- nvim-treesitter is on the `main` branch (the rewrite). Its API is nothing
-- like the old one: `ensure_installed`, `highlight` and `indent` in `opts` are
-- silently ignored there. Parsers are installed with .install() and
-- highlighting is turned on per-buffer with vim.treesitter.start().
--
-- nvim 0.12 already bundles: c, lua, markdown, markdown_inline, query, vim,
-- vimdoc -- so those are not listed here.
local ensure = {
  "bash",
  "css",
  "diff",
  "dockerfile",
  "git_config",
  "git_rebase",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "hcl",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "make",
  "printf",
  "python",
  "regex",
  "rust",
  "scss",
  "sql",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "xml",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    priority = 900,
    config = function()
      require("nvim-treesitter").setup()

      -- Install anything missing, in the background.
      local installed = require("nvim-treesitter").get_installed()
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure)

      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end

      -- Turn on highlighting + indentation for every filetype that has a parser.
      local function ts_start(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
        if not lang or not vim.treesitter.language.add(lang) then
          return
        end
        pcall(vim.treesitter.start, buf, lang)
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("youhide_treesitter", { clear = true }),
        callback = function(event)
          ts_start(event.buf)
        end,
      })

      -- `nvim file.tsx` reads the file before this plugin loads, so the
      -- FileType autocmd above never fires for it. Catch those up.
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          ts_start(buf)
        end
      end
    end,
  },

  -- Context-aware commentstring, so gc works in JSX/TSX/Vue
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = false,
    opts = { enable_autocmd = false },
    config = function(_, opts)
      require("ts_context_commentstring").setup(opts)
      -- nvim 0.12's built-in gc reads this option
      local get = require("ts_context_commentstring.internal").calculate_commentstring
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold" }, {
        group = vim.api.nvim_create_augroup("youhide_commentstring", { clear = true }),
        callback = function()
          local ok, cs = pcall(get)
          if ok and cs then
            vim.bo.commentstring = cs
          end
        end,
      })
    end,
  },

  -- Sticky header showing the enclosing function/class
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = { max_lines = 3, multiline_threshold = 1 },
  },
}
