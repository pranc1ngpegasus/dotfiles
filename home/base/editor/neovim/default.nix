{pkgs, ...}: {
  home.packages = with pkgs; [
    gopls
    nil
    rust-analyzer
    typescript-language-server
  ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    extraConfig = ''
      " options
      set autoread
      set background=dark
      set clipboard=unnamed
      set cmdheight=0
      set cursorcolumn
      set cursorline
      set encoding=UTF-8
      set expandtab
      set ignorecase
      set inccommand=split
      set incsearch
      set laststatus=0
      set nobackup
      set noshowmode
      set noswapfile
      set number
      set scrolloff=1000
      set shiftround
      set shiftwidth=2
      set smartcase
      set smartindent
      set tabstop=2
      set termguicolors
      set wrapscan

      " netrw
      let g:netrw_liststyle = 3
      let g:netrw_preview = 1
      let g:netrw_sizestyle = "H"
      let g:netrw_timefmt = "%Y/%m/%d(%a) %H:%M:%S"

      " truecolor
      if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
      endif
    '';
    extraLuaConfig = ''
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
    plugins = with pkgs.vimPlugins; [
      # theme
      {
        plugin = iceberg-vim;
        type = "viml";
        config = ''
          colorscheme iceberg
        '';
      }
      # show key bindings
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          vim.keymap.set('n', '<leader>?', '<cmd>lua require("which-key").show({global = false})<CR>')
        '';
      }
      # statusline
      {
        plugin = incline-nvim;
        type = "lua";
        config = ''
          require('incline').setup()
        '';
      }
      # notify
      {
        plugin = nvim-notify;
        type = "lua";
        config = ''
          require("notify").setup({
            max_width = 50,
            render = "wrapped-compact",
            stages = "slide",
            timeout = 1500,
          })
        '';
      }
      nui-nvim
      {
        plugin = noice-nvim;
        type = "lua";
        config = ''
          require("noice").setup()
        '';
      }
      # completion
      {
        plugin = copilot-lua;
        type = "lua";
        config = ''
          require("copilot").setup({
            suggestion = {
              enabled = false,
            },
            panel = {
              enabled = false,
            },
          })
        '';
      }
      blink-cmp-copilot
      {
        plugin = blink-cmp;
        type = "lua";
        config = ''
          require('blink-cmp').setup({
            completion = {
              accept = {
                auto_brackets = {
                  enabled = true,
                },
              },
              documentation = {
                auto_show = true,
                auto_show_delay_ms = 500,
              },
              keyword = {
                range = 'full',
              },
              list = {
                selection = {
                  preselect = false,
                  auto_insert = true,
                },
              },
              menu = {
                auto_show = true,
              },
              ghost_text = {
                enabled = true,
              },
            },
            keymap = {
              preset = 'default',
            },
            signature = {
              enabled = true,
            },
            sources = {
              default = {
                'lsp',
                'path',
                'snippets',
                'buffer',
                'copilot',
              },
              providers = {
                copilot = {
                  name = "copilot",
                  module = "blink-cmp-copilot",
                  score_offset = 100,
                  async = true,
                },
              },
            },
          })
        '';
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local servers = {"rust_analyzer", "gopls", "ts_ls", "nil_ls"};
          local opt = {
            on_attach = function(client, bufnr)
              local opts = { noremap = true, silent = true }
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gc', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'go', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gf', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
              vim.cmd 'autocmd BufWritePre * lua vim.lsp.buf.format({ async = false, timeout_ms = 1000 })'
            end,
            capabilities = require('blink-cmp').get_lsp_capabilities()
          }

          for _, server in ipairs(servers) do
            require('lspconfig')[server].setup(opt)
          end
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
          require("gitlinker").setup()
        '';
      }
    ];
  };
}
