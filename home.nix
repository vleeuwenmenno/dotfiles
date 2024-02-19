{ config, pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home = {
    username = "menno";
    homeDirectory = "/home/menno";
    stateVersion = "23.11";

    packages = with pkgs; [
      gnumake
      btop
      go
      fortune
      lsd
      zsh
      zsh-powerlevel10k
    ];
  };

  programs = {
    home-manager.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    git = {
      enable = true;
      userName = "Menno van Leeuwen";
      userEmail = "menno@vleeuwen.me";
      includes = [ { path = "~/.dotfiles/config/gitconfig"; } ];
    };

    zsh = {
      enable = true;

      oh-my-zsh = {
          enable = true;
          plugins = [
            "git"
            "docker"
            "1password"
            "ubuntu"
            "tmux"
            "sudo"
            "screen"
            "adb"
            "brew"
            "ufw"
            "zsh-interactive-cd"
            "zsh-navigation-tools"
            "yarn"
            "vscode"
            "composer"
            "laravel"
            "golang"
            "httpie"
          ];
      };

      shellAliases = {
        l = "lsd -Sl --reverse --human-readable --group-directories-first";
        update = "git -C ~/.dotfiles pull && home-manager switch --flake ~/.dotfiles";
        docker-compose = "docker compose";
        gg = "git pull";
        gl = "git log --stat";
      };

      initExtra = "source ~/.dotfiles/config/p10k.zsh";

      syntaxHighlighting = {
        enable = true;
      };

      plugins = with pkgs; [
        {
          name = "powerlevel10k";
          src = zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];
    };
  };
}
