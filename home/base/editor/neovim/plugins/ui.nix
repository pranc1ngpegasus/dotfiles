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
        local incline_group = vim.api.nvim_create_augroup("incline_lazy_setup", { clear = true })
        vim.api.nvim_create_autocmd("UIEnter", {
          group = incline_group,
          once = true,
          callback = function()
            vim.defer_fn(function()
              require('incline').setup()
            end, 10)
          end,
        })
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
        local noice_group = vim.api.nvim_create_augroup("noice_lazy_setup", { clear = true })
        vim.api.nvim_create_autocmd("UIEnter", {
          group = noice_group,
          once = true,
          callback = function()
            vim.defer_fn(function()
              require("noice").setup()
            end, 10)
          end,
        })
      '';
    }
  ];
}
