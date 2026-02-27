#!/run/current-system/sw/bin/bash

TARGET_DIR="/etc/nixos/git-config"

cd $TARGET_DIR
git fetch origin
git reset --hard origin/main
git clean -fd


cp -f "$TARGET_DIR/flake.nix" "/etc/nixos/flake.nix"
rm -f /etc/nixos/flake.lock

nixos-rebuild boot
