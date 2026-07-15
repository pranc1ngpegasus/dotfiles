{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = iceberg-vim;
      type = "viml";
      config = ''
        colorscheme iceberg
        highlight StatusLine cterm=NONE ctermbg=235 ctermfg=242 gui=NONE guibg=#1e2132 guifg=#6b7089
        highlight StatusLineNC cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#17171b guifg=#444b71
        highlight! link StatusLineTerm StatusLine
        highlight! link StatusLineTermNC StatusLineNC
      '';
    }
  ];
}
