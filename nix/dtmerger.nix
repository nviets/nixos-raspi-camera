{ stdenv
, lib
, writeShellScriptBin
, libraspberrypi
} :

writeShellScriptBin "dtmerger.sh" ''
  O=${../imx708.dtbo}
  D=$(dirname $O)
  exec ${libraspberrypi}/bin/dtoverlay -d $D $O
''
