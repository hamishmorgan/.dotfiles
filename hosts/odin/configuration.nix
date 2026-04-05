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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;
  nix.settings.max-jobs = "auto";
  nix.settings.cores = 0;

  nix.registry.nixpkgs.flake = nixpkgs-stable;
  nix.nixPath = [ "nixpkgs=${nixpkgs-stable}" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "odin";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Display manager and desktops
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable = false;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Niri (scrollable tiling Wayland compositor)
  programs.niri.enable = true;

  # Nvidia
  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # GA102 (Ampere) supports open kernel modules; revert if issues
    nvidiaSettings = true;
  };
  hardware.graphics.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # Bluetooth (Broadcom BCM20702A1)
  hardware.bluetooth.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.broadcom-bt-firmware ];

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

  # Printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
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
    ];
  };

  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  services.flatpak.enable = true;

  programs.steam.enable = true;
  programs.firefox.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;

  programs.gnupg.agent.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "hamish" ];
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
  ];

  system.stateVersion = "25.11";
}
