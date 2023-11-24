{inputs, config, pkgs, lib, ...}:
let
  evalName = name:
     let file = lib.filesystem.listFilesRecursive name; in builtins.head file;
in
{
  options.autostart = lib.mkOption {
    default = [];
  };

  config = {
    home.file = builtins.listToAttrs (map (pkg:
    {
      name = ".config/autostart/" + pkg.pname + ".desktop";
      value =
      if pkg ? desktopFile then {
        source = pkg.desktopFile;
      } else {
        source = evalName (pkg + "/share/applications/");
      };
    })
    config.autostart);
  };
}