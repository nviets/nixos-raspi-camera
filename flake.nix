{
  description = "Raspberry Pi camera project";

  nixConfig = {
    bash-prompt = "\[ raspi-camera \\w \]$ ";
  };

  inputs = {
    nixpkgs = {
      # Author's favorite nixpkgs
      url = "github:grwlf/nixpkgs/local17";
    };
  };

  outputs = { self, nixpkgs }:
    let
      module = system : (import ./nix/raspi-camera.nix) {
        pkgs = import nixpkgs { inherit system; };
      };
      aarch64-linux = "aarch64-linux";
    in {
      nixosModules = {
        "${aarch64-linux}" = module aarch64-linux;
      };
    };
}

