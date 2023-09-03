{ stdenv }:

# A derivation which builds my bin directory

stdenv.mkDerivation {
  name = "my-bin";
  src = ./.;
  installPhase = ''
    mkdir -p $out/bin
    # copy executables to $out/bin
    for file in *.sh; do
      if [ -x $file ]; then
        cp *.sh $out/bin
      fi
    done
  '';
}
