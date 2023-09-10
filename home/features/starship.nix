{...}: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

      aws = {
        disabled = true;
      };

      character = {
        format = "[\\$](green bold) ";
      };

      directory = {
        truncation_length = 3;
      };

      gcloud = {
        disabled = true;
      };

      git_branch = {
        symbol = "";
        format = "\\([$symbol$branch(:$remote_branch)]($style)\\)";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        # conflicted = "";
        # ahead = "";
        # behind = "";
        # diverged = "";
        # up_to_date = "✓";
        # untracked = "";
        # stashed = "";
        # modified = "🔥";
        # staged = "";
        # renamed = "";
        # deleted = "";
      };

      package = {
        disabled = true;
      };
    };
  };
}
