{ pkgs, ... }: {
  home.packages = with pkgs; [
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
    pyenv
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
    mcfly # Better shell history
    fzf # Fuzzy finder
    tokei # Code statistics
    tealdeer # Modern tldr client
    lazygit # Terminal UI for git

    # Shell and terminal
    starship # Cross-shell prompt
    zellij # Modern terminal multiplexer
    nushell # Modern shell
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

    # GUI Applications
    ## Utilities
    mission-center
    flameshot
    gnome.gnome-tweaks
    pinta
    bottles
    trayscale

    ## Chat Apps
    telegram-desktop
    betterdiscordctl
    vesktop
    whatsapp-for-linux
    signal-desktop

    ## Multimedia
    spotify
    plex-media-player

    ## Astronomy
    stellarium

    ## Games
    openra
  ];
}
