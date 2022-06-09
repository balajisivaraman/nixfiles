{ lib
, stdenv
, nixosTests
, rustPlatform
, fetchFromGitHub
, pkg-config
, python3
, less
, installShellFiles
, makeWrapper
, xlibsWrapper
, libxcb
}:

rustPlatform.buildRustPackage rec {
  pname = "i3lockr";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "owenthewizard";
    repo = pname;
    rev = "v${version}";
    sha256 = "0xna3290x4h0w1fw2r8kcswrjq3pz13smynykxcmi1kqcxv1mvih";
  };
  cargoSha256 = "sha256:089p2qn03yngbsh4q24cwhq5348xxf2ds0dixafa0fxlh75gnh10";

  nativeBuildInputs = [ pkg-config python3 installShellFiles makeWrapper  ];
  buildInputs = [ xlibsWrapper libxcb ];

  meta = with lib; {
    description = "Distorts a screenshot and runs i3lock.";
    homepage = "https://github.com/owenthewizard/i3lockr";
    license = with licenses; [ asl20 /* or */ mit ];
  };
}
