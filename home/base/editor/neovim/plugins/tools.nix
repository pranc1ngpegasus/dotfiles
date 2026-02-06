{pkgs, ...}: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = telescope-nvim;
      type = "lua";
      config = ''
        vim.keymap.set('n', '<Space><Space>', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<C-f>', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
      '';
    }
    nvim-treesitter.withAllGrammars
    {
      plugin = gitlinker-nvim;
      type = "lua";
      config = ''
        require("gitlinker").setup()
      '';
    }
  ];
}
