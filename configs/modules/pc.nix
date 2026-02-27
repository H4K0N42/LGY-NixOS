{ pkgs, ... }:
{
  users = {
    users.schule = {
      isNormalUser = true;
      description = "Schule";
      extraGroups = [ ];
    };
  };

  # interfaces.enp1s0.wakeOnLan.enable = true;

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
    git
    vscodium-fhs
    ghostty
  ];
}
