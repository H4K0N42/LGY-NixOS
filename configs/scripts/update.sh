#!/run/current-system/sw/bin/bash

REPO_URL="https://github.com/H4K0N42/LGY-NixOS"
TARGET_DIR="/etc/nixos/git-config"

cd /tmp/
rm -rf $TARGET_DIR
git clone --depth 1 $REPO_URL $TARGET_DIR

cp -f "$TARGET_DIR/flake.nix" "/etc/nixos/flake.nix"
rm -f /etc/nixos/flake.lock

nixos-rebuild boot
