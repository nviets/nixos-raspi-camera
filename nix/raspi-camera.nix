{pkgs, config, lib, ...}:
let
  cfg = config.hardware.raspi-camera;
  user = "rpicam-rtsp-server";
  campkgs = import ./packages.nix { inherit pkgs; };
in
with lib;
{
  options = {
    hardware.raspi-camera = {
    };
  };

  config = with campkgs; {
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

    users.groups."${user}" = {};

    users.extraUsers."${user}" = {
      group = user;
      isSystemUser = true;
      home = "/var/spool/${user}";
      createHome = true;
      extraGroups = [
        "video" "plugdev"
      ];
    };

    systemd.services.rpicam-rtsp-server = {
      script = with pkgs; ''
        ${rpicam-apps}/bin/rpicam-vid -t 0 --inline -o - \
          --hflip --vflip --width 320 --height 240 \
          2>/dev/null \
        | ${vlc}/bin/cvlc stream:///dev/stdin --sout '#rtp{sdp=rtsp://:8554/stream1}' \
          :demux=h264 \
        ;
      '';
      after = [ "dtmerger.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "always";
        User = user;
        Group = user;
      };
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
