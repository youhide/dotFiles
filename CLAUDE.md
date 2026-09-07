# CLAUDE.md

Personal dotfiles. `files/` is the source of truth; everything in `$HOME` is a
symlink into it.

## Layout and linking

Symlinks are declared in `hidedot.conf.yaml` and created by [hideDot]. Adding a
newly managed file means adding a `link:` entry there, not running `ln -s`.
Preview with `hidedot --dry-run` before `hidedot`.

`~/.config/nvim` -> `files/nvim`. Edit through `files/`; never move or replace a
symlink target.

`files/iterm2/com.googlecode.iterm2.plist` is a backup, deliberately not linked
(iTerm2 rewrites it constantly).

## Neovim

Neovim 0.12, macOS only. Plugin manager is lazy.nvim; one file per area under
`lua/plugins/`.

Things that are easy to get wrong here:

- **nvim-treesitter is on `branch = "main"`** (the rewrite). `ensure_installed`,
  `highlight` and `indent` in `opts` are silently ignored. Parsers install via
  `require("nvim-treesitter").install()`, highlighting via
  `vim.treesitter.start()`. See `lua/plugins/treesitter.lua`.
- **LSP uses native `vim.lsp.config()` / `vim.lsp.enable()`.** Never write
  `require("lspconfig").x.setup{}`.
- **mason is v2 and has no `ensure_installed` option.** LazyVim implements that
  itself; copying the pattern here does nothing. Use `mason-lspconfig` or
  `mason-nvim-dap`'s `ensure_installed`, or `:MasonInstall`.
- **`rust_analyzer` belongs to rustaceanvim** (`lua/plugins/rust.lua`) and is in
  `mason-lspconfig`'s `automatic_enable.exclude`. Removing it from the `servers`
  table is not enough on its own -- the mason package stays installed and
  `automatic_enable` would start a second client.
- **rustaceanvim is configured through `vim.g.rustaceanvim`,** not `setup()`, so
  lazy's default `opts` handling is a no-op for it.
- **lazy.nvim's `checker` is disabled on purpose.** `lazy-lock.json` lives in a
  git working tree and auto-checks left the repo permanently dirty. Update
  deliberately with `:Lazy update` and commit the lockfile.
- **Format-on-save and autosave are off by default,** behind `vim.g.autoformat`
  and `vim.g.autosave`. This is intentional; do not "fix" it.
- **Debug adapters are not installed automatically.** First run needs
  `:DapInstall delve codelldb js python`.
- **The GUI is Neovide** (`brew install --cask neovide-app`), opened by the `v`
  shell function. It does not start Neovim from an interactive shell, so
  `files/shell/4_paths.sh` never runs for it -- anything Neovim needs on `PATH`
  goes through `prepend_path()` in `lua/config/options.lua`. Neovide-only
  settings belong in `lua/config/gui.lua`, which returns early unless
  `vim.g.neovide` is set.

### Keymaps

There are two parallel sets: `Ctrl` works everywhere, `<D-...>` (Cmd) only
inside Neovide, which passes macOS's Cmd combos straight through. A plain
terminal never sends them, and they never survive tmux. `<D-c>`/`<D-v>`/`<D-x>`
and the zoom keys live in `lua/config/gui.lua`, the rest in
`lua/config/keymaps.lua`.

Leader namespace, to avoid collisions:

```
a ai          b buffer      c code        d debug      e/E explorer
f find        g git         h hunk        m multicursor  o open
q session     t test        u toggle      w window     x diagnostics
M Mason       | - splits    / search
```

Free: `n p r s v y z`.

A direct mapping must never share a key with a group prefix -- it stalls for
`timeoutlen` on every press and kills the which-key label. `:checkhealth
which-key` reports overlaps and duplicates; it should stay clean.

### Style

Lua is formatted with stylua (`.stylua.toml`, 2-space, 120 cols). Run
`stylua files/nvim` before committing. Use `-- stylua: ignore` above dense
one-line-per-mapping `keys` tables.

## Shell

`files/shell/` is numbered `1_` to `9_` and sourced in order by `zshrc`.
Secrets are lazy: `load_secrets` / `unload_secrets` / `list_secrets`, backed by
`pass`. nvm, terraform completions and brew prefixes are all lazily resolved or
cached, so keep startup work out of these files.

[hideDot]: https://github.com/youhide/hideDot
