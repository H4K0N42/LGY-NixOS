#!/run/current-system/sw/bin/bash

TARGET_DIR="/etc/nixos/git-config"
REPO_URL="https://github.com/H4K0N42/LGY-NixOS/"  # Change this to your repo
CONFIG_FILE="/etc/nixos/configuration.nix"

mkdir -p "$TARGET_DIR"
git clone "$REPO_URL" "$TARGET_DIR"

cp -f "$TARGET_DIR/flake.nix" "/etc/nixos/flake.nix"
rm -f /etc/nixos/flake.lock

read -rp "Hostname> " NEW_HOSTNAME

echo "$NEW_HOSTNAME" > /etc/nixos/hostname

nixos-generate-config

if [ -f "$CONFIG_FILE" ]; then
    STATE_VERSION=$(grep 'system.stateVersion' "$CONFIG_FILE" | awk -F'"' '{print $2}')
    cat > "$CONFIG_FILE" <<EOF
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "$STATE_VERSION"; # Did you read the comment?
}
EOF
fi

cd /etc/nixos
nixos-rebuild boot --install-bootloader --flake .#"$NEW_HOSTNAME"

read

reboot
