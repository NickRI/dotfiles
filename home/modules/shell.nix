{config, pkgs, lib, ...}:
let
  inherit (pkgs) fetchFromGitHub;
in
{
  config = {
    home.shellAliases = {
       ".." = "cd ..";
       "..." = "cd ../..";
       ll = "ls -lah";
    };

    home.file = {
      ".p10k.zsh".source = ../files/.p10k.zsh;
    };

    programs = {

      zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = [ "--cmd=cd" ];
      };

      fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      bat = {
        enable = true;
      };

      jq.enable = true;

      gh = {
        enable = true;
        settings = {
          # What protocol to use when performing git operations. Supported values: ssh, https
          git_protocol = "ssh";
          # What editor gh should run when creating issues, pull requests, etc. If blank, will refer to environment.
          # editor = ;
          # When to interactively prompt. This is a global config that cannot be overridden by hostname. Supported values: enabled, disabled
          prompt = "enabled";
          # A pager program to send command output to, e.g. "less". Set the value to "cat" to disable the pager.
          # pager = ;
          # Aliases allow you to create nicknames for gh commands
          aliases = {
              co = "pr checkout";
          };
          # The path to a unix socket through which send HTTP connections. If blank, HTTP traffic will be handled by net/http.DefaultTransport.
          # http_unix_socket = ;
          # What web browser gh should use when opening URLs. If blank, will refer to environment.
          browser = "chromium";
        };
        extensions = [
            pkgs.gh-dash
        ];
      };

      bash.enable = true;

      zsh = {
        enable = true;
        initExtra = ''
           # Sources
           source ~/.p10k.zsh
           autoload -U compinit && compinit

           # Keybindings
           bindkey '^f' autosuggest-accept

           # History
           HISTDUP=erase
           setopt appendhistory
           setopt sharehistory
           setopt hist_ignore_space
           setopt hist_ignore_all_dups
           setopt hist_save_no_dups
           setopt hist_find_no_dups
           setopt hist_ignore_dups

           # Completion styling
           zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
           zstyle ':completion:*' menu no

           zstyle ':fzf-tab:complete:(cd|ls|ll):*' fzf-preview 'ls --color $realpath'
           zstyle ':fzf-tab:complete:(cat|bat):*' fzf-preview 'bat --style=numbers --color=always -r :100 $realpath'
       '';

       oh-my-zsh = {
           enable = true;
           theme = "robbyrussell";
           plugins = [ "git" "sudo" "docker" "themes" ];
       };

       plugins = [
         {
           name = "zsh-autosuggestions";
           src = fetchFromGitHub {
             owner = "zsh-users";
             repo = "zsh-autosuggestions";
             rev = "v0.7.0";
             sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
           };
         }
         {
           name = "zsh-completions";
           src = fetchFromGitHub {
             owner = "zsh-users";
             repo = "zsh-completions";
             rev = "0.35.0";
             sha256 = "GFHlZjIHUWwyeVoCpszgn4AmLPSSE8UVNfRmisnhkpg=";
           };
         }
         {
           name = "powerlevel10k";
           src = fetchFromGitHub {
             owner = "romkatv";
             repo = "powerlevel10k";
             rev = "v1.19.0";
             sha256 = "+hzjSbbrXr0w1rGHm6m2oZ6pfmD6UUDBfPd7uMg5l5c=";
           };
           file = "powerlevel10k.zsh-theme";
         }
         {
           name = "zsh-syntax-highlighting";
           src = fetchFromGitHub {
             owner = "zsh-users";
             repo = "zsh-syntax-highlighting";
             rev = "0.8.0";
             sha256 = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
           };
         }
         {
           name = "fzf-tab";
           src = fetchFromGitHub {
             owner = "Aloxaf";
             repo = "fzf-tab";
             rev = "v1.1.2";
             sha256 = "sha256-Qv8zAiMtrr67CbLRrFjGaPzFZcOiMVEFLg1Z+N6VMhg=";
           };
         }
       ];
      };
    };
  };
}