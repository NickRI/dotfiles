{nixpkgs ? import <nixpkgs> {}, version, hash}:
let
    pkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/${hash}.tar.gz";
    }) {};

    toolchain = pkgs.${version};
in
nixpkgs.mkShell {
    packages = [ toolchain ];

    shellHook = ''
    export GOPATH=$(pwd)/.go
    export PATH=$(pwd)/.go/bin:$PATH
    '';
}
