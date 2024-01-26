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
vim.o.ambiwidth                 = "double"
vim.o.autoread                  = true
vim.o.background                = "dark"
vim.o.clipboard                 = "unnamed"
vim.o.cursorcolumn              = true
vim.o.cursorline                = true
vim.o.encoding                  = "UTF-8"
vim.o.expandtab                 = true
vim.o.ignorecase                = true
vim.o.inccommand                = "split"
vim.o.incsearch                 = true
vim.o.laststatus                = 3
vim.o.backup                    = false
vim.o.showmode                  = false
vim.o.swapfile                  = false
vim.o.number                    = true
vim.o.scrolloff                 = 1000
vim.o.shiftround                = true
vim.o.shiftwidth                = 2
vim.o.smartcase                 = true
vim.o.smartindent               = true
vim.o.tabstop                   = 2
vim.o.termguicolors             = true
vim.o.title                     = true
vim.o.wrapscan                  = true

-- netrw
vim.g.netrw_liststyle           = 3
vim.g.netrw_preview             = 1
vim.g.netrw_sizestyle           = "H"
vim.g.netrw_timefmt             = "%Y/%m/%d(%a) %H:%M:%S"

-- use ripgrep for :grep
vim.cmd([[
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
  endif
]])

-- lazy.vim setup
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
  {
    "cocopon/iceberg.vim",
    event = "VeryLazy",
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "AndreM222/copilot-lualine",
    },
    opts = function()
      return {
        options = {
          theme = "auto"
        },
        sections = {
          lualine_x = { 'copilot' ,'encoding', 'fileformat', 'filetype' },
        },
      }
    end,
  },
  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    event = "VeryLazy",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = false,
        },
        panel = {
          enabled = false,
        },
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "VeryLazy",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-omni",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "ray-x/cmp-treesitter",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      {
        "zbirenbaum/copilot-cmp",
        config = function()
          require("copilot_cmp").setup()
        end,
      },
    },
    config = function()
      vim.cmd([[set completeopt=menu,menuone,noselect]])

      local cmp = require("cmp")
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
          ["<C-n>"] = function(fallback)
            if not cmp.select_next_item() then
              if vim.bo.buftype ~= "prompt" and has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end
          end,
          ["<C-p>"] = function(fallback)
            if not cmp.select_prev_item() then
              if vim.bo.buftype ~= "prompt" and has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end
          end,
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm()
            else
              fallback()
            end
          end, { "i", "c" }),
        },
        sources = cmp.config.sources({
          { name = "copilot" },
          { name = "nvim_lsp" },
          { name = "omni" },
          { name = "nvim_lsp_signature_help" },
          { name = "treesitter" },
          { name = "vsnip" },
        }, {
          { name = "buffer" },
        }),
        experimental = {
          ghost_text = true,
        },
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "copilot", group_index = 2 },
          { name = "buffer" }
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "copilot", group_index = 2 },
          { name = "path" }
        }, {
          { name = "cmdline" }
        }),
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    config = function()
      require("mason-lspconfig").setup()
      require("mason-lspconfig").setup_handlers({
        function(server)
          local opt = {
            on_attach = function(client, bufnr)
              local opts = { noremap = true, silent = true }
              vim.api.nvim_buf_set_keymap(bufnr, "n", "ca",
                "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
              vim.api.nvim_buf_set_keymap(bufnr, "n", "gc",
                "<cmd>lua vim.lsp.buf.incoming_calls()<CR>", opts)
              vim.api.nvim_buf_set_keymap(bufnr, "n", "go",
                "<cmd>lua vim.lsp.buf.outgoing_calls()<CR>", opts)
              vim.api.nvim_buf_set_keymap(bufnr, "n", "gd",
                "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
              vim.api.nvim_buf_set_keymap(bufnr, "n", "gf",
                "<cmd>lua vim.lsp.buf.references()<CR>", opts)
              vim.api.nvim_buf_set_keymap(bufnr, "n", "gi",
                "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
              vim.api.nvim_buf_set_keymap(bufnr, "n", "gr",
                "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
              vim.api.nvim_buf_set_keymap(bufnr, "n", "K",
                "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
              vim.cmd "autocmd BufWritePre * lua vim.lsp.buf.format({ async = false, timeout_ms = 1000 })"
            end,
            capabilities = require("cmp_nvim_lsp").default_capabilities()
          }
          require("lspconfig")[server].setup(opt)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    dependencies = {
      "andersevenrud/nvim_context_vt",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
    },
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    opts = {
      timeout = 1500,
    },
  },
  {
    "ibhagwan/fzf-lua",
    keys = {
      {
        "<Space><Space>",
        "<cmd>lua require('fzf-lua').files()<CR>",
      },
      {
        "<C-f>",
        "<cmd>lua require('fzf-lua').grep_project()<CR>",
      },
    },
    config = function()
      require("fzf-lua").setup({
        winopts = {
          height = 0.4,
          width = 1.0,
          row = 1,
          col = 0.5,
        },
        fzf_opts = {
          ["--layout"] = "reverse-list",
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "iceberg",
    },
  },
}
local opts = {}

require("lazy").setup(plugins, opts)
