{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation {
  pname = "wormhole-drop";
  version = "0.1.0";

  src = ./.;

  buildInputs = [
    pkgs.go
    pkgs.gcc
  ];

  buildPhase = ''
    export GOCACHE=$TMPDIR/go-build-cache
    export GOMODCACHE=$TMPDIR/go-mod-cache
    mkdir -p $GOCACHE
    mkdir -p $GOMODCACHE

    cd $src

    go build -o $out/bin/wormhole-drop .
  '';

  installPhase = ''
    # бинарник уже на месте
    :
  '';

  meta = with pkgs.lib; {
    description = "Go wormhole drop application";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
