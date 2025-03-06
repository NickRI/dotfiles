{
  config,
  lib,
  vsextensions,
  ...
}:

{
  config = {
    programs.vscode = lib.mkIf (config.programs.vscode.enable) {
      userSettings = {
        "go.toolsManagement.autoUpdate" = true;
        "go.survey.prompt" = true;
        "go-lines.lineLength" = 80;
        "editor.quickSuggestions" = {
          "strings" = true;
        };
        "editor.suggest.showWords" = true;
      };

      extensions = with vsextensions.vscode-marketplace; [
        golang.go
        yokoe.vscode-postfix-go
        honnamkuan.golang-snippets
        aos.gostmortem-table
        r3inbowari.gomodexplorer
        liuchao.go-struct-tag
        galkowskit.go-interface-annotations
        quillaja.goasm
        gofenix.go-lines
      ];

      keybindings = [
        {
          "key" = "ctrl+i";
          "command" = "go.impl.cursor";
        }
      ];

      userTasks = {
        version = "2.0.0";
        tasks = [
          {
            type = "shell";
            label = "$(beaker) Golang generate all";
            command = "go generate ./...";
            presentation = {
              reveal = "always";
            };
            options = {
              statusbar = {
                label = "$(beaker) Go-Gen";
                detail = "Golang generate all";
                color = "#00ADD8";
              };
            };
            problemMatcher = [ "$go" ];
          }
          {
            type = "shell";
            label = "$(run-all) Golang test all";
            command = "go test -race -cover ./...";
            presentation = {
              reveal = "always";
            };
            options = {
              statusbar = {
                hide = true;
              };
            };
            problemMatcher = [ "$go" ];
          }
          {
            type = "shell";
            label = "$(gather) Golang mod tidy";
            command = "go mod tidy -v";
            presentation = {
              reveal = "always";
            };
            options = {
              statusbar = {
                hide = true;
              };
            };
            problemMatcher = [ "$go" ];
          }
        ];
      };
    };
  };
}
