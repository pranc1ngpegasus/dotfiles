{pkgs, ...}: {
  programs = {
    neovim = {
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

        " use ripgrep as vimgrep
        if executable('rg')
        	set grepprg=rg\ --vimgrep\ --no-heading
        	set grepformat=%f:%l:%c:%m,%f:%l:%m
        endif
      '';
      extraPackages = with pkgs; [
        gcc
        gnumake
      ];
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
              }
            })
          '';
        }
        {
          plugin = mason-nvim;
          type = "lua";
          config = ''
            require("mason").setup()
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
                capabilities = require('cmp_nvim_lsp').default_capabilities()
              }
              require('lspconfig')[server].setup(opt)
            end })
          '';
        }
        {
          plugin = nvim-cmp;
          type = "lua";
          config = ''
            vim.cmd([[set completeopt=menu,menuone,noselect]])

            local cmp = require('cmp')
            cmp.setup({
              snippet = {
                expand = function(args)
                  vim.fn["vsnip#anonymous"](args.body)
                end,
              },
              window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
              },
              mapping = {
                ['<C-n>'] = function(fallback)
                  if not cmp.select_next_item() then
                    if vim.bo.buftype ~= 'prompt' and has_words_before() then
                      cmp.complete()
                    else
                      fallback()
                    end
                  end
                end,
                ['<C-p>'] = function(fallback)
                  if not cmp.select_prev_item() then
                    if vim.bo.buftype ~= 'prompt' and has_words_before() then
                      cmp.complete()
                    else
                      fallback()
                    end
                  end
                end,
                ['<Tab>'] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.confirm()
                  else
                    fallback() -- If you use vim-endwise, this fallback will behave the same as vim-endwise.
                  end
                end, { 'i', 'c' }),
              },
              sources = cmp.config.sources({
                { name = "copilot", group_index = 2 },
                { name = 'nvim_lsp' },
                { name = 'omni' },
                { name = 'nvim_lsp_signature_help' },
                { name = 'treesitter' },
                { name = 'vsnip' },
              }, {
                { name = 'buffer' },
              }),
              experimental = {
                ghost_text = true,
              },
            })

            cmp.setup.cmdline('/', {
              mapping = cmp.mapping.preset.cmdline(),
              sources = {
                { name = "copilot", group_index = 2 },
                { name = 'buffer' }
              },
            })

            cmp.setup.cmdline(':', {
              mapping = cmp.mapping.preset.cmdline(),
              sources = cmp.config.sources({
                { name = "copilot", group_index = 2 },
                { name = 'path' }
              }, {
                { name = 'cmdline' }
              }),
            })
          '';
        }
        nvim-lspconfig
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        cmp-omni
        cmp-nvim-lsp-signature-help
        cmp-treesitter
        cmp-vsnip
        vim-vsnip
        copilot-cmp
        nvim-treesitter.withAllGrammars
        nvim_context_vt
        {
          plugin = vim-terraform;
          type = "viml";
          config = ''
            autocmd FileType terraform autocmd BufWritePre * :TerraformFmt
          '';
        }
        vim-toml
        vim-graphql
        {
          plugin = fzf-vim;
          type = "viml";
          config = ''
            let g:fzf_layout = { 'down': '~40%' }
            command! -bang -nargs=* Rg call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)
            noremap <C-f> :Rg<CR>
            noremap <Space><Space> :FZF<CR>
          '';
        }
        # fzfWrapper
        auto-pairs
        {
          plugin = nvim-notify;
          type = "lua";
          config = ''
            vim.notify = require("notify")
          '';
        }
        editorconfig-vim
        {
          plugin = copilot-lua;
          type = "lua";
          config = ''
            require('copilot').setup()
          '';
        }
        {
          plugin = copilot-cmp;
          type = "lua";
          config = ''
            require('copilot_cmp').setup()
          '';
        }
      ];
      vimAlias = true;
    };
  };
}
