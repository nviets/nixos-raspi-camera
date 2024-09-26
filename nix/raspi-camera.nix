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
    libpisp = pkgs.callPackage ./libpisp.nix {};
    libcamera = pkgs.callPackage ./libcamera-raspi.nix {
      inherit libpisp;
    };
  in {

    environment.systemPackages = with pkgs; [
      libcamera
    ];
  };
}
