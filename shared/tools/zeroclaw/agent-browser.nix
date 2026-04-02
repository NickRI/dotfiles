{
  lib,
  config,
  pkgs,
  ...
}:
let
  version = "0.21.4";

  src = pkgs.fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "v${version}";
    hash = "sha256-T+IiizT1e5nuH6EqROn0b/w3H1OShWTTHUqD7tZJDkw=";
  };

  agentBrowserPackage = pkgs.rustPlatform.buildRustPackage {
    pname = "agent-browser";
    inherit version src;

    sourceRoot = "source/cli";

    cargoLock = {
      lockFile = "${src}/cli/Cargo.lock";
    };

    doCheck = false;

    meta = with lib; {
      description = "Headless browser automation CLI for AI agents (Vercel agent-browser)";
      homepage = "https://github.com/vercel-labs/agent-browser";
      license = licenses.asl20;
      mainProgram = "agent-browser";
      platforms = platforms.linux ++ platforms.darwin;
    };
  };

  cfg = config.services.zeroclaw;
in
{
  config = lib.mkIf (cfg.enable && cfg.settings.browser.enabled) {
    environment.systemPackages = [
      pkgs.chromium
    ];

    environment.variables = {
      CHROME_PATH = "${pkgs.chromium}/bin/chromium";
      PLAYWRIGHT_BROWSERS_PATH = "0";
    };

    services.zeroclaw.extraPkgs = lib.mkAfter [ agentBrowserPackage ];
  };
}
