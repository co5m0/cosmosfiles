{
  config,
  pkgs,
  serena,
  jail,
  dagger,
  ...
}:

let
in
{

  imports = [ ./jail.nix ];

  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "25.05";
  home.homeDirectory = "/home/co5mo";
  home.username = "co5mo";

  # programs.home-manager.enable = true;

  xdg.enable = true;
  services.ssh-agent.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = with pkgs; [
    serena.packages.${pkgs.system}.serena
    dagger.packages.${pkgs.system}.dagger
    neovim
    nnn
    bat
    fd
    fzf
    jq
    yq
    ripgrep
    tree
    tmux
    gh
    awscli2
    aws-vault
    # terraform
    # terraform-ls
    # tflint
    ssm-session-manager-plugin
    lua-language-server
    yaml-language-server
    # nodePackages_latest.aws-cdk
    # nodejs-slim_20
    # nodePackages_latest.npm
    # typescript-language-server
    typescript
    go
    gopls
    lazygit
    nil
    pulumi-bin
    kubectl
    k9s
    kind
    delta
    gemini-cli-bin
    rust-analyzer
    # zig
    # zls
    opencode
    claude-code
    corepack_24
    lazysql
    legcord
    # nixd
    nixfmt
    uv
    codex
    yazi
    rtk
  ];

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  # ZSH
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      update = "nix flake update --flake ~/.nix";
      switch = "nix run nixpkgs#home-manager -- switch --flake ~/.nix#co5mo";
      # biomeln = "ln -srf $(git rev-parse --show-toplevel)/node_modules/.pnpm/@biomejs+cli-linux-arm64-musl@1.9.4/node_modules/@biomejs/cli-linux-arm64-musl/biome $(git rev-parse --show-toplevel)/node_modules/.bin/biome";
      # n = "nnn -dH";
      rless = "less -r";
      vim = "nvim";
      vi = "nvim";
      tf = "terraform";
      k = "kubectl";
      lgit = "lazygit";
      lsql = "lazysql";
      ldocker = "lazydocker";
      grep = "rg";
    };
    dotDir = "${config.xdg.configHome}/zsh";
    sessionVariables = {
      EDITOR = "nvim";
      TERMINFO = "$HOME/.terminfo";
      TERM = "xterm-256color";
      NNN_FCOLORS = "D4DEB778E79F9F67D2E5E5D2";
    };
    # loginExtra = ''
    #   case $- in *i*)
    #     [ -z "$TMUX" ] && exec tmux
    #   esac
    # '';
    initExtraFirst = ''
      typeset -U path PATH
      path=("$HOME/.local/share/flutter/bin" $path)
    '';
    initContent = ''
      if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
        tmux attach-session -t default || tmux new-session -s default
      fi

      DEFAULT_USER=$USER
      VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
      MODE_INDICATOR="%F{white}N%f"
      INSERT_MODE_INDICATOR="%F{yellow}I%f"
      VI_MODE_SET_CURSOR=true
      prompt_context(){}
      prompt_dir(){
          prompt_segment cyan $CURRENT_FG '%~'
      }
      ch(){
          curl https://raw.githubusercontent.com/cheat/cheatsheets/refs/heads/master/$1
      }
      function n() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
          command yazi "$@" --cwd-file="$tmp"
          IFS= read -r -d '\' cwd < "$tmp"
          [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
          rm -f -- "$tmp"
       }
    '';
    autosuggestion = {
      enable = true;
    };
    enableCompletion = true;
    history = {
      size = 10000;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "aws"
        "extract"
        "terraform"
        "gh"
        "vi-mode"
        "fzf"
        "kubectl"
      ];
      theme = "agnoster";
      # envirment = { pathsToLink = [ "/share/zsh" ]; };
      extraConfig = "\n        PROMPT=\"$PROMPT\\$(vi_mode_prompt_info)\"\n\n        RPROMPT=\"\\$(vi_mode_prompt_info)$RPROMPT\"\n        ";
    };
  };

  # DIR-ENV
  # programs.direnv = {
  #   enable = true;
  #   enableZshIntegration = true;
  # };

  #programs.direnv= {
  #  enable = true;

  #  config = {
  #    whitelist = {
  #      prefix= [
  #        "$HOME/code/go/src/github.com/hashicorp"
  #        "$HOME/code/go/src/github.com/mitchellh"
  #      ];

  #      exact = ["$HOME/.envrc"];
  #    };
  #  };
  #};
}
