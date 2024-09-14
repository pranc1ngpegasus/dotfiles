{...}: {
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary = {
          background = "0x16171E";
          foreground = "0xD1D2D3";
        };
        cursor = {
          text = "0xFEFFFF";
          cursor = "0xc7c7c7";
        };
        normal = {
          black = "#161821";
          red = "#e27878";
          green = "#b4be82";
          yellow = "#e2a478";
          blue = "#84a0c6";
          magenta = "#a093c7";
          cyan = "#89b8c2";
          white = "#c6c8d1";
        };
        bright = {
          black = "#6b7089";
          red = "#e98989";
          green = "#c0ca8e";
          yellow = "#e9b189";
          blue = "#91acd1";
          magenta = "#ada0d3";
          cyan = "#95c4ce";
          white = "#d2d4de";
        };
      };
      env = {
        TERM = "xterm-256color";
      };
      font = {
        size = 15.0;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font";
          style = "BoldItalic";
        };
      };
      scrolling = {
        history = 100000;
      };
    };
  };
}
