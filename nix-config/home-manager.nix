{ config, pkgs, ... }:

let
  # Define the custom pnpm package
  latestPnpm = pkgs.stdenv.mkDerivation {
    name = "pnpm";
    version = "9.14.4";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/pnpm/-/pnpm-9.14.4.tgz";
      sha512 =
        "yBgLP75OS8oCyUI0cXiWtVKXQKbLrfGfp4JUJwQD6i8n1OHUagig9WyJtj3I6/0+5TMm2nICc3lOYgD88NGEqw==";
    };
    doCheck = true;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir $out
      cp -r * $out
      mv $out/bin/pnpm.cjs $out/bin/pnpm
      mv $out/bin/pnpx.cjs $out/bin/pnpx
      chmod +x $out/bin/{pnpm,pnpx}
    '';
  };
in {
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "22.11";

  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = with pkgs; [
    neovim
    nnn
    bat
    fd
    fzf
    htop
    jq
    yq
    ripgrep
    gcc
    gnumake
    tree
    watch
    perl
    tmux
    gh
    awscli2
    terraform
    terraform-ls
    tflint
    ssm-session-manager-plugin
    pre-commit
    lua-language-server
    nodePackages.yaml-language-server
    # nodejs-slim_20
    nodePackages_latest.npm
    # typescript-language-server
    typescript
    # latestPnpm
    pnpm
    go
    gopls
    lazygit
    nil
    pulumi-bin
    python3
    kubectl
    k9s
    delta
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
      update = "sudo nix flake update --flake $HOME/nix-config";
      switch = "sodo mount -o remount,size=16G /tmp && sudo nixos-rebuild switch --flake $HOME/nix-config#nixos";
      biomeln = "ln -srf $(git rev-parse --show-toplevel)/node_modules/.pnpm/@biomejs+cli-linux-arm64-musl@1.9.4/node_modules/@biomejs/cli-linux-arm64-musl/biome $(git rev-parse --show-toplevel)/node_modules/.bin/biome";
      n = "nnn -dH";
      rless = "less -r";
      vim = "nvim";
      vi = "nvim";
      tf = "terraform";
      k = "kubectl";
    };
    sessionVariables = {
      EDITOR = "nvim";
      # PATH = "$PATH:$HOME/.pulumi_bin";
      TERMINFO = "$HOME/.terminfo";
      TERM = "xterm-256color";
      NNN_FCOLORS="D4DEB778E79F9F67D2E5E5D2";
    };
    loginExtra = ''
      tmux
    '';
    initExtra = ''
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
    '';
    autosuggestion = {
      enable = true;
    };
    enableCompletion = true;
    enableAutosuggestions = true;
    history = { size = 10000; };
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
        "jira"
        "fzf"
        "kubectl"
      ];
      theme = "agnoster";
      # envirment = { pathsToLink = [ "/share/zsh" ]; };
      extraConfig =
        "\n        PROMPT=\"$PROMPT\\$(vi_mode_prompt_info)\"\n\n        RPROMPT=\"\\$(vi_mode_prompt_info)$RPROMPT\"\n        ";
    };
  };

  # DIR-ENV
  # programs.direnv = {
  #   enable = true;
  #   enableZshIntegration = true;
  # };

  programs.gpg.enable = true;

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

