{ lib, ... }:
{
  options = {
    runtime = lib.mkOption {
      type = lib.types.submodule {
        options = {
          docker = lib.mkOption {
            type = lib.types.submodule {
              options = {
                allowed_workspace_roots = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [ ];
                  description = "Optional workspace root allowlist for Docker mount validation.";
                };
                cpu_limit = lib.mkOption {
                  type = lib.types.nullOr (lib.types.float);
                  default = 1.0;
                  description = "Optional CPU limit (`None` = no explicit limit).";
                };
                image = lib.mkOption {
                  type = lib.types.str;
                  default = "alpine:3.20";
                  description = "Runtime image used to execute shell commands.";
                };
                memory_limit_mb = lib.mkOption {
                  type = lib.types.nullOr (lib.types.int);
                  default = 512;
                  description = "Optional memory limit in MB (`None` = no explicit limit).";
                };
                mount_workspace = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Mount configured workspace into `/workspace`.";
                };
                network = lib.mkOption {
                  type = lib.types.str;
                  default = "none";
                  description = "Docker network mode (`none`, `bridge`, etc.).";
                };
                read_only_rootfs = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Mount root filesystem as read-only.";
                };
              };
            };
            default = {
              allowed_workspace_roots = [ ];
              cpu_limit = 1.0;
              image = "alpine:3.20";
              memory_limit_mb = 512;
              mount_workspace = true;
              network = "none";
              read_only_rootfs = true;
            };
            description = "Docker runtime configuration (`[runtime.docker]` section).";
          };
          kind = lib.mkOption {
            type = lib.types.enum [
              "native"
              "docker"
            ];
            default = "native";
            description = "Тип runtime: `native` или `docker`.";
          };
          reasoning_effort = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.enum [
                "minimal"
                "low"
                "medium"
                "high"
                "xhigh"
              ]
            );
            default = null;
            description = "Уровень reasoning для провайдеров с явным контролем (`minimal` … `xhigh`); `null` — по умолчанию у провайдера.";
          };
          reasoning_enabled = lib.mkOption {
            type = lib.types.nullOr (lib.types.bool);
            default = null;
            description = "Глобальный override reasoning: `null` — как у провайдера, `true`/`false` — явно.";
          };
        };
      };
      default = {
        docker = {
          allowed_workspace_roots = [ ];
          cpu_limit = 1.0;
          image = "alpine:3.20";
          memory_limit_mb = 512;
          mount_workspace = true;
          network = "none";
          read_only_rootfs = true;
        };
        kind = "native";
      };
      description = "Runtime adapter configuration (`[runtime]` section).";
    };
  };
}
