{
  description = "NixOS configuration for chesedo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixmox = {
      url = "git+https://git.isincredibly.gay/srxl/nixmox";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      nixmox,
      zen-browser,
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

          specialArgs = {
            inherit nixos-hardware;

            zen-browser = zen-browser.packages.${system}.default;
          };
          modules = [
            ./nixos/configuration-framework-13.nix
          ];
        };
      };
      homeConfigurations = {
        chesedo = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            nixmox = nixmox.packages.${system};
          };
          modules = [
            ./home-manager/home.nix
          ];
        };
      };
    };
}
