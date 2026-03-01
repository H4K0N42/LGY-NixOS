#!/run/current-system/sw/bin/bash

sleep 15 # Race condition, will work most of the time

TARGET_DIR="/etc/nixos/git-config"

cd $TARGET_DIR
git fetch origin
git reset --hard origin/main
git clean -fd


cp -f "$TARGET_DIR/flake.nix" "/etc/nixos/flake.nix"
rm -f /etc/nixos/flake.lock