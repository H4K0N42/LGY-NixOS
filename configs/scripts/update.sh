#!/run/current-system/sw/bin/bash

sleep 30

TARGET_DIR="/etc/nixos/git-config"

cd $TARGET_DIR
git fetch origin
git reset --hard origin/dev
git clean -fd


cp -f "$TARGET_DIR/flake.nix" "/etc/nixos/flake.nix"
rm -f /etc/nixos/flake.lock
