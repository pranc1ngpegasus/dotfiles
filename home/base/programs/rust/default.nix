{pkgs, ...}: let
  rustflags =
    if pkgs.system == "aarch64-darwin"
    then ''
      "-C", "link-arg=-undefined",
      "-C", "link-arg=dynamic_lookup",
    ''
    else ''
      "-C", "link-arg=-fuse-ld=${pkgs.mold}/bin/mold"
    '';
in {
  home.file.".cargo/config.toml".text = ''
    [net]
    git-fetch-with-cli = true

    [target.x86_64-unknown-linux-gnu]
    linker = "${pkgs.clang}/bin/clang"
    rustflags = [ ${rustflags} ]

    [target.x86_64-unknown-linux-musl]
    linker = "${pkgs.clang}/bin/clang"
    rustflags = [ ${rustflags} ]

    [target.aarch64-apple-darwin]
    linker = "${pkgs.clang}/bin/clang"
    rustflags = [ ${rustflags} ]
  '';
}
