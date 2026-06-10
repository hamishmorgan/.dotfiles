{
  nixpkgs-stable,
  pkgs,
  noctalia,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "hamish" ];
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0;
    };
    registry.nixpkgs.flake = nixpkgs-stable;
    nixPath = [ "nixpkgs=${nixpkgs-stable}" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    # Disable UMIP. Wine/Proton games (notably TW:WH3 and several other titles
    # via anti-tamper/EOS) execute SGDT/SIDT from user mode; with UMIP active the
    # kernel software-emulates each one, which spams dmesg, starves the game's
    # update loop, and has been correlated with NVIDIA XID faults and crashes.
    # Trade-off: removes a hardening feature that blocks some info-disclosure
    # attacks via descriptor-table addresses. Acceptable on a personal desktop.
    kernelParams = [ "clearcpuid=514" ];
  };

  networking = {
    hostName = "odin";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Display manager and desktops
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    gnome.core-apps.enable = false;

    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };

    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    envfs.enable = true;
    flatpak.enable = true;
  };

  programs = {
    niri.enable = true;
    nix-ld.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    firefox.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    fish.enable = true;
    zsh.enable = true;
    gnupg.agent.enable = true;
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "hamish" ];
    };
  };

  hardware = {
    sane.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = true; # GA102 (Ampere) supports open kernel modules; revert if issues
      nvidiaSettings = true;
    };
    graphics.enable = true;
    bluetooth = {
      enable = true;
      settings.General.Experimental = true;
    };
    enableRedistributableFirmware = true;
    firmware = [ pkgs.broadcom-bt-firmware ];
  };

  # Auth and secrets (polkit, gnome-keyring, and xdg portals are provided by GNOME)
  security.pam.services.swaylock = { };

  nixpkgs.config.allowUnfree = true;

  users.users.hamish = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "scanner"
      "lp"
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  environment = {
    # Raise NVIDIA's shader disk cache cap so DXVK/VKD3D pipelines aren't evicted
    # between launches. Driver default is 1 GB, which TW:WH3 and similar blow past,
    # causing recompilation stutter and CPU spikes every session.
    sessionVariables = {
      __GL_SHADER_DISK_CACHE = "1";
      __GL_SHADER_DISK_CACHE_SIZE = "12000000000"; # 12 GB
    };

    # Reduce niri VRAM usage (NVIDIA heap reuse quirk)
    etc."nvidia/nvidia-application-profiles-rc.d/50-niri-vram.json".text = builtins.toJSON {
      rules = [
        {
          pattern = {
            feature = "procname";
            matches = "niri";
          };
          profile = "niri";
        }
      ];
      profiles = [
        {
          name = "niri";
          settings = [
            {
              key = "GLVidHeapReuseRatio";
              value = 0;
            }
          ];
        }
      ];
    };

    systemPackages = with pkgs; [
      git
      gh
      wget
      sshfs
      gnome-software

      # Wayland session utilities
      # fuzzel, mako, and waybar removed: noctalia v5 provides the launcher,
      # notifications, and bar. mako in particular raced noctalia for
      # org.freedesktop.Notifications on login (D-Bus activation).
      swaylock
      swayidle
      wl-clipboard
      xwayland-satellite

      # Desktop shell.
      # noctalia-shell 5.0.0's -O3 release build crashes GCC with an ICE
      # (gt_ggc_m_S, ggc-page.cc:1517) on config_service.cpp. The binary isn't in
      # noctalia.cachix.org for our inputs, so it builds locally and hits the crash.
      # Inject -O2 into the release-only add_project_arguments block: it lands after
      # meson's -O3 on the command line, so -O2 wins, while -DNDEBUG/release stay.
      # --replace-fail so this aborts loudly if upstream changes the flags.
      (noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace meson.build \
            --replace-fail "'-fomit-frame-pointer'," "'-O2', '-fomit-frame-pointer',"
        '';
      }))

      google-chrome

      simple-scan
      # nixpkgs#481158 fix not yet backported to 25.11.
      # buildDotnetModule consumes runtimeDeps before mkDerivation, so
      # overrideAttrs can't reach it — wrap the bin externally instead.
      (symlinkJoin {
        name = "naps2-with-libtiff";
        paths = [ naps2 ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/naps2 \
            --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libtiff ]}
        '';
      })
      pdfarranger
      localsend

      tesseract
      poppler-utils
    ];
  };

  system.stateVersion = "25.11";
}
