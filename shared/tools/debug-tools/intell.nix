{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "s0ix-selftest";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "intel";
    repo = "S0ixSelftestTool";
    rev = "main";
    sha256 = "sha256-2quAiVYt6elULJTqMFhnciNWork6ViTWcPTRJQfvu+I=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    install -m755 s0ix-selftest-tool.sh $out/bin/s0ix-selftest
  '';
}
