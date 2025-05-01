{
  lib,
  stdenv,
  pkgs,
}:

let
  nixmoxSrc = builtins.fetchTarball {
    url = "https://github.com/Sorixelle/nixmox/archive/1e9b569308efbbf61bd4f471803620715eac53cc.tar.gz";
    sha256 = "sha256-kAKKojLeUO8BKzH6ZGGhPc44ShZRd7Kh8ig7ppm11ac=";
  };

  # Create new pkgs with the nixmox overlay
  pkgsWithOomox = import pkgs.path {
    inherit (pkgs) system;
    overlays = [ (import nixmoxSrc).overlay ];
  };

in
pkgsWithOomox.oomoxPlugins.theme-oomox.generate {
  name = "sunset-cave";
  src = ./theme-file;
  gtkVariant = "all";
}
