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
    rpicam-apps = pkgs.callPackage ./rpicam-apps.nix {
      inherit libpisp libcamera;
    };
  in {

    systemd.services.tweaks = {
      script = ''
        ${dtmerger}/bin/dtmerger.sh
      '';
      wantedBy = [ "multi-user.target" ];
    };

    services.udev = {
      extraRules = ''
        SUBSYSTEM=="dma_heap", GROUP="video", MODE="0660"
      '';
    };

    nixpkgs.config.permittedInsecurePackages = [
      "libav-11.12"
    ];

    environment.systemPackages = with pkgs; [
      libcamera
      dtmerger
      rpicam-apps
    ];
  };
}
