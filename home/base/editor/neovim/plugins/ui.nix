{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = iceberg-vim;
      type = "viml";
      config = ''
        colorscheme iceberg
      '';
    }
    {
      plugin = which-key-nvim;
      type = "lua";
      config = ''
        vim.keymap.set('n', '<leader>?', '<cmd>lua require("which-key").show({global = false})<CR>')
      '';
    }
    {
      plugin = incline-nvim;
      type = "lua";
      config = ''
        require('incline').setup()
      '';
    }
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
  ];
}
