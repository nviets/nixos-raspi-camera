{ stdenv
, lib
, writeShellScriptBin
, libraspberrypi
} :

writeShellScriptBin "dtmerger.sh" ''
  O=${../ov5647.dtbo}
  D=$(dirname $O)
  exec ${libraspberrypi}/bin/dtoverlay -d $D $O
''
