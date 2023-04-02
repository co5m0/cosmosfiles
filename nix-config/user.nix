{ pkgs, ... }:

{

  users = {
    defaultUserShell = pkgs.zsh;
    users.co5mo = {
      isNormalUser = true;
      #home = "/home/co5mo";
      extraGroups = [ "docker" "wheel" ];
      hashedPassword = "$6$p7QbCrHOx6mWHh7u$kIq98sWm18Rn5oWh0mwmtV9YWv7LGEEQopuofD8ZH8/KVwOHZ2l.u1a4dh0oNjSehxW8XVkzexISxLUfwtMFE/";
    };
  };
}
