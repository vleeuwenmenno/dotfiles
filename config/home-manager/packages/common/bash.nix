{ config, pkgs, ... }:
{
  home.file.".bashrc.extra".source = "${config.home.homeDirectory}/dotfiles/.bashrc";

  programs.bash = {
    enable = true;
    enableCompletion = true;

    initExtra = ''
      if [ -f ~/.bashrc.extra ]; then
        source ~/.bashrc.extra
      fi
    '';
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
      "--color 'fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f'"
      "--color 'info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54'"
    ];
  };
}
