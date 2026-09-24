{ pkgs, lib, ... }:
let
  repoUrl = "https://github.com/H4K0N42/LGY-NixOS";
  workDir = "/var/lib/lgy-cache";
  keyDir = "/var/lib/secrets";

  # Variants the builder pre-builds; must match the keys of segmentModules in flake.nix
  variants = [
    "PC"
    "NOTE"
  ];

  # Minimal stand-in for /etc/nixos/configuration.nix on a client. The package
  # closure is independent of the real hardware, so this is enough to fill the cache.
  stubConfiguration = pkgs.writeText "configuration.nix" ''
    { lib, ... }:
    {
      imports = lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;
      fileSystems."/" = lib.mkDefault { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; };
      system.stateVersion = "26.05";
    }
  '';

  buildScript = pkgs.writeShellScript "lgy-cache-build" ''
    set -euo pipefail

    if [ -d ${workDir}/repo/.git ]; then
      git -C ${workDir}/repo fetch --quiet origin
      git -C ${workDir}/repo reset --quiet --hard origin/main
      git -C ${workDir}/repo submodule update --init --recursive --quiet
    else
      git clone --quiet --recurse-submodules ${repoUrl} ${workDir}/repo
    fi

    rev=$(git -C ${workDir}/repo rev-parse HEAD)
    if [ "$rev" = "$(cat ${workDir}/last-built 2>/dev/null)" ]; then
      echo "Commit $rev already built, nothing to do."
      exit 0
    fi

    mkdir -p ${workDir}/roots
    for variant in ${lib.concatStringsSep " " variants}; do
      echo "Building $variant for commit $rev"
      ws=${workDir}/workspaces/$variant
      mkdir -p "$ws"
      # Same layout as /etc/nixos on a client
      rsync -a --delete --exclude .git ${workDir}/repo/ "$ws/git-config/"
      cp -f ${workDir}/repo/flake.nix ${workDir}/repo/flake.lock "$ws/"
      cp -f ${stubConfiguration} "$ws/configuration.nix"
      echo "$variant" > "$ws/hostname"
      # Optional: drop a real hardware-configuration.nix from a client into
      # ${workDir}/hardware/$variant.nix for an even closer match
      if [ -f ${workDir}/hardware/$variant.nix ]; then
        cp -f ${workDir}/hardware/$variant.nix "$ws/hardware-configuration.nix"
      else
        rm -f "$ws/hardware-configuration.nix"
      fi
      # The out-link is a GC root, so the store paths stay in the cache until the next build
      nix build "path:$ws#nixosConfigurations.$variant.config.system.build.toplevel" \
        --out-link ${workDir}/roots/$variant
    done

    echo "$rev" > ${workDir}/last-built
  '';
in
{
  # Serve the local /nix/store as a signed binary cache on port 5000.
  # The private key is not in git; copy it to the server by hand (see cachePublicKey in configs/default.nix).
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ "${keyDir}/cache-priv-key.pem" ];
  };
  networking.firewall.allowedTCPPorts = [ 5000 ];

  # Pull the repo and build every variant whenever main changes
  systemd.services.lgy-cache-build = {
    description = "Build all client configurations for the binary cache";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [
      git
      rsync
      nix
    ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "lgy-cache";
      ExecStart = buildScript;
    };
  };

  systemd.timers.lgy-cache-build = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitInactiveSec = "15min";
      Persistent = true;
    };
  };

  # Headless server: no desktop, so no Flatpak apps either
  services.flatpak.enable = lib.mkForce false;
  services.xserver.enable = lib.mkForce false;

  # The server is a notebook that is always plugged in
  systemd.services.battery-charge-threshold = {
    description = "Set battery charge threshold";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'for f in /sys/class/power_supply/*/charge_control_end_threshold; do echo 80 > $f; done'";
      RemainAfterExit = true;
    };
  };

  nix.settings = {
    # Build packages in parallel; the server is the only machine that compiles
    max-jobs = "auto";
    cores = 0;
  };
}
