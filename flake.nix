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
    nixosModules = {
      raspi-camera = import ./nix/raspi-camera.nix;
    };
  };
}

