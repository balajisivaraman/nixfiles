{ lib, stdenv, fetchurl, unzip, libarchive }:

stdenv.mkDerivation rec {
  name = "otf-san-francisco";

  otf-san-francisco = fetchurl {
    name = "otf-san-francisco";
    url="https://developer.apple.com/fonts/downloads/SFPro.zip";
    sha512="7001638787c7580a7cd1c40d92af8c680187ebfad832fe0ec4e97ccc15d925a9928e97b1e5bfd39db1789eb955bf0fcbb954a990b2ef2b56b41da7a13a6bd6cd";
  };

  buildInputs = [ unzip libarchive ];

  sourceRoot = ".";

  phases = [ "unpackPhase" "installPhase" ];

  unpackPhase = ''
    unzip -j ${otf-san-francisco}
    bsdtar xvPf 'San Francisco Pro.pkg' || true
    bsdtar xvPf 'San Francisco Pro.pkg/Payload'
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    cp Library/Fonts/*.otf $out/share/fonts/opentype
  '';

  meta = {
    description = "The system font for macOS, iOS, watchOS, and tvOS";
    homepage = "https://developer.apple.com/fonts/";
  };
}
