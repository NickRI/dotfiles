{ lib, ... }:
{
  options = {
    cost = lib.mkOption {
      type = lib.types.submodule {
        options = {
          allow_override = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Allow requests to exceed budget with --override flag (default: false)";
          };
          daily_limit_usd = lib.mkOption {
            type = lib.types.float;
            default = 10.0;
            description = "Daily spending limit in USD (default: 10.00)";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable cost tracking (default: false)";
          };
          monthly_limit_usd = lib.mkOption {
            type = lib.types.float;
            default = 100.0;
            description = "Monthly spending limit in USD (default: 100.00)";
          };
          prices = lib.mkOption {
            type = (
              lib.types.attrsOf (
                lib.types.submodule {
                  options = {
                    input = lib.mkOption {
                      type = lib.types.float;
                      default = 0.0;
                      description = "Input price per 1M tokens";
                    };
                    output = lib.mkOption {
                      type = lib.types.float;
                      default = 0.0;
                      description = "Output price per 1M tokens";
                    };
                  };
                }
              )
            );
            default = { };
            description = "Per-model pricing (USD per 1M tokens)";
          };
          warn_at_percent = lib.mkOption {
            type = lib.types.int;
            default = 80;
            description = "Warn when spending reaches this percentage of limit (default: 80)";
          };
        };
      };
      default = {
        allow_override = false;
        daily_limit_usd = 10.0;
        enabled = false;
        monthly_limit_usd = 100.0;
        prices = {
          "anthropic/claude-3-haiku" = {
            input = 0.25;
            output = 1.25;
          };
          "anthropic/claude-3.5-sonnet" = {
            input = 3.0;
            output = 15.0;
          };
          "anthropic/claude-opus-4-20250514" = {
            input = 15.0;
            output = 75.0;
          };
          "anthropic/claude-sonnet-4-20250514" = {
            input = 3.0;
            output = 15.0;
          };
          "google/gemini-1.5-pro" = {
            input = 1.25;
            output = 5.0;
          };
          "google/gemini-2.0-flash" = {
            input = 0.1;
            output = 0.4;
          };
          "openai/gpt-4o" = {
            input = 5.0;
            output = 15.0;
          };
          "openai/gpt-4o-mini" = {
            input = 0.15;
            output = 0.6;
          };
          "openai/o1-preview" = {
            input = 15.0;
            output = 60.0;
          };
        };
        warn_at_percent = 80;
      };
      description = "Cost tracking and budget enforcement configuration (`[cost]` section).";
    };
  };
}
