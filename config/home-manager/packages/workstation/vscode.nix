{ pkgs, pkgs-unstable, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs-unstable.vscode;
    mutableExtensionsDir = true;
    extensions = with pkgs.vscode-extensions; [
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode.makefile-tools
      ms-vsliveshare.vsliveshare
      bbenoist.nix
      aaron-bond.better-comments
      alexisvt.flutter-snippets
      bmewburn.vscode-intelephense-client
      christian-kohler.path-intellisense
      dart-code.dart-code
      dart-code.flutter
      esbenp.prettier-vscode
      foxundermoon.shell-format
      github.vscode-github-actions
      github.vscode-pull-request-github
      usernamehw.errorlens
      vincaslt.highlight-matching-tag
      vscode-icons-team.vscode-icons
      golang.go
      davidanson.vscode-markdownlint
      bbenoist.nix
      brettm12345.nixfmt-vscode
      yzhang.markdown-all-in-one
      xdebug.php-debug
      github.copilot
      github.copilot-chat
    ];
  };
}
