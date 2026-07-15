{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gopls
    nil
    rust-analyzer
    typescript-language-server
  ];

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    withPython3 = false;
    withRuby = false;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = iceberg-vim;
        type = "viml";
        config = ''
          colorscheme iceberg
          highlight StatusLine cterm=NONE ctermbg=235 ctermfg=242 gui=NONE guibg=#1e2132 guifg=#6b7089
          highlight StatusLineNC cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#17171b guifg=#444b71
          highlight! link StatusLineTerm StatusLine
          highlight! link StatusLineTermNC StatusLineNC
        '';
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local format_group = vim.api.nvim_create_augroup("user_lsp_format_on_save", { clear = false })

          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(ev)
              local client = vim.lsp.get_client_by_id(ev.data.client_id)
              if client and client:supports_method("textDocument/completion") then
                vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
              end

              vim.api.nvim_clear_autocmds({ group = format_group, buffer = ev.buf })
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = format_group,
                buffer = ev.buf,
                callback = function()
                  vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
                end,
              })
            end,
          })

          vim.lsp.enable({ "rust_analyzer", "gopls", "ts_ls", "nil_ls" })
        '';
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          vim.keymap.set('n', '<Space><Space>', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
          vim.keymap.set('n', '<C-f>', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
        '';
      }
      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          bash
          go
          gomod
          gosum
          gowork
          javascript
          json
          lua
          markdown
          markdown_inline
          nix
          rust
          toml
          tsx
          typescript
          vim
          vimdoc
          yaml
        ]
      ))
      {
        plugin = gitlinker-nvim;
        type = "lua";
        config = ''
          require("gitlinker").setup()
        '';
      }
    ];
    initLua = ''
      pcall(function()
        vim.loader.enable()
      end)

      -- options
      vim.opt.clipboard = "unnamed"
      vim.opt.cmdheight = 0
      vim.opt.cursorcolumn = true
      vim.opt.cursorline = true
      vim.opt.expandtab = true
      vim.opt.ignorecase = true
      vim.opt.inccommand = "split"
      vim.opt.laststatus = 3
      vim.opt.showmode = false
      vim.opt.swapfile = false
      vim.opt.number = true
      vim.opt.scrolloff = 1000
      vim.opt.shiftround = true
      vim.opt.shiftwidth = 2
      vim.opt.smartcase = true
      vim.opt.smartindent = true
      vim.opt.tabstop = 2
      vim.opt.termguicolors = true

      -- completion
      vim.o.pumborder = "rounded"
      vim.opt.completeopt = { "menu", "menuone", "noselect", "fuzzy", "popup" }
    '';
  };
}
