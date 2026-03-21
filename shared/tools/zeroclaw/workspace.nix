{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.zeroclaw;
in
{
  options.services.zeroclaw = {
    skillsSource = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Local path on the *build machine* that contains skill directories, e.g.
        `shared/agent-files/skills`.

        If set, for each workspace key `<workspace_key>` and each
        `workspaces.<workspace_key>.skills`
        we will create symlink:
        `${cfg.dataDir}/<workspace_key>/skills/<skill>` -> `<skillsSource>/<skill>`.
      '';
    };

    workspaces = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            source = lib.mkOption {
              type = lib.types.path;
              description = ''
                Local directory whose contents will be copied into:
                `${cfg.dataDir}/<workspace_key>` on the target machine.
              '';
            };

            skills = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = ''
                List of skill names to symlink into
                `${cfg.dataDir}/<workspace_key>/skills/<skill>/`.
              '';
            };
          };
        }
      );
      default = { };
      example = {
        workspace = {
          source = ../../../shared/agent-files/agents/main;
          skills = [
            "gitea"
            "nixos"
          ];
        };
      };
      description = ''
        Mapping of logical workspace keys to their local sources.

        Example:
          workspaces.workspace = {
            source = ../../../shared/agent-files/agents/main;
            skills = [ "gitea" "nixos" ];
          };
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/zeroclaw";
      example = "/var/lib/zeroclaw";
      description = ''
        Config directory; `config.toml` lives here, state in `<dataDir>/workspace`.
        API keys encrypted at rest use `<dataDir>/.secret_key`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.zeroclawWorkspace = ''
      mkdir -p ${cfg.dataDir}

      ${pkgs.rsync}/bin/rsync -a ${
        config.sops.templates."zeroclaw-config".path
      } ${cfg.dataDir}/config.toml

      # Create each workspace directory.
      ${lib.concatMapStringsSep "\n" (workspace_key: ''
        mkdir -p "${cfg.dataDir}/${workspace_key}"
      '') (lib.attrNames cfg.workspaces)}

      # Ownership/permissions only for directories (avoid dereferencing symlink targets).
      chown ${cfg.user}:${cfg.user} ${cfg.dataDir}
      chmod a+X ${cfg.dataDir}

      ${lib.concatMapStringsSep "\n" (workspace_key: ''
        chown ${cfg.user}:${cfg.user} "${cfg.dataDir}/${workspace_key}"
        chmod u+rwX,g+rwX,o-rwx "${cfg.dataDir}/${workspace_key}"
      '') (lib.attrNames cfg.workspaces)}

      # Link only regular files from each `workspaces.<key>.source` into
      # workspace root.
      # If target exists and is not a symlink, we skip to avoid destroying user data.
      ${lib.concatMapStringsSep "\n" (
        workspace_key:
        let
          ws = cfg.workspaces.${workspace_key};
        in
        ''
          ws_src="${ws.source}"
          ws_dst="${cfg.dataDir}/${workspace_key}"
          for f in "$ws_src"/*; do
            [ -f "$f" ] || continue
            base="$(basename "$f")"
            target="$ws_dst/$base"
            if [ -L "$target" ]; then
              ln -sf "$f" "$target"
            elif [ ! -e "$target" ]; then
              ln -s "$f" "$target"
            else
              # Replace only regular files (never directories) to guarantee symlinks.
              if [ -f "$target" ]; then
                rm -f "$target"
                ln -s "$f" "$target"
              else
                echo "Skipping existing $target (not a symlink and not a regular file)" >&2
              fi
            fi
          done
        ''
      ) (lib.attrNames cfg.workspaces)}

      # Optionally symlink selected skills into each workspace.
      ${lib.optionalString (cfg.skillsSource != null) ''
        ${lib.concatMapStringsSep "\n" (
          workspace_key:
          let
            ws = cfg.workspaces.${workspace_key};
          in
          ''
            mkdir -p "${cfg.dataDir}/${workspace_key}/skills"
            chown ${cfg.user}:${cfg.user} "${cfg.dataDir}/${workspace_key}/skills"
            chmod u+rwX,g+rwX,o-rwx "${cfg.dataDir}/${workspace_key}/skills"

            ${lib.concatMapStringsSep "\n" (skill: ''
              rm -rf "${cfg.dataDir}/${workspace_key}/skills/${skill}"
              ln -s "${cfg.skillsSource}/${skill}" "${cfg.dataDir}/${workspace_key}/skills/${skill}"
            '') ws.skills}
          ''
        ) (lib.attrNames cfg.workspaces)}
      ''}
    '';

    # If sources or selected skills change, restart the service.
    systemd.services.zeroclaw.restartTriggers = lib.mkAfter (
      [
        (builtins.toJSON cfg.workspaces)
      ]
      ++ (lib.optionals (cfg.skillsSource != null) [ (toString cfg.skillsSource) ])
      ++ (map (workspace_key: cfg.workspaces.${workspace_key}.source) (lib.attrNames cfg.workspaces))
    );
  };
}
