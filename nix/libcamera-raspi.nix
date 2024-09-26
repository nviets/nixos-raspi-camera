{ stdenv
, fetchgit
, lib
, meson
, ninja
, pkg-config
, makeFontsConf
, openssl
, libdrm
, libevent
, libyaml
, lttng-ust
, libpisp
, gst_all_1
, gtest
, graphviz
, doxygen
, python3
, python3Packages
, systemd # for libudev
, withQcam ? false
, qt5 # withQcam
, libtiff # withQcam
}:

stdenv.mkDerivation rec {
  pname = "libcamera";
  version = "v0.3.1+rpt20240906";

  src = fetchgit {
    # url = "https://git.libcamera.org/libcamera/libcamera.git";
    url = "https://github.com/raspberrypi/libcamera";
    # rev = "v${version}";
    rev = "69a894c4adad524d3063dd027f5c4774485cf9db";
    hash = "sha256-KH30jmHfxXq4j2CL7kv18DYECJRp9ECuWNPnqPZajPA=";
    # hash = "sha256-0000000000000000000000000000000000000000000=";
    # hash = "sha256-vB7dxBDG0y8YvG/2vCgrhyBJmumGG66Vl7yZwprxj5c=";
    # hash = "sha256-x0Im9m9MoACJhQKorMI34YQ+/bd62NdAPc2nWwaJAvM=";
  };

  patches = [
    ./libcamera-installed.patch
  ];

  outputs = [ "out" "dev" ];

  postPatch = ''
    patchShebangs utils/
    patchShebangs src/py/libcamera
  '';

  # libcamera signs the IPA module libraries at install time, but they are then
  # modified by stripping and RPATH fixup. Therefore, we need to generate the
  # signatures again ourselves. For reproducibility, we use a static private key.
  #
  # If this is not done, libcamera will still try to load them, but it will
  # isolate them in separate processes, which can cause crashes for IPA modules
  # that are not designed for this (notably ipa_rpi.so).
  preBuild = ''
    ninja src/ipa-priv-key.pem
    install -D ${./libcamera-raspi-ipa-priv-key.pem} src/ipa-priv-key.pem
  '';

  strictDeps = true;

  buildInputs = [
    # IPA and signing
    openssl

    # gstreamer integration
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base

    # cam integration
    libevent
    libdrm

    # hotplugging
    systemd

    # lttng tracing
    lttng-ust

    # yamlparser
    libyaml

    gtest
    libpisp
  ] ++ lib.optionals withQcam [ libtiff qt5.qtbase qt5.qttools ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    python3Packages.jinja2
    python3Packages.pyyaml
    python3Packages.ply
    python3Packages.sphinx
    python3Packages.pybind11
    graphviz
    doxygen
    openssl
  ] ++ lib.optional withQcam qt5.wrapQtAppsHook;

  mesonFlags = [
    "-Dv4l2=true"
    "-Dqcam=${if withQcam then "enabled" else "disabled"}"
    "-Dlc-compliance=disabled" # tries unconditionally to download gtest when enabled
    # Avoid blanket -Werror to evade build failures on less
    # tested compilers.
    "-Dwerror=false"
    # Documentation breaks binary compatibility.
    # Given that upstream also provides public documentation,
    # we can disable it here.
    "-Ddocumentation=disabled"
    "-Dpipelines=rpi/vc4,rpi/pisp"
    "-Dipas=rpi/vc4,rpi/pisp"
  ];

  # Fixes error on a deprecated declaration
  env.NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations";

  # Silence fontconfig warnings about missing config
  FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ ]; };

  meta = with lib; {
    description = "An open source camera stack and framework for Linux, Android, and ChromeOS";
    homepage = "https://libcamera.org";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ citadelcore ];
    badPlatforms = [
      # Mandatory shared libraries.
      lib.systems.inspect.platformPatterns.isStatic
    ];
  };
}
