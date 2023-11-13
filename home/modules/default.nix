{inputs, config, pkgs, lib, ...}:

{
    imports = mkMerge [
      mkIf (pkgs.stdenv.hostPlatform.isLinux) { ./autostart.nix }
    ];
}