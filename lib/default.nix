{ stdenv }:

stdenv.mkDerivation {
  name = "my-lib";
  src = ./.;
  installPhase = ''
    mkdir -p $out
    cp -r * $out/.
  '';
}
