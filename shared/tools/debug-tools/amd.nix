{ pkgs, lib, ... }:

pkgs.python3Packages.buildPythonApplication rec {
  pname = "amd-debug-tools";
  version = "0.2.20";
  format = "pyproject";

  src = pkgs.fetchgit {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/superm1/amd-debug-tools.git";
    rev = version;
    hash = "sha256-JDacCakZC+4N4IDAODWLSuensAtFArl052I4weK/zJQ=";
  };

  build-system = with pkgs.python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with pkgs.python3Packages; [
    dbus-fast
    jinja2
    matplotlib
    packaging
    pandas
    pyudev
    seaborn
    tabulate
  ];

  pythonRemoveDeps = [
    "cysystemd"
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        pkgs.acpica-tools
        pkgs.ethtool
        pkgs.libdisplay-info
        pkgs.systemd
        pkgs.util-linux
        pkgs.eudev
        pkgs.gcc.cc.lib
      ]
    }"
  ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = "AMD debug tools including amd-s2idle";
    homepage = "https://pypi.org/project/amd-debug-tools/";
    license = licenses.mit;
  };
}
