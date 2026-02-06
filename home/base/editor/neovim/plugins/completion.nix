{pkgs, ...}: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
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
  ];
}
