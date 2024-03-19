{ config, lib, pkgs, ... }:
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
      fzf
      rustup
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
      includes = [ { path = "~/.dotfiles/config/gitconfig"; } ];
    };

    ssh = {
      enable = true;
      matchBlocks = {
        server = {
          port = 22;
          hostname =  "192.168.86.254";
          user = "menno";
        };
        "accept.prikklok" = {
          port = 22;
          hostname = "49.13.197.18";
          user = "menno";
          forwardAgent = true;
        };
        "prod.prikklok" = {
          port = 22;
          hostname = "49.13.145.100";
          user = "menno";
          forwardAgent = true;
        };
      };
      extraConfig = ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
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
        python = "python3";
      };

      initExtra = ''
        source ~/.dotfiles/config/p10k.zsh

        # PHP using docker
        export PATH=/home/menno/Projects/Sandwave/.data/scripts/php:$PATH

        # FVM
        export PATH=/home/menno/fvm/default/bin:$PATH

        if [ -f /home/menno/Projects/Sandwave/.zshrc ]; then
          source /home/menno/Projects/Sandwave/.zshrc
        fi

        # NVM
        export NVM_DIR="$HOME/.nvm"
  [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"
      '';

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
