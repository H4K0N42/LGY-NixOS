{ pkgs, ... }:
{
  services.libinput.enable = true;

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
        wayland.enable = true;
        autoLogin.relogin = true;
        settings = {
          Autologin = {
            Session = "plasma.desktop";
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
  ];
}
