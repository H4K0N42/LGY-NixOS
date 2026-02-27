{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      hostname = nixpkgs.lib.trim (builtins.readFile /etc/hostname);

      segmentModules = {
        "PC" = [ ./git-config/configs/modules/pc.nix ];
        "NOTE" = [ ./git-config/configs/modules/notebook.nix ];
      };

      modulesForHostname =
        h:
        let
          segments = nixpkgs.lib.splitString "-" (nixpkgs.lib.toUpper h);

          combinations = nixpkgs.lib.concatMap (
            start:
            map (end: nixpkgs.lib.concatStringsSep "-" (nixpkgs.lib.sublist start (end - start) segments)) (
              nixpkgs.lib.range (start + 1) (builtins.length segments)
            )
          ) (nixpkgs.lib.range 0 (builtins.length segments - 1));

        in
        nixpkgs.lib.concatMap (combo: segmentModules.${combo} or [ ]) combinations;

    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./git-config/configs/default.nix
        ]
        ++ modulesForHostname hostname;
      };
    };
}
