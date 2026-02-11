{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = copilot-lua;
      type = "lua";
      config = ''
        local copilot_group = vim.api.nvim_create_augroup("copilot_lazy_setup", { clear = true })
        vim.api.nvim_create_autocmd("InsertEnter", {
          group = copilot_group,
          once = true,
          callback = function()
            require("copilot").setup({
              suggestion = {
                enabled = false,
              },
              panel = {
                enabled = false,
              },
            })
          end,
        })
      '';
    }
    blink-cmp-copilot
    {
      plugin = blink-cmp;
      type = "lua";
      config = ''
        local blink_group = vim.api.nvim_create_augroup("blink_cmp_lazy_setup", { clear = true })
        vim.api.nvim_create_autocmd("InsertEnter", {
          group = blink_group,
          once = true,
          callback = function()
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
          end,
        })
      '';
    }
  ];
}
