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

      -- options
      local o = vim.opt
      o.autoread       = true
      o.background     = "dark"
      o.clipboard      = "unnamed"
      o.cmdheight      = 0
      o.cursorcolumn   = true
      o.cursorline     = true
      o.encoding       = "UTF-8"
      o.expandtab      = true
      o.ignorecase     = true
      o.inccommand     = "split"
      o.incsearch      = true
      o.laststatus     = 0
      o.backup         = false
      o.showmode       = false
      o.swapfile       = false
      o.number         = true
      o.scrolloff      = 1000
      o.shiftround     = true
      o.shiftwidth     = 2
      o.smartcase      = true
      o.smartindent    = true
      o.tabstop        = 2
      o.termguicolors  = true
      o.wrapscan       = true

      -- netrw
      vim.g.netrw_liststyle = 3
      vim.g.netrw_preview   = 1
      vim.g.netrw_sizestyle  = "H"
      vim.g.netrw_timefmt   = "%Y/%m/%d(%a) %H:%M:%S"

      -- truecolor support in tmux/screen
      if not vim.g.gui_running and vim.env.TERM and vim.env.TERM:match("^screen") or vim.env.TERM and vim.env.TERM:match("^tmux") then
        vim.cmd([[let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"]])
        vim.cmd([[let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"]])
      end
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
          local lsp_format_group = vim.api.nvim_create_augroup("LspFormat", { clear = true })

          local servers = {"rust_analyzer", "gopls", "ts_ls", "nil_ls"}
          local opt = {
            on_attach = function(client, bufnr)
              local opts = { buffer = bufnr, noremap = true, silent = true }
              vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, opts)
              vim.keymap.set('n', 'gc', vim.lsp.buf.incoming_calls, opts)
              vim.keymap.set('n', 'go', vim.lsp.buf.outgoing_calls, opts)
              vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
              vim.keymap.set('n', 'gf', vim.lsp.buf.references, opts)
              vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
              vim.keymap.set('n', 'gr', vim.lsp.buf.rename, opts)

              if client.supports_method("textDocument/formatting") then
                vim.api.nvim_create_autocmd("BufWritePre", {
                  group = lsp_format_group,
                  buffer = bufnr,
                  callback = function()
                    vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
                  end,
                })
              end
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
      (nvim-treesitter.withPlugins (p:
        with p; [
          bash
          css
          dockerfile
          go
          gomod
          gosum
          html
          javascript
          json
          lua
          make
          markdown
          nix
          rust
          toml
          tsx
          typescript
          yaml
        ]))
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
