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

    services.udev = {
      extraRules = ''
        SUBSYSTEM=="dma_heap", GROUP="video", MODE="0660"
      '';
    };

    systemd.services.dtmerger = {
      script = ''
        ${dtmerger}/bin/dtmerger.sh
      '';
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    systemd.services.rpicam-rtsp-server = {
      script = with pkgs; ''
        ${rpicam-apps}/bin/rpicam-vid -t 0 --inline -o - \
          --hflip --vflip --width 320 --height 240 \
        | ${vlc}/bin/cvlc stream:///dev/stdin --sout '#rtp{sdp=rtsp://:8554/stream1}' \
          :demux=h264 \
        >/dev/null 2>&1
      '';
      after = [ "dtmerger.service" ];
      wantedBy = [ "multi-user.target" ];
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
