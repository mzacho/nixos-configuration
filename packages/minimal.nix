{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (callPackage ../bin/default.nix {})
    aspell
    aspellDicts.da
    aspellDicts.en
    bat
    brave
    clipmenu
    curl
    gnome-keyring
    gnupg
    htop
    light
    i3
    man-pages
    man-pages-posix
    rofi
    util-linux
    silver-searcher
    wget
    xorg.xev
    xorg.xmodmap
    zoxide
  ];
}
