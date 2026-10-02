{ lib, ... }:
{
  services.veyon.publicKey.value = lib.mkForce "";

  users.users.lehrer = {
    isNormalUser = true;
    description = "Lehrer";
    initialHashedPassword = "$y$jCT$RNmkxvxQWr/xA2bJslwvq0$tGoGoXIe4BVRNX89qrB9U0iJkEOMuCsVH1iSukPtB4B";
    extraGroups = [ "dialout" "networkmanager" ];
  };
}
