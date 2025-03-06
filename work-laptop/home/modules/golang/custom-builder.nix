{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (builtins) length;
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (pkgs) buildGoModule fetchFromGitHub;

  build =
    program:
    buildGoModule {
      pname = program.name;
      version = program.version;

      src = fetchFromGitHub {
        githubBase = program.githubBase;
        owner = program.owner;
        repo = program.repo;
        rev = program.rev;
        hash = program.hash;
      };

      vendorHash = program.vendorHash;
      proxyVendor = program.proxyVendor;

      subPackages = program.subPackages;

      tags = program.tags;
      ldflags = program.ldflags;
      modRoot = program.modRoot;
      checkFlags = program.checkFlags;
      buildInputs = program.buildInputs;
      nativeBuildInputs = program.nativeBuildInputs;
      CGO_ENABLED = program.CGO_ENABLED;
    };
in
{
  options.golang = {
    binaries = mkOption {
      default = [ ];
      description = "List of Go programs to be installed from GitHub repositories.";
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = mkOption {
              description = "Program name";
              type = lib.types.str;
              example = "enumer";
            };
            version = mkOption {
              description = "Program version";
              type = lib.types.str;
              example = "1.31.3";
            };
            githubBase = mkOption {
              description = "Program repository github url";
              type = lib.types.str;
              example = "github.com";
              default = "github.com";
            };
            owner = mkOption {
              description = "Program repository owner";
              type = lib.types.str;
              example = "dmarkham";
            };
            repo = mkOption {
              description = "Program repository repo";
              type = lib.types.str;
              example = "enumer";
            };
            rev = mkOption {
              description = "Program repository revision";
              type = lib.types.str;
              example = "master";
            };
            hash = mkOption {
              description = "Program repository hash";
              type = lib.types.str;
              example = "sha256-Gjw1dRrgM8D3G7v6WIM2+50r4HmTXvx0Xxme2fH9TlQ=";
              default = lib.fakeHash;
            };
            vendorHash = mkOption {
              description = "Program vendor hash";
              type = lib.types.nullOr lib.types.str;
              example = "sha256-Gjw1dRrgM8D3G7v6WIM2+50r4HmTXvx0Xxme2fH9TlQ=";
              default = lib.fakeHash;
            };
            ldflags = mkOption {
              description = "Build ldflags";
              type = lib.types.listOf lib.types.str;
              example = [ "-X 'main.version=\${version}'" ];
              default = [ ];
            };
            checkFlags = mkOption {
              description = "Build checkflags to filter in/out tests and others";
              type = lib.types.listOf lib.types.str;
              example = [ "-run=^Test(Simple|Fast)$" ];
              default = [ ];
            };
            subPackages = mkOption {
              description = "Build subpackage path to main";
              type = lib.types.listOf lib.types.str;
              example = [ "cmd\/\${name}" ];
              default = [ ];
            };
            modRoot = mkOption {
              description = "The root directory of the Go module that contains the go.mod file";
              type = lib.types.str;
              example = "./";
              default = "./";
            };
            proxyVendor = mkEnableOption "If true, the intermediate fetcher downloads dependencies from the Go module proxy (using go mod download) instead of vendoring them";
            tags = mkOption {
              description = "A string list of Go build tags (also called build constraints) that are passed via the -tags argument of go build.";
              type = lib.types.listOf lib.types.str;
              example = [
                "production"
                "sqlite"
              ];
              default = [ ];
            };
            nativeBuildInputs = mkOption {
              description = "A list of dependencies whose host platform is the new derivation’s build platform, and target platform is the new derivation’s host platform.";
              type = lib.types.listOf lib.types.package;
              example = [ pkgs.musl ];
              default = [ ];
            };
            buildInputs = mkOption {
              description = "Programs and libraries used by the new derivation at run-time";
              type = lib.types.listOf lib.types.package;
              example = [
                pkgs.libvirt
                pkgs.libxml2
                pkgs.go_1_18
              ];
              default = [ ];
            };
            CGO_ENABLED = mkOption {
              description = "Build CGO_ENABLED variable";
              type = lib.types.int;
              example = 1;
              default = 0;
            };
          };
        }
      );
    };
  };

  config = {
    home.packages = map build config.golang.binaries;
  };
}
