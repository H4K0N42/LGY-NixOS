{ pkgs, hostname, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    vscodium-fhs
    ghostty
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    timeout = 1;
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev"; # Use "nodev" when using EFI
      backgroundColor = "#000000";
      splashImage = null;
    };
  };

  networking.hostName = hostname;
  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "root" ];
    };

    gc = {
      automatic = true;
      dates = "daily";
      persistent = true;
      options = "--keep 5";
    };

    optimise = {
      automatic = true;
      dates = [ "daily" ];
      persistent = true;
    };
  };

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  console.keyMap = "de";

  # # Sound with pipewire
  # services.pulseaudio.enable = true;
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  # };

  systemd.services.H4shutdown-script = {
    description = "Run script on shutdown";
    # Run before shutdown/reboot
    wantedBy = [
      "shutdown.target"
      "reboot.target"
    ];
    before = [
      "shutdown.target"
      "reboot.target"
      "final.target"
    ];

    # Important: this tells systemd to run it during stop, not start
    unitConfig = {
      DefaultDependencies = "no";
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "/etc/nixos/git-config/configs/scripts/shutdown/shutdown.sh";
    };
  };
}
