{
  pkgs,
  pkgs-unstable,
  hostname,
  ...
}:
{
  # Import host-specific packages
  imports =
    if hostname == "mennos-gamingpc" then
      [ ./hosts/mennos-gamingpc.nix ]
    else if hostname == "mennos-laptop" then
      [ ./hosts/mennos-laptop.nix ]
    else if hostname == "mennos-server" then
      [ ./hosts/mennos-server.nix ]
    else
      [ ./hosts/fallback.nix ];

  home.packages =
    with pkgs;
    [
      # General packages
      git
      gnupg
      gh
      nixfmt-rfc-style
      wget
      fastfetch

      # Package management
      pipx
      devbox

      # Development SDKs/Toolkits
      gcc
      pkg-config
      gnumake
      stdenv.cc
      rustc
      cargo
      cargo-edit
      cargo-watch
      cargo-audit
      cargo-expand
      cargo-tarpaulin
      act # GitHub Actions CLI

      # File and directory operations
      eza # Modern ls
      bat # Modern cat
      zoxide # Smarter cd command
      broot # Interactive directory navigator
      du-dust # Modern du
      duf # Modern df
      zip
      unzip
      bottom # Modern top/htop
      glances # Advanced system monitoring tool
      procs # Modern ps
      hyperfine # Benchmarking tool

      # Search and text processing
      ripgrep # Modern grep
      sd # Modern sed
      choose # Modern cut
      jq # JSON processor
      yq # YAML processor
      xsv # CSV processor

      # System monitoring and process management
      procs # Modern ps
      bottom # Modern top/htop
      hyperfine # Benchmarking tool
      bandwhich # Network utilization tool
      doggo # Modern dig
      gping # Ping with graph
      htop # Interactive process viewer

      # Development utilities
      delta # Better git diff
      difftastic # Structural diff tool
      fzf # Fuzzy finder
      tokei # Code statistics
      tealdeer # Modern tldr client
      lazygit # Terminal UI for git

      # Shell and terminal
      starship # Cross-shell prompt
      blesh # Bash ble.sh
      zellij # Modern terminal multiplexer
      screen # Terminal multiplexer

      # File viewers and processors
      hexyl # Modern hexdump
      chafa # Terminal image viewer
      glow # Markdown renderer

      # Editors
      neovim
      nano
      micro

      # Lolz
      fortune
      cowsay
      cmatrix
      figlet
      lolcat
    ]
    ++ (with pkgs-unstable; [ ]);
}
