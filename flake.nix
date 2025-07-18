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

    piper-voice-ryan-onnx = {
      url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/ryan/high/en_US-ryan-high.onnx";
      flake = false; # This tells Nix it's just a file, not a flake
    };
    piper-voice-ryan-json = {
      url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/ryan/high/en_US-ryan-high.onnx.json";
      flake = false;
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
      piper-voice-ryan-onnx,
      piper-voice-ryan-json,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;

      piperVoiceModels = {
        en-us-ryan-high = pkgs.stdenv.mkDerivation {
          pname = "piper-voice-en-us-ryan-high";
          version = "1.0.0";

          # No src needed since we're using the downloaded files directly
          dontUnpack = true;

          installPhase = ''
            mkdir -p $out/share/piper/voices/en_US/ryan/high
            cp ${piper-voice-ryan-onnx} $out/share/piper/voices/en_US/ryan/high/en_US-ryan-high.onnx
            cp ${piper-voice-ryan-json} $out/share/piper/voices/en_US/ryan/high/en_US-ryan-high.onnx.json
          '';

          meta = with lib; {
            description = "Piper TTS voice model - English US Ryan High Quality";
            homepage = "https://github.com/rhasspy/piper";
            license = licenses.mit;
          };
        };
      };
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
            inherit piperVoiceModels;

            nixmox = nixmox.packages.${system};
          };
          modules = [
            ./home-manager/home.nix
          ];
        };
      };
    };
}
