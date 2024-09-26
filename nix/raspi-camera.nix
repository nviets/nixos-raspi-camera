{pkgs, config, lib, ...}:
let
  cfg = config.hardware.raspi-camera;
in
with lib;
{
  options = {
    hardware.raspi-camera = {
    };
  };

  config = let
    libcamera = pkgs.callPackage ./libcamera-rapsi.nix {};
  in {

    environment.systemPackages = with pkgs; [
      libcamera
    ];
  };
}
