{...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        color_scheme = "iceberg-dark";
        font_size = 17.0;
        harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
        hide_tab_bar_if_only_one_tab = true,
        keys = {
          { mods = "CTRL", key = "q", action=wezterm.action{ SendString="\x11" } },
        },
        tab_bar_at_bottom = true,
      }
    '';
  };
}
