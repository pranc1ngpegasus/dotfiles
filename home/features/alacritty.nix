{...}: {
  programs.alacritty = {
    enable = true;
    settings = {
      liveConfigReload = true;
      window = {
        opacity = 1.0;
      };
      font = {
        size = 16.0;
        normal = {
          family = "JetBrainsMono Nerd Font";
        };
      };
      keyBindings = [
        {
          key = "Q";
          mods = "Control";
          action = "\\x11";
        }
      ];
    };
  };
}
