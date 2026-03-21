{ lib, ... }:
{
  options = {
    observability = lib.mkOption {
      type = lib.types.submodule {
        options = {
          backend = lib.mkOption {
            type = lib.types.enum [
              "none"
              "noop"
              "log"
              "verbose"
              "prometheus"
              "otel"
              "opentelemetry"
              "otlp"
            ];
            default = "none";
            description = "Observability backend (`none`, `noop`, `log`, `verbose`, `prometheus`, `otel`, `opentelemetry`, `otlp`). Алиасы `opentelemetry`/`otlp` совпадают с OTel.";
          };
          otel_endpoint = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "OTLP endpoint (e.g. \"http://localhost:4318\"). Only used when backend = \"otel\".";
          };
          otel_service_name = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Service name reported to the OTel collector. Defaults to \"zeroclaw\".";
          };
          runtime_trace_max_entries = lib.mkOption {
            type = lib.types.int;
            default = 200;
            description = "Maximum entries retained when runtime_trace_mode = \"rolling\".";
          };
          runtime_trace_mode = lib.mkOption {
            type = lib.types.enum [
              "none"
              "rolling"
              "full"
            ];
            default = "none";
            description = "Режим записи runtime trace: `none`, `rolling`, `full`.";
          };
          runtime_trace_path = lib.mkOption {
            type = lib.types.str;
            default = "state/runtime-trace.jsonl";
            description = "Runtime trace file path. Relative paths are resolved under workspace_dir.";
          };
        };
      };
      default = {
        backend = "none";
        runtime_trace_max_entries = 200;
        runtime_trace_mode = "none";
        runtime_trace_path = "state/runtime-trace.jsonl";
      };
      description = "Observability backend configuration (`[observability]` section).";
    };
  };
}
