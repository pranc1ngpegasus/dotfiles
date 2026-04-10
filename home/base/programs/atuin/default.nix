{ ... }:
{
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      auto_sync = false;
      update_check = false;
      sync_frequency = "0";

      search_mode = "fuzzy";
      filter_mode = "global";
      inline_height = 20;
      style = "compact";
      show_preview = true;
      enter_accept = false;
    };
  };
}
