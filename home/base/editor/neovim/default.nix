{
  lib,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      set ambiwidth=double
      set autoread
      set background=dark
      set clipboard=unnamed
      set cursorcolumn
      set cursorline
      set encoding=UTF-8
      set expandtab
      set ignorecase
      set inccommand=split
      set incsearch
      set laststatus=3
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
      set title
      set wrapscan

      " netrw
      let g:netrw_liststyle = 3
      let g:netrw_preview = 1
      let g:netrw_sizestyle = "H"
      let g:netrw_timefmt = "%Y/%m/%d(%a) %H:%M:%S"

      " disable sql completion
      let g:loaded_sql_completion = 0

      " use ripgrep as vimgrep
      if executable('rg')
        set grepprg=rg\ --vimgrep\ --no-heading
        set grepformat=%f:%l:%c:%m,%f:%l:%m
      endif

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
      {
        plugin = iceberg-vim;
        type = "viml";
        config = ''
          colorscheme iceberg
          set background=dark
        '';
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
            require('lualine').setup({
              options = {
                theme = 'iceberg_dark'
              },
          sections = {
            lualine_c = { 'lsp_progress' },
            lualine_x = { 'copilot', 'encoding', 'fileformat', 'filetype' },
          },
            })
        '';
      }
      lualine-lsp-progress
      {
        plugin = mason-nvim;
        type = "lua";
        config = ''
          require("mason").setup()
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
            fuzzy = {
              use_typo_resistance = true,
              use_frecency = true,
              use_proximity = true,
              sorts = { 'score', 'sort_text' },
            },
            keymap = {
              preset = 'default',
              ['<Tab>'] = { 'select_and_accept' },
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
        plugin = mason-lspconfig-nvim;
        type = "lua";
        config = ''
          require('mason-lspconfig').setup()
          require('mason-lspconfig').setup_handlers({ function(server)
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
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                vim.cmd 'autocmd BufWritePre * lua vim.lsp.buf.format({ async = false, timeout_ms = 1000 })'
              end,
              capabilities = require('blink-cmp').get_lsp_capabilities()
            }
            require('lspconfig')[server].setup(opt)
          end })
        '';
      }
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      nvim_context_vt
      nvim-treesitter-textobjects
      {
        plugin = nvim-notify;
        type = "lua";
        config = ''
          vim.notify = require("notify")
        '';
      }
      {
        plugin = fzf-vim;
        type = "viml";
        config = ''
          let g:fzf_layout = { 'down': '~40%' }
          command! -bang -nargs=* Rg call fzf#vim#grep('rg --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)
          noremap <C-f> :Rg<CR>
          noremap <Space><Space> :FZF<CR>
        '';
      }
      auto-pairs
      vim-sandwich
      {
        plugin = gitlinker-nvim;
        type = "lua";
        config = ''
          require("gitlinker").setup()
        '';
      }
    ];
    vimAlias = true;
  };
}