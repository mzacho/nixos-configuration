# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:

{
  nix = {
    # Use my own nixpkgs and home-manager forks
    # nixPath = [
    #   "nixpkgs=${/home/martin/projects/nixpkgs}"
    #   # "home-manager=${/home/martin/projects/home-manager}"
    # ];
    settings = {
      keep-outputs = true;
      keep-derivations = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = ["root" "martin"];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Include home manager
      # Assumes a channel is set up
      <home-manager/nixos>

      # Include system packages
      ./packages/full.nix
    ];

  fileSystems."/persist".neededForBoot = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = import /home/martin/projects/linux/kernel.nix pkgs;

    kernelParams = [
      # fix i8042: Warning: Keylock active during boot
      "i8042.unlock=1"
    ];

    # UEFI boot using systemd-boot
    loader.systemd-boot = {
      enable = true;
      # limit number of boot entries available
      configurationLimit = 40;
    };

    initrd.postDeviceCommands = lib.mkAfter ''
      # echo rolling back root dataset to empty snapshot
      # zfs rollback -r rpool/local/root@blank
      # zfs rollback -r pool/encrypted/local/root@blank

      echo wiping root
      mkdir -p /mnt
      mount -t btrfs /dev/nvme0n1p2 /mnt # @@SUBSTITUTED_BY_SED@@
      echo deleting nested subvolumes created by systemd
      btrfs subvolume delete /mnt/root/srv
      btrfs subvolume delete /mnt/root/tmp
      btrfs subvolume delete /mnt/root/var/tmp
      btrfs subvolume delete /mnt/root/var/lib/portables
      btrfs subvolume delete /mnt/root/var/lib/machines

      echo reverting root to blank snapshot
      btrfs subvolume delete /mnt/root
      btrfs subvolume snapshot /mnt/snapshots/root-blank /mnt/root
      umount /mnt
      echo finished wiping root
    '';
  };

  networking = {
    # Generate hostid
    hostId = "00000000";
    hostName = "0x0b289a08";
    # Manage wireless through network manager, and not the standard
    # networking.wireless scripts
    wireless.enable = false;
    networkmanager.enable = true;
    extraHosts = ''
      192.168.1.150 pi
      100.106.129.112 pitailscale
    '';
  };

  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    useXkbConfig = true;
  };

  fonts = {
    packages = with pkgs; [
      fira-code
      nerdfonts
    ];
  };

  hardware = {
    logitech.wireless.enable = true;
    bluetooth = {
      enable = true;
      settings = {
        General = {
          # Some shizzle needed so my airpods can connect ..
          ControllerMode = "bredr";
        };
      };
    };
  };

  # Enable RealtimeKit for pulseaudio
  security.rtkit.enable = true;

  services = {

    # Configuration of the X window server as well as i3 window
    # manager, and lightdm greeter.
    xserver = {
      enable = true;
      xkb = {
        options = "model:latitude"; #,ctrl:nocaps";
        layout = "us(intl)";
      };

      windowManager.i3 = {
        enable = true;
        extraSessionCommands =
          let dircolors = ./config/dircolors.256dark;
          in ''
        xmodmap ~/.Xmodmap_dvorak_laptop
        xset r rate 200 40
        xsetroot -solid '#002b36'
        xflux -l 55.676098 -g 12.568337
        eval `dircolors ${dircolors}`
        unclutter -idle 1 &

        #rsibreak &
        '';
      };

      displayManager.lightdm.greeters.slick = {
        enable = false;
      };

      videoDrivers = [ "modesetting" ];

      # increase mouse wheel speed
      imwheel = {
        enable = true;
        rules = {
          ".*" = ''
              None, Up,   Button4, 1
              None, Down, Button5, 1
          '';
        };
      };
    };

    libinput.enable = true;

    # Enable pipewire daemon - replaces pulseaudio
    pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    # Make backlight work - give users in the video group permission
    # to change things in sys/class/backlight/intel_backlight
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
    '';

    # Enable emacs server
    emacs = {
      enable = true;
      package = (pkgs.emacsPackagesFor pkgs.emacs29).emacsWithPackages (epkgs: with epkgs; [
        vterm
        treesit-grammars.with-all-grammars
      ]);
      defaultEditor = true;
    };

    # Enable the clipmenu clipboard manager daemon
    clipmenu.enable = true;

    # Enable urvtd daemon, so new terminal are created via
    # urvt clients, to spawn them faster
    urxvtd.enable = true;

    offlineimap = {
      enable = true;
      onCalendar = "*:0/1"; # update every minute
      timeoutStartSec = "59sec";
    };

    protonmail-bridge.enable = true;
    protonmail-bridge.path = with pkgs; [ pass gnome-keyring ];

    gnome.gnome-keyring.enable = true;

    passSecretService.enable = true;

    # Middleware to access a smart card using SCard API (PC/SC).
    pcscd.enable = true;
  };

  # Enable the Docker daemon
  virtualisation.docker = {
    enable = true;
    # Store persistent docker state on persistent file system
    extraOptions = "--data-root /persist/misc/docker";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;

    users.martin = {
      isNormalUser = true;
      extraGroups = [ "audio" "video" "pulse" "networkmanager" "docker" "fuse" "systemd-journal" "adm" "wheel"];
      # Run passwd on first boot
      initialPassword = "change-me";
    };
  };

  programs.dconf.enable = true;

  programs.zsh.enable = true;
  programs.gnupg.agent.enable = true;

  system = {
    copySystemConfiguration = true;

    activationScripts = {
      "symlink-local-state" = {
        deps = [ "users" "groups" ];
        text = let script = pkgs.writeShellScript
          "symlink-local-state" (builtins.readFile
            ./lib/nixos-system-activation-script.sh);
               in "${script}";
      };
    };
  };

  environment = {
    pathsToLink = [
      "/share/nix-direnv"
    ];
  };

  documentation = {
    # Add man pages by dev tools to environment
    dev.enable = true;
    # In order to enable to mandoc man-db has to be disabled.
    man = {
      man-db.enable = false;
      mandoc.enable = true;
    };
  };

  xdg.mime.defaultApplications = {
    "text/html" = "firefox-devedition.desktop";
    "x-scheme-handler/http" = "firefox-devedition.desktop";
    "x-scheme-handler/https" = "firefox-devedition.desktop";
    "x-scheme-handler/about" = "firefox-devedition.desktop";
    "x-scheme-handler/unknown" = "firefox-devedition.desktop";
  };


  ###
  ### User installed packages
  ###

  home-manager = {
    # Install user packages into /etc/profiles instead of
    # ~/.nix-profile (useful for building conf in vms)
    useUserPackages = true;

    # By default, Home Manager uses a private pkgs instance that is
    # configured via the home-manager.users.<name>.nixpkgs options.
    # Use the global pkgs that is configured via the system level
    # nixpkgs options instead.
    #
    # This saves an extra Nixpkgs evaluation, adds consistency, and
    # removes the dependency on NIX_PATH, which is otherwise used for
    # importing Nixpkgs.
    useGlobalPkgs = true;

    # Verbose output on activation
    verbose = true;

    users = {
      martin = {
        # This value determines the Home Manager release that your
        # configuration is compatible with. This helps avoid breakage
        # when a new Home Manager release introduces backwards
        # incompatible changes.
        #
        # You can update Home Manager without changing this value. See
        # the Home Manager release notes for a list of state version
        # changes in each release.
        home.stateVersion = "23.05";

        home.pointerCursor = {
          name = "phinger-cursors-light";
          package = pkgs.phinger-cursors;
          # The available cursor sizes are 24, 32, 48, 64, 96 and 128
          size = 32;
          gtk.enable = true;
        };

        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;

        programs.gpg.scdaemonSettings.disable-ccid = true;

        programs.zsh = {
          enable = true;
          sessionVariables = {
            MY_HOSTNAME = "$(hostnamectl hostname)";
            EDITOR="emacseditor -r --socket-name=/run/user/1000/emacs/server";

            XDG_DATA_HOME = "$HOME/.local/share";
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_STATE_HOME = "$HOME/.local/state";
            XDG_CACHE_HOME = "$HOME/.cache";
            XDG_RUNTIME_DIR = "/tmp/run/$UID";

            SCREENSHOTS = "$HOME/Screenshots";

            GPG_TTY = "$(tty)";

            PYENV_ROOT = "$HOME/.pyenv";
            PYTHONUSERBASE = "$HOME/.python-user-base";
            # Use Jedi completion in repl
            # export PYTHONSTARTUP="$(python3 -m jedi repl)"
            PYTHONSTARTUP = "$HOME/lib/pythonstartup.py";

            NVM_DIR = "$XDG_DATA_HOME/.nvm";

            # Preview file content using bat
            FZF_CTRL_T_OPTS = ''
              --preview \"bat -n --color=always {}\"
              --bind \"ctrl-/:change-preview-window(down|hidden|)\"'';

            # CTRL-/ to toggle small preview window to see the full command
            # CTRL-Y to copy the command into clipboard using pbcopy
            FZF_CTRL_R_OPTS = ''
              --preview \"echo {}\" --preview-window up:3:hidden:wrap
              --bind \"ctrl-/:toggle-preview\"
              --bind \"ctrl-y:execute-silent(echo -n {2..} |  pbcopy)+abort\"
              --color header:italic
              --header \"Press CTRL-Y to copy command into clipboard\"'';

            # Print tree structure in the preview window
            FZF_ALT_C_OPTS = "--preview 'tree -C {}'";

            # Customize colors used by ls and exa
            # export LSCOLORS=ExfxcxdxbxEgEdabagacad
            EXA_COLORS="uu=38;5;248:gu=38;5;248:da=32";

            # Colorize man pages using bat
            # MANPAGER="sh -c 'col -bx | bat -l man -p'";

            # zsh
            HISTSIZE=1000000000;
            SAVEHIST=1000000000;

            # add extra dirs to PATH
            PATH="$PATH:/home/martin/.yarn/bin:/home/martin/.local/bin";
          };

          initExtra = ''
            # Silence, please
            unsetopt beep

            # Set emacs as zle (zsh line editor) main keymap
            bindkey -e

            # Ignore duplicates in zsh history
            setopt HIST_EXPIRE_DUPS_FIRST
            setopt HIST_IGNORE_DUPS
            setopt HIST_IGNORE_ALL_DUPS
            setopt HIST_IGNORE_SPACE
            setopt HIST_REDUCE_BLANKS
            setopt HIST_FIND_NO_DUPS
            setopt HIST_SAVE_NO_DUPS
            # Confirm before executing history expansions
            setopt HIST_VERIFY
            # Share history entries between terminals
            # unsetopt SHARE_HISTORY
            # setopt INC_APPEND_HISTORY
          '';

          shellAliases = {
            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";

            alphabet = "echo ABCDEFGHIJKLMNOPQRSTUVWXYZ && echo \"0....5....1....5....2....5..\"";
            cat = "bat --style=\"plain,changes\"";
            cd = "z"; # zoxide
            cx = "chmod u+x";            
            d = "docker";
            dc = "docker-compose";
            e = "emacs-find-file.sh";
            eb = "emacs-send-to-new-buffer.sh";
            fzf = "fzf --preview \"bat --color=always --style=number --line-range=:500 {}\"";
            g = "git";
            h = "bat --plain --language=help";
            jc = "journalctl";
            k = "kubectl";
            l = "ls -ovAFhb --group-directories-first --color=auto";
            logout = "dm-tool switch-to-greeter";
            m = "man";
            mk = "minikube";
            ne = "nix-env";
            nix = "nix --extra-experimental-features nix-command";
            ns = "nix-shell";
            pwgen = "bw generate -uln --length 55 | pbcopy; echo new password copied";
            pwgpg = "bitwarden-get-password.sh GPG f89f3266-3670-4000-87a1-aec900b0a7f8";
            pwssh = "bitwarden-get-password.sh SSH 2a6c14a5-2e32-471f-ab89-aed50095f57e";
            py = "python3";
            # reboot = "zfs-backup-root-and-reboot.sh";
            sc = "systemctl";
            tf = "terraform";
            assume = "source assume";

            light-theme = "light-theme.sh";
            dark-theme = "dark-theme.sh";
          };
        };
        programs.zsh.oh-my-zsh = {
          enable = true;
          theme = "robbyrussell";
          custom = "$HOME/lib/oh-my-zsh/custom";
          plugins = [
            "dircycle"
            "docker"
            "docker-compose"
            "gh"
            "fzf-tab"
            "zoxide"
            "zsh-autopair"
            "zsh-syntax-highlighting"
            "history-substring-search"
          ];
          extraConfig = ''
            zstyle ':omz:update' mode disabled
            zstyle ':omz:update' frequency 1
            zstyle ':fzf-tab:complete:z:*' fzf-preview 'exa -1 --icons --color=always $realpath'
            zstyle ':fzf-tab:*' continuous-trigger 'tab'

            DISABLE_MAGIC_FUNCTIONS="false"
            ENABLE_CORRECTION="true"
            DISABLE_UNTRACKED_FILES_DIRTY="true"
            HIST_STAMPS="mm/dd/yyyy"

            export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=red,fg=white,bold'
            export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#4a4a4a'
          '';
        };
        programs.fzf.enable = true;

        programs.gh = {
          enable = true;
          settings = {
            git.protocol = "ssh";
            editor = "emacs";
            prompt = "enabled";
            pager = "less";
          };
        };

        programs.direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };

        home = {
          file =
            let
              # TODO: encrypt with age
              #
              # this is not super secret, as it's just proton mails
              # bridges pr. install generated pw, and local to my
              # machine (if an attacker can access my bridge I have
              # bigger issues than worrying about leaking this...)
              protonmail-bridge-password =
                builtins.readFile /persist/misc/protonmail-bridge-pass;
            in {
              "lib" = {
                source = (pkgs.callPackage ./lib/default.nix {});
              };

              ".urxvt/ext/font-size" = {
                source = ./config/urxvt-font-size.sh;
              };

              ".utoprc" = {
                # Ocaml repl syntax highlight
                enable = false;
                source = ./config/utoprc;
              };

              ".gdbinit" = {
                # gdb syntax highlight
                enable = false;
                source = ./config/gdbinit.py;
              };

              ".config/gh/hosts.yml" = {
                source = ./config/gh-hosts.yml;
              };

              ".config/git/config" = {
                source = (pkgs.substituteAll {
                  src = ./config/gitconfig;
                  smtppass = protonmail-bridge-password;
                });
              };

              ".config/htop/htoprc" = {
                source = ./config/htoprc;
              };

              ".config/flake8" = {
                enable = false;
                source = ./config/flake8;
              };

              ".config/fd/ignore" = {
                source = ./config/fd-ignore;
              };

              ".tmux.conf" = {
                enable = false;
                source = ./config/tmux.conf;
              };

              ".config/rofi/config.rasi" = {
                source = ./config/rofi/config-solarized-dark.rasi;
              };

              ".offlineimaprc" = {
                source = (pkgs.substituteAll {
                  src = ./config/.offlineimaprc;
                  protonimappass = protonmail-bridge-password;
                });
              };

              ".msmtprc" = {
                source = (pkgs.substituteAll {
                  src = ./config/.msmtprc;
                  protonsmtppass = protonmail-bridge-password;
                });
              };

              ".config/X11/Xresources-default" = {
                source = let resources = [
                  (builtins.readFile ./config/X11/Xresources-internal-monitor)
                  (builtins.readFile ./config/X11/Xresources-solarized-dark)
                  (builtins.readFile ./config/X11/Xresources-urxvt)
                ]; in pkgs.writeText "xresources"
                  (pkgs.lib.fold (a: f: a + f) "" resources);
              };

              ".config/X11/Xresources-home-station" = {
                source = let resources = [
                  (builtins.readFile ./config/X11/Xresources-4k-monitor)
                  (builtins.readFile ./config/X11/Xresources-solarized-dark)
                  (builtins.readFile ./config/X11/Xresources-urxvt)
                ]; in pkgs.writeText "xresources"
                  (pkgs.lib.fold (a: f: a + f) "" resources);
              };

              ".config/X11/Xresources-light-192dpi" = {
                source = let resources = [
                  (builtins.readFile ./config/X11/Xresources-4k-monitor)
                  (builtins.readFile ./config/X11/Xresources-solarized-light)
                  (builtins.readFile ./config/X11/Xresources-urxvt)
                ]; in pkgs.writeText "xresources"
                  (pkgs.lib.fold (a: f: a + f) "" resources);
              };

              ".config/X11/Xresources-light-96dpi" = {
                source = let resources = [
                  (builtins.readFile ./config/X11/Xresources-internal-monitor)
                  (builtins.readFile ./config/X11/Xresources-solarized-light)
                  (builtins.readFile ./config/X11/Xresources-urxvt)
                ]; in pkgs.writeText "xresources"
                  (pkgs.lib.fold (a: f: a + f) "" resources);
              };

              ".config/X11/Xresources-dark-192dpi" = {
                source = let resources = [
                  (builtins.readFile ./config/X11/Xresources-4k-monitor)
                  (builtins.readFile ./config/X11/Xresources-solarized-dark)
                  (builtins.readFile ./config/X11/Xresources-urxvt)
                ]; in pkgs.writeText "xresources"
                  (pkgs.lib.fold (a: f: a + f) "" resources);
              };

              ".config/X11/Xresources-dark-96dpi" = {
                source = let resources = [
                  (builtins.readFile ./config/X11/Xresources-internal-monitor)
                  (builtins.readFile ./config/X11/Xresources-solarized-dark)
                  (builtins.readFile ./config/X11/Xresources-urxvt)
                ]; in pkgs.writeText "xresources"
                  (pkgs.lib.fold (a: f: a + f) "" resources);
              };


            };

          extraOutputsToInstall = [
            "doc"
            "info"
            "devdoc"
          ];
        };
      };
    };
  };

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05";
}
