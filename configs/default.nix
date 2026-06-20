{
  config,
  pkgs,
  hostname,
  inputs,
  ...
}:
{
  # https://search.nixos.org/packages
  environment.systemPackages = with pkgs; [
    git
    ghostty
    chromium
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

  services.flatpak.enable = true;
  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo;";
    }
  ];
  services.flatpak.packages = [
    "edu.mit.Scratch"
  ];

  services.xserver.enable = true;

  services.veyon = {
    enable = true;
    publicKey = {
      name = "LGY-NixOS";
      value = ''
        -----BEGIN PUBLIC KEY-----
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyDNqvh1Yuw2T6Z2u0MYc
        xcaCQuQYTyslIjKN5w6VeCKnmMzhG+pCEB4ka/JdRp2rf5pl+6ZK1hvK+inL2ngn
        FtZA48pu3fXa0D92VBZsZgsbDBqfJ6l9tK1tBvCrEw3wcA3Lx7MYCkR5rbShC5M2
        ZjntGKmkmhTFq9xRAWc0oTLIqrjwPN67jpSLCvnAf+N8YUanzDzud13M+nn0JkAi
        XfMybnHkqp09R1n6w0IBB1hXunJgMu2fdZ6e0fzQVP0KfrB2JOyB89lAXUw40VAV
        27MF/bFcCOE2skZu1dazB8TvjlmAPjLhKhJZr1ERJ2H2Fhrj4x5V2zXC0bqkEyXa
        kaH0YnSEn8idtGdeKbSkALG67tYDdfS1g8vrs/4d5xi4nPWp1c+tQtX842lDiQ+8
        GsROOA1jUgFkCPmljxIuG7wyetv6iOhRzpUWKndkuIJYBJzDKca1X8oPpkmgduWz
        OBGYrutUVdfIImPLrWUFpra+2I48Dhd1u2wPLmjTmPnEeDfePWjpxrEQNleN6EQi
        CBnmUvkw6kv2urfAVxMz6ySnn8uui7/NniXXWL0OSdhBt3kQ3gHdi4mnYH7jb65i
        +va0xmgMwDdACzS9kQdMGLiXp3kLQ9QZrfjg3Ka45UC/ioDRcoQWOin6/GCkjkBk
        0petrU/JDBLpZNd+xb+oXu0CAwEAAQ==
        -----END PUBLIC KEY-----
      '';
    };
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    timeout = 1;
    systemd-boot = {
      enable = true;
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

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  systemd.services.H4Update = {
    description = "Update NixOS";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "/etc/nixos/git-config/configs/scripts/update.sh"
        "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch"
      ];
      WorkingDirectory = "/etc/nixos/git-config";
      User = "root";
      RemainAfterExit = true;
    };
  };

  systemd.services.H4BootScript = {
    description = "Startup Script";

    after = [ "local-fs.target" ];
    before = [ "display-manager.service" ];
    wantedBy = [ "display-manager.service" ];

    path = with pkgs; [
      rsync
      coreutils
      bash
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/etc/nixos/git-config/configs/scripts/boot/boot.sh";
    };
  };

  systemd.services.display-manager.after = [ "H4BootScript.service" ];
  systemd.services.display-manager.requires = [ "H4BootScript.service" ];
}
