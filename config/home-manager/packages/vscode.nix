{ pkgs, ... }:
let
  pinnedPkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/d4f247e89f6e10120f911e2e2d2254a050d0f732.tar.gz";
    # Update this SHA256 when a new version is required ^^^
    # You can find them here: https://www.nixhub.io/packages/vscode
  }) { };
in
{
  # Use the pinned VSCode for the programs.vscode configuration
  programs.vscode = {
    enable = true;
    package = pinnedPkgs.vscode;
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
    #   ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    #     {
    #       name = "warpnet.salt-lint";
    #       publisher = "warpnet";
    #       version = "latest";
    #     }
    #     {
    #         name = "mguellsegarra.highlight-on-copy";
    #         publisher = "mguellsegarra";
    #         version = "latest";
    #     }
    #   ];
  };
}
