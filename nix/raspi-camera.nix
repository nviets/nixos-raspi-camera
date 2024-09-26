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
    dtmerger = pkgs.callPackage ./dtmerger.nix {};
  in {

    environment.systemPackages = with pkgs; [
      libcamera
      dtmerger
    ];
  };
}
