local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  -- colorscheme
  {
    'cocopon/iceberg.vim',
    lazy = false,
    config = function()
      vim.cmd([[colorscheme iceberg]])
      vim.cmd([[set background=dark]])
    end
  },
  -- statusline
  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    config = function()
      require('lualine').setup({
        options = {
          theme = 'iceberg_dark'
        }
      })
    end
  },
  -- Language Server
  {
    'williamboman/mason.nvim',
    config = function()
      require("mason").setup()
    end
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
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
    end
  },
  {
    'hrsh7th/nvim-cmp',
    config = function()
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
    end,
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-omni',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'ray-x/cmp-treesitter',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
      'zbirenbaum/copilot-cmp',
    },
    event = "InsertEnter",
  },
  -- tree-sitter
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup({
        auto_install = true,
      })
    end,
    event = "InsertEnter",
  },
  {
    'haringsrob/nvim_context_vt',
    event = "InsertEnter",
  },
  -- syntax
  {
    'cespare/vim-toml',
    lazy = true,
    ft = { 'toml' },
  },
  {
    'hashivim/vim-terraform',
    lazy = true,
    ft = { 'terraform', 'tf' },
  },
  {
    'jparise/vim-graphql',
    lazy = true,
    ft = { 'graphql', 'graphqls', 'gql' },
  },
  {
    'vim-scripts/dbext.vim',
    lazy = true,
    ft = { 'sql' },
  },
  -- util
  {
    'lotabout/skim.vim',
    config = function()
      vim.cmd([[let g:skim_layout = { 'down': '~40%' }]])
      -- vim.cmd([[command! -bang -nargs=* Rg call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)]])
    end,
    dependencies = {
      'lotabout/skim',
    },
    keys = {
      {"<C-f>", "<cmd>Rg<CR>"},
      {"<Space><Space>", "<cmd>SK<CR>"},
    },
  },
  {
    'knsh14/vim-github-link',
  },
  {
    'jiangmiao/auto-pairs',
  },
  {
    'rcarriga/nvim-notify',
    config = function()
      vim.notify = require("notify")
    end
  },
  {
    'editorconfig/editorconfig-vim'
  },
  {
    'zbirenbaum/copilot.lua',
    config = function()
      require('copilot').setup()
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    after = {
      'copilot.lua'
    },
    config = function ()
      require('copilot_cmp').setup()
    end
  },
}

require("lazy").setup(plugins)
