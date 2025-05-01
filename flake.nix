{
  description = "NixOS configuration for chesedo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
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
          specialArgs = { inherit nixos-hardware; };
          modules = [
            ./nixos/configuration-framework-13.nix
          ];
        };
      };
      homeConfigurations = {
        chesedo = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home-manager/home.nix
          ];
        };
      };
    };
}
