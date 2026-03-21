{ lib, ... }:
{
  options = {
    project_intel = lib.mkOption {
      type = lib.types.submodule {
        options = {
          default_language = lib.mkOption {
            type = lib.types.enum [
              "en"
              "de"
              "fr"
              "it"
            ];
            default = "en";
            description = "Язык отчётов project_intel.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable the project_intel tool. Default: false.";
          };
          include_git_data = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Include git log data in reports. Default: true.";
          };
          include_jira_data = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Include Jira data in reports. Default: false.";
          };
          jira_base_url = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Jira instance base URL (required if include_jira_data is true).";
          };
          report_output_dir = lib.mkOption {
            type = lib.types.str;
            default = "~/.zeroclaw/project-reports";
            description = "Output directory for generated reports.";
          };
          risk_sensitivity = lib.mkOption {
            type = lib.types.str;
            default = "medium";
            description = "Risk detection sensitivity: low, medium, high. Default: \"medium\".";
          };
          templates_dir = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional custom templates directory.";
          };
        };
      };
      default = {
        default_language = "en";
        enabled = false;
        include_git_data = true;
        include_jira_data = false;
        report_output_dir = "~/.zeroclaw/project-reports";
        risk_sensitivity = "medium";
      };
      description = "Project delivery intelligence configuration (`[project_intel]` section).";
    };
  };
}
