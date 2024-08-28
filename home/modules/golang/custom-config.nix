{ config, pkgs, ... }:

{
  imports = [
    ./custom-builder.nix
  ];

  config = {
    golang.binaries = [
      rec {
        name = "importsort";
        version = "1.0.0";
        owner = "lcd1232";
        repo = "${name}";
        rev = "v${version}";
        hash = "sha256-ahMZSAVkP1wigizW1UWG2+VD40LQsenqeYK1ZiUK6kE=";
        vendorHash = "sha256-Pz1m9uoUWp5XBiasdwz/DN24friHHYL1J7tjroE6goI=";
      }
      rec {
        name = "minimock";
        version = "3.1.3";
        subPackages = [ "cmd/${name}" ];
        owner = "gojuno";
        repo = "${name}";
        rev = "v${version}";
        hash = "sha256-6n5FOHTfsLYqnhlDO3etMnrypeOElmwdvoFQb3aSBts=";
        vendorHash = "sha256-fiSU2NB9rWIPQLdnui5CB5VcadTVUg2JaO3ma7DAYqo=";
        ldflags = ["-s" "-w" "-X main.version=${version}"];
      }
      rec {
        name = "gogo-protobuf";
        version = "1.3.2";
        subPackages = [ "protoc-gen-gogo" "protoc-gen-gogoslick" "gogoproto" ];
        owner = "gogo";
        repo = "protobuf";
        rev = "v${version}";
        hash = "sha256-CoUqgLFnLNCS9OxKFS7XwjE17SlH6iL1Kgv+0uEK2zU=";
        vendorHash = "sha256-nOL2Ulo9VlOHAqJgZuHl7fGjz/WFAaWPdemplbQWcak=";
        checkFlags = [ "-skip=TestGolden|TestParameters" ];
      }
      rec {
        name = "buffalo";
        version = "0.18.14";
        subPackages = [ "cmd/${name}" ];
        owner = "go${name}";
        repo = "cli";
        rev = "v${version}";
        tags = [ "sqlite" ];
        hash = "sha256-HNJE5TZgfStuX5fyZGAsiOBmE80Fv1uH2DUiBQ+2Geo=";
        vendorHash = "sha256-7AZ78upxTn3wqsHlbyyhQfYqIcW/Op5sLUgqv4AkG9Y=";
      }
      rec {
        name = "buffalo-pop";
        version = "6.1.1";
        subPackages = [ "soda" ];
        owner = "gobuffalo";
        repo = "pop";
        rev = "v${version}";
        tags = [ "sqlite" ];
        hash = "sha256-S57LdTFS5PZLVUKxXOHb82jjJ7Oq9lm9Ai/DsE+BhdY=";
        vendorHash = "sha256-DjdE9A9jVd7cC481DUMHsfp4o6Z+vR647fWy6SKw02s=";
      }
    ];
  };
}