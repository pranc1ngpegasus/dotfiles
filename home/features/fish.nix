{pkgs, ...}: {
  programs.fish = {
    enable = true;
    shellInit = ''
      fish_add_path $HOME/.tfenv/bin
      fish_add_path $HOME/.nodenv/bin
    '';
    plugins = [
      {
        name = "asdf";
        src = pkgs.fetchFromGitHub {
          owner = "rstacruz";
          repo = "fish-asdf";
          rev = "master";
          sha256 = "39L6UDslgIEymFsQY8klV/aluU971twRUymzRL17+6c=";
        };
      }
      {
        name = "fzf";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "fzf";
          rev = "master";
          sha256 = "28QW/WTLckR4lEfHv6dSotwkAKpNJFCShxmKFGQQ1Ew=";
        };
      }
      {
        name = "fish-ghq";
        src = pkgs.fetchFromGitHub {
          owner = "decors";
          repo = "fish-ghq";
          rev = "master";
          sha256 = "6b1zmjtemNLNPx4qsXtm27AbtjwIZWkzJAo21/aVZzM=";
        };
      }
      {
        name = "fish-rust";
        src = pkgs.fetchFromGitHub {
          owner = "halostatue";
          repo = "fish-rust";
          rev = "master";
          sha256 = "fvKL10euckjVeaGqvZMzOB6WCdqiKQl3mN0fk0Okn18=";
        };
      }
    ];
  };
}
