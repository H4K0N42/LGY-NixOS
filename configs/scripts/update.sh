#!/run/current-system/sw/bin/bash

sleep 30

TARGET_DIR="/etc/nixos/git-config"

cd $TARGET_DIR
git fetch origin
git reset --hard origin/main
git clean -fd


cp -f "$TARGET_DIR/flake.nix" "/etc/nixos/flake.nix"
cp -f "$TARGET_DIR/flake.lock" "/etc/nixos/flake.lock"
git rev-parse HEAD > /etc/nixos/git-rev
