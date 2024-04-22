{ config, lib, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  fonts.fontconfig.enable = true;
  home = {
    username = "menno";
    homeDirectory = "/home/menno";
    stateVersion = "23.11";

    packages = with pkgs; [
      nerdfonts
      screen
      direnv
      flutter
      tmux
      gnumake
      btop
      go
      fortune
      cowsay
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
      includes = [{ path = "~/.dotfiles/config/gitconfig"; }];
    };

    ssh = {
      enable = true;
      matchBlocks = {
        server = {
          port = 22;
          hostname = "100.124.76.123";
          user = "menno";
        };
        pc = {
          port = 22;
          hostname = "100.107.105.42";
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
        "python3.10" = "/nix/store/hfb9yd6bl3ch0zankxk0v49kd1nj3a3x-home-manager-path/bin/python3";

        # Requires https://github.com/jarun/advcpmv
        mv = "/usr/local/bin/mvg -g";
        cp = "/usr/local/bin/cpg -g";
      };

      initExtra = ''
              source ~/.dotfiles/config/p10k.zsh

              # PHP using docker
              export PATH=/home/menno/Projects/Sandwave/.data/scripts/php:$PATH

              # JetBrains Toolbox
              export PATH=/home/menno/JetBrains/Scripts:$PATH

              if [ -f /home/menno/Projects/Sandwave/.zshrc ]; then
                source /home/menno/Projects/Sandwave/.zshrc
              fi

              # PyENV
              export PYENV_ROOT="$HOME/.pyenv"
              [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
              eval "$(pyenv init -)"

              # NVM
              export NVM_DIR="$HOME/.nvm"
        [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"  # This loads nvm
        [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"

              # Ensure nix is in path
              export PATH=/home/menno/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH
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
