{ pkgs ? import <nixpkgs> { } }:
let
  my-python-packages = ps:
    with ps; [
      google-api-python-client
      google-auth-oauthlib
    ];
in pkgs.mkShell {
  buildInputs = with pkgs; [ nixfmt ];
  packages = [ (pkgs.python3.withPackages my-python-packages) ];
}
