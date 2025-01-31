# System-wide packages

{ config, pkgs, ... }:

let
  python312-pgks = ps: with ps; [
    anthropic
    jedi
    jedi-language-server
    matplotlib
    numpy
    pylint
    requests
    rich
    scikit-learn
    statsmodels
  ];
  python311-pgks = ps: with ps; [
    (callPackage ../lib/claudesync.nix {})
  ];
in

{
  environment.systemPackages = with pkgs; [
    (callPackage ../bin/default.nix {})
    (python312.withPackages python312-pgks)
    (python311.withPackages python311-pgks)
    ansible
    aspell
    aspellDicts.da
    aspellDicts.en
    autorandr
    bat
    bitwarden
    bitwise
    brave
    busybox
    cachix
    cargo-nextest
    clipmenu
    config.boot.kernelPackages.perf
    cowsay
    curl
    delta
    docker-compose
    dunst
    ed
    element-desktop
    emacsPackages.mu4e
    fd
    firefox-devedition
    flamegraph
    flux
    gcc
    gdu
    gh
    ghostie
    ghostscript
    git
    gnome-keyring
    gnumake
    gnupg
    gnuplot
    graph-easy
    graphviz
    hoppscotch
    htop
    httpie
    hydroxide
    hyperfine
    i3
    imagemagick
    inxi
    jetbrains.idea-community
    jq
    kompose
    kubectl
    libcamera
    libnotify
    light
    lxappearance
    lynx
    man-pages
    man-pages-posix
    minikube
    msmtp
    mu
    multimarkdown
    mysql-shell
    nixfmt-rfc-style
    nmap
    nms
    nodePackages.eslint
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodejs
    offlineimap
    pango
    parallel
    pass
    pgmodeler
    phinger-cursors
    pipx
    poppler
    poppler_utils
    postgresql
    protonmail-bridge
    restic
    ripgrep
    rofi
    rsibreak
    sccache
    shellcheck
    silver-searcher
    simplescreenrecorder
    slack
    solaar
    speedtest-cli
    spotify
    sqlite
    sshfs
    terraform
    terraform-ls
    tk
    tldr
    tree
    tree-sitter-grammars.tree-sitter-typescript
    typescript
    unclutter
    unzip
    upower
    util-linux
    vagrant
    vim
    vscode
    wget
    xautomation
    xdotool
    xflux
    xkb-switch
    xlayoutdisplay
    xorg.xdpyinfo
    xorg.xev
    xorg.xmodmap
    yarn
    yq
    yubikey-manager
    zip
    zoom-us
    zoxide # (callPackage /home/martin/projects/zoxide/default.nix {})
  ];
}
