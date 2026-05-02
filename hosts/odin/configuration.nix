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

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "odin";
    networkmanager.enable = true;
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
    steam.enable = true;
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

  # Reduce niri VRAM usage (NVIDIA heap reuse quirk)
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-niri-vram.json".text = builtins.toJSON {
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

  environment.systemPackages = with pkgs; [
    git
    gh
    wget
    sshfs
    gnome-software

    # Wayland session utilities
    fuzzel
    mako
    waybar
    swaylock
    swayidle
    wl-clipboard
    xwayland-satellite

    # Desktop shell
    noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

    google-chrome

    simple-scan
    # nixpkgs#481158 fix not yet backported to 25.11; remove override after.
    (naps2.overrideAttrs (old: {
      runtimeDeps = (old.runtimeDeps or [ ]) ++ [ libtiff ];
    }))
    pdfarranger
  ];

  system.stateVersion = "25.11";
}
