{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
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
                },
              },
            })
          end,
        })
      '';
    }
  ];
}
