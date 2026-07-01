{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = telescope-nvim;
      type = "lua";
      config = ''
        vim.keymap.set('n', '<Space><Space>', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<C-f>', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
      '';
    }
    {
      plugin = nvim-tree-lua;
      type = "lua";
      config = ''
        require("nvim-tree").setup({
          disable_netrw = true,
          hijack_netrw = true,
          hijack_directories = {
            enable = true,
            auto_open = true,
          },
          update_focused_file = {
            enable = true,
          },
          view = {
            width = 36,
            side = "left",
          },
          renderer = {
            add_trailing = true,
            decorators = {},
            group_empty = false,
            highlight_git = "none",
            indent_markers = {
              enable = true,
              inline_arrows = false,
              icons = {
                corner = "|",
                edge = "|",
                item = "|",
                bottom = " ",
                none = " ",
              },
            },
            icons = {
              symlink_arrow = " -> ",
              web_devicons = {
                file = {
                  enable = false,
                },
                folder = {
                  enable = false,
                },
              },
              show = {
                file = false,
                folder = false,
                folder_arrow = false,
                git = false,
                modified = false,
                hidden = false,
                diagnostics = false,
                bookmarks = false,
              },
            },
          },
          filters = {
            dotfiles = false,
          },
          git = {
            enable = false,
            ignore = false,
          },
        })

        vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle file tree" })
        vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeFindFile<CR>", { noremap = true, silent = true, desc = "Reveal file in tree" })
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
}
