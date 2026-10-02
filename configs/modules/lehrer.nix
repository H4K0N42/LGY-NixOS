{ lib, ... }:
{
  services.veyon.publicKey.value = lib.mkForce "";

  # Kein Autologin auf Lehrer-Geräten (überschreibt pc.nix / note.nix)
  services.displayManager.sddm = {
    autoLogin.relogin = lib.mkForce false;
    settings.Autologin = lib.mkForce { };
  };

  users.users.lehrer = {
    isNormalUser = true;
    description = "Lehrer";
    initialHashedPassword = "$y$jCT$RNmkxvxQWr/xA2bJslwvq0$tGoGoXIe4BVRNX89qrB9U0iJkEOMuCsVH1iSukPtB4B";
    extraGroups = [ "dialout" "networkmanager" ];
  };
}
