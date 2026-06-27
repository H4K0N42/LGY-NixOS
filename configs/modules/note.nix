{ pkgs, ... }:
{
  services.libinput.enable = true;
  boot.kernelParams = [
    "i8042.reset"
    "i8042.nomux=1"
    "i8042.nopnp=1"
    "atkdb.reset"
    "pnpacpi=off"
  ];

  users = {
    users.schule = {
      isNormalUser = true;
      description = "Schule";
      extraGroups = [ "dialout" ];
    };
  };

  services = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = false;
        autoLogin.relogin = true;
        settings = {
          Autologin = {
            Session = "plasmax11.desktop";
            User = "schule";
          };
        };
      };
    };
    desktopManager.plasma6.enable = true;
  };

  environment.systemPackages = with pkgs; [
    libreoffice
    onlyoffice-desktopeditors
    arduino-ide
    sqlitebrowser
    thonny
    tigerjython
    python3
    vscodium-fhs
    filius
    logisim
    openjdk
    notepad-next
    tipp10
    cura-appimage
    vlc
    gimp-with-plugins
    musescore
    geogebra
    reaper
  ];

  networking.firewall.enable = false;

  systemd.services.battery-charge-threshold = {
    description = "Set battery charge threshold";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/CMB1/charge_control_end_threshold'";
      RemainAfterExit = true;
    };
  };

}
