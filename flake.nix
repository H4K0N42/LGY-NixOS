{
  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    veyon.url = "git+https://github.com/H4K0N42/veyon.git?submodules=1"; # TODO: replace H4K0N42 with veyon when pull request is merged
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      flakeDir = builtins.toString ./.;
      hostnameFile = flakeDir + "/hostname";
      hostname = nixpkgs.lib.trim (builtins.readFile hostnameFile);

      segmentModules = {
        "PC" = [ ./git-config/configs/modules/pc.nix ];
        "NOTE" = [ ./git-config/configs/modules/note.nix ];
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
        specialArgs = { inherit inputs hostname; };
        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          inputs.veyon.nixosModules.default
          ./configuration.nix
          ./git-config/configs/default.nix
        ]
        ++ modulesForHostname hostname;
      };
    };
}
