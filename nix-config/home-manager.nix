{ config, lib, pkgs, ... }:

let
  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = (pkgs.writeShellScriptBin "manpager" ''
    cat "$1" | col -bx | bat --language man --style plain
  '');
  # pkgsUnstable = import <nixpkgs-unstable> {};
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
    nnn
    bat
    fd
    fzf
    htop
    jq
    ripgrep
    gcc
    tree
    watch
    tmux
    gh
    awscli2
    terraform
    gitui
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
    MANPAGER = "${manpager}/bin/manpager";
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
      update = "sudo nixos-rebuild switch --flake /nix-config#nixos";
      n = "nnn -dHC";
    };
    localVariables = {
        EDITOR = "nvim";
    };
    loginExtra = ''
      tmux
    '';
    initExtra = ''
    '';
    enableAutosuggestions = true;
    history = {
      size = 10000;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" "aws" "extract" "terraform" "gh"];
      theme = "robbyrussell";
    };
  };

  # GIT
  # programs.git = {
  #   enable = true;
  #   userName  = "marioconsalvo";
  #   userEmail = "marioconsalvo@unobravo.com";
  # };

  # DIR-ENV
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };


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

