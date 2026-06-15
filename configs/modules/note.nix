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
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "dbus-run-session startplasma-x11";
          user = "schule";
        };
        default_session = initial_session;
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
  ];
}
