{
  pkgs,
  ...
}:
let
  inherit (pkgs) fetchFromGitHub;
in
{
  home.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    ls = "eza";
    ll = "eza -la";
    tree = "eza --tree";
    cat = "bat --color=always";
  };

  home.file = {
    ".p10k.zsh".source = ../files/.p10k.zsh;
  };

  programs = {
    eza = {
      enable = true;
      icons = "auto";
      extraOptions = [ "--color=always" ];
    };

    #      alacritty = {
    #        enable = true;
    #        settings = {
    #          window = {
    #            opacity = 0.7;
    #            blur = true;
    #            resize_increments = true;
    #            dynamic_padding = true;
    #          };
    #          bell = {
    #            animation = "EaseOutCubic";
    #            color = "#11a01d";
    #            duration = 500;
    #          };
    #          font.normal = { family = "Meslo LGS NF"; style = "Regular"; };
    #          font.size = 13.5;
    #          cursor.style = { shape = "Block"; blinking = "On"; };
    #          selection.save_to_clipboard = true;
    #        };
    #      };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd=cd" ];
    };

    fzf = {
      enable = true;
      defaultOptions = [
        "--border"
        "--layout=reverse-list"
      ];
      fileWidgetOptions = [
        "--preview 'if [ -d {} ]; then eza -al --icons --color=always --no-permissions --no-time --no-user --group-directories-first {}; else bat -n --color=always --line-range :500 {}; fi'"
      ];
      changeDirWidgetOptions = [
        "--preview 'eza -al --icons --color=always --no-permissions --no-time --no-user --group-directories-first {}'"
      ];
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
        pkgs.unstable.gh-dash
      ];
    };

    bash.enable = true;

    zsh = {
      enable = true;
      initContent = ''
        # Sources
        source ~/.p10k.zsh
        autoload -Uz compinit && compinit -C

        # Keybindings
        bindkey '^f' autosuggest-accept
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word

        # Other options
        setopt globdots

        # Completion styling
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' menu no

        zstyle ':fzf-tab:complete:*' fzf-preview 'if [ -d $realpath ]; then eza -al --icons --color=always --no-permissions --no-time --no-user --group-directories-first $realpath; else bat -n --color=always --line-range :500 $realpath; fi'

        sudo-command-line() {
            [[ -z $BUFFER ]] && zle up-history
            if [[ $BUFFER == sudo\ * ]]; then
                LBUFFER="''${LBUFFER#sudo }"
            else
                LBUFFER="sudo $LBUFFER"
            fi
        }
        zle -N sudo-command-line
        # Defined shortcut keys: [Esc] [Esc]
        bindkey "\e\e" sudo-command-line
      '';

      history = {
        size = 20000;
        save = 20000;
        append = true;
        share = true;
        saveNoDups = true;
        findNoDups = true;
        ignoreDups = true;
        ignoreSpace = true;
        ignoreAllDups = true;
      };

      plugins = [
        {
          name = "zsh-autosuggestions";
          src = fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.7.1";
            sha256 = "sha256-vpTyYq9ZgfgdDsWzjxVAE7FZH4MALMNZIFyEOBLm5Qo=";
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
            rev = "v1.20.0";
            sha256 = "sha256-ES5vJXHjAKw/VHjWs8Au/3R+/aotSbY7PWnWAMzCR8E=";
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
            rev = "v1.2.0";
            sha256 = "sha256-q26XVS/LcyZPRqDNwKKA9exgBByE0muyuNb0Bbar2lY=";
          };
        }
      ];
    };
  };
}
