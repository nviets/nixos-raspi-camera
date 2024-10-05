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

  outputs = { self, nixpkgs }: {
    packages = {
      aarch64-linux = let
        pkgs = import nixpkgs { system = "aarch64-linux"; };
      in (import ./nix/packages.nix { inherit pkgs; });
    };
    nixosModules = {
      raspi-camera = import ./nix/raspi-camera.nix;
    };
  };
}

