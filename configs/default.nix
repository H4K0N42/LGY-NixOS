{ pkgs, hostname, ... }:
{
  # https://search.nixos.org/packages
  environment.systemPackages = with pkgs; [
    git
    ghostty
    chromium
    brave
  ];

  # https://search.nixos.org/options?query=programs.
  programs = {
    chromium = {
      enable = true;
      homepageLocation = "https://www.leibnizgymnasium.de/";
      extraOpts = {
        "BrowserSignin" = 0;
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [
          "de"
        ];
      };
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      ];
    };
    firefox.enable = true;
  };

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

  services.cron.enable = true;
  services.cron.systemCronJobs = [
    "@reboot bash /etc/nixos/git-config/configs/scripts/boot/boot.sh"
  ];

}
