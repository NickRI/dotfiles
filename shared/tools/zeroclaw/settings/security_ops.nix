{ lib, ... }:
{
  options = {
    security_ops = lib.mkOption {
      type = lib.types.submodule {
        options = {
          auto_triage = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Automatically triage incoming alerts without user prompt.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable security operations tools.";
          };
          max_auto_severity = lib.mkOption {
            type = lib.types.enum [
              "low"
              "medium"
              "high"
              "critical"
            ];
            default = "low";
            description = "Максимальная серьёзность для авто-remediation без подтверждения.";
          };
          playbooks_dir = lib.mkOption {
            type = lib.types.str;
            default = "~/.zeroclaw/playbooks";
            description = "Directory containing incident response playbook definitions (JSON).";
          };
          report_output_dir = lib.mkOption {
            type = lib.types.str;
            default = "~/.zeroclaw/security-reports";
            description = "Directory for generated security reports.";
          };
          require_approval_for_actions = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Require human approval before executing playbook actions.";
          };
          siem_integration = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional SIEM webhook URL for alert ingestion.";
          };
        };
      };
      default = {
        auto_triage = false;
        enabled = false;
        max_auto_severity = "low";
        playbooks_dir = "~/.zeroclaw/playbooks";
        report_output_dir = "~/.zeroclaw/security-reports";
        require_approval_for_actions = true;
      };
      description = "Managed Cybersecurity Service (MCSS) dashboard agent configuration (`[security_ops]`).";
    };
  };
}
