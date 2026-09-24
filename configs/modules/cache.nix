{ config, pkgs, lib, ... }:
let
  repoUrl = "https://github.com/H4K0N42/LGY-NixOS";
  workDir = "/var/lib/lgy-cache";
  keyDir = "/var/lib/secrets";

  # must match segmentModules in flake.nix
  variants = [
    "PC"
    "NOTE"
  ];

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
      rsync -a --delete --exclude .git ${workDir}/repo/ "$ws/git-config/"
      cp -f ${workDir}/repo/flake.nix ${workDir}/repo/flake.lock "$ws/"
      cp -f ${stubConfiguration} "$ws/configuration.nix"
      echo "$variant" > "$ws/hostname"
      echo "$rev" > "$ws/git-rev"
      # optional: a real hardware-configuration.nix from a client
      if [ -f ${workDir}/hardware/$variant.nix ]; then
        cp -f ${workDir}/hardware/$variant.nix "$ws/hardware-configuration.nix"
      else
        rm -f "$ws/hardware-configuration.nix"
      fi
      # the out-link keeps the build from being garbage collected
      nix build "path:$ws#nixosConfigurations.$variant.config.system.build.toplevel" \
        --out-link ${workDir}/roots/$variant
    done

    echo "$rev" > ${workDir}/last-built
  '';
in
{
  # private key is not in git, copy it over by hand
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ "${keyDir}/cache-priv-key.pem" ];
  };
  networking.firewall.allowedTCPPorts = [ 5000 ];

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

  systemd.services.lgy-cache-build.onSuccess = [ "lgy-cache-issue.service" ];

  systemd.services.lgy-cache-issue = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      built=$(cut -c1-7 ${workDir}/last-built 2>/dev/null || echo "-------")
      running=${lib.substring 0 7 (if config.system.configurationRevision != null then config.system.configurationRevision else "-------")}
      mkdir -p /run/issue.d
      printf 'Letzter Build: %s    System: %s\n\n' "$built" "$running" > /run/issue.d/lgy-cache.issue
      ${pkgs.util-linux}/bin/agetty --reload || true
    '';
  };

  programs.bash.loginShellInit = ''
    if [ "$(id -u)" = 0 ] && [[ "$(tty)" == /dev/tty* ]]; then
      journalctl -f -n 50 -u lgy-cache-build
    fi
  '';

  systemd.timers.lgy-cache-build = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitInactiveSec = "15min";
      Persistent = true;
    };
  };

  services.flatpak.enable = lib.mkForce false;
  services.xserver.enable = lib.mkForce false;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

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
    max-jobs = "auto";
    cores = 0;
  };
}
