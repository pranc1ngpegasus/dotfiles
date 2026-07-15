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
      nvim-treesitter.withAllGrammars
      {
        plugin = gitlinker-nvim;
        type = "lua";
        config = ''
          local gitlinker_group = vim.api.nvim_create_augroup("gitlinker_lazy_setup", { clear = true })
          vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
            group = gitlinker_group,
            once = true,
            callback = function()
              require("gitlinker").setup()
            end,
          })
        '';
      }
    ];
    initLua = ''
      pcall(function()
        vim.loader.enable()
      end)

      -- options
      vim.opt.autoread = true
      vim.opt.background = "dark"
      vim.opt.clipboard = "unnamed"
      vim.opt.cmdheight = 0
      vim.opt.cursorcolumn = true
      vim.opt.cursorline = true
      vim.opt.encoding = "UTF-8"
      vim.opt.expandtab = true
      vim.opt.ignorecase = true
      vim.opt.inccommand = "split"
      vim.opt.incsearch = true
      vim.opt.laststatus = 3
      vim.opt.backup = false
      vim.opt.showmode = false
      vim.opt.swapfile = false
      vim.opt.number = true
      vim.opt.ruler = true
      vim.opt.scrolloff = 1000
      vim.opt.shiftround = true
      vim.opt.shiftwidth = 2
      vim.opt.smartcase = true
      vim.opt.smartindent = true
      vim.opt.tabstop = 2
      vim.opt.termguicolors = true
      vim.opt.wrapscan = true

      -- completion
      vim.o.pumborder = "rounded"
      vim.opt.completeopt = { "menu", "menuone", "noselect", "fuzzy", "popup" }

      -- disable unnecessary built-in plugins
      vim.g.did_indent_on             = 1
      vim.g.did_install_default_menus = 1
      vim.g.did_install_syntax_menu   = 1
      vim.g.did_load_ftplugin         = 1
      vim.g.loaded_2html_plugin       = 1
      vim.g.loaded_getscript          = 1
      vim.g.loaded_getscriptPlugin    = 1
      vim.g.loaded_gzip               = 1
      vim.g.loaded_man                = 1
      vim.g.loaded_matchit            = 1
      vim.g.loaded_matchparen         = 1
      vim.g.loaded_remote_plugins     = 1
      vim.g.loaded_rrhelper           = 1
      vim.g.loaded_shada_plugin       = 1
      vim.g.loaded_spellfile_plugin   = 1
      vim.g.loaded_sql_completion     = 1
      vim.g.loaded_tar                = 1
      vim.g.loaded_tarPlugin          = 1
      vim.g.loaded_tutor_mode_plugin  = 1
      vim.g.loaded_vimball            = 1
      vim.g.loaded_vimballPlugin      = 1
      vim.g.loaded_zip                = 1
      vim.g.loaded_zipPlugin          = 1
      vim.g.skip_loading_mswin        = 1
    '';
  };
}
