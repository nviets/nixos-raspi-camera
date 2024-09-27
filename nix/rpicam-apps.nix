{ stdenv
, fetchgit
, lib
, meson
, ninja
, libcamera
, libpisp
, ninja
, python3
, python3Packages
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "rpicam-apps";
  version = "v1.5.1";

  src = fetchgit {
    url = "https://github.com/raspberrypi/rpicam-apps";
    rev = "v${version}";
    # hash = "sha256-KH30jmHfxXq4j2CL7kv18DYECJRp9ECuWNPnqPZajPA=";
  };

  outputs = [ "out" "dev" ];

  postPatch = ''
    patchShebangs utils/
  '';

  strictDeps = true;

  buildInputs = [
    libcamera
    libpisp
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ];

  mesonFlags = [
  ];

  # Fixes error on a deprecated declaration
  env.NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations";
}
