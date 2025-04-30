{
  description = "NixOS configuration for chesedo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixfmt-rfc-style
          nil
        ];
      };
      nixosConfigurations = {
        nixos-framework-13 = lib.nixosSystem {
          inherit system;
          modules = [
            nixos-hardware.nixosModules.framework-13-7040-amd
            ./nixos/configuration-framework-13.nix
          ];
        };
      };
    };
}
