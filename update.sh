#!/usr/bin/env bash

REPO_URL="https://github.com/H4K0N42/LGY-NixOS"
TARGET_DIR="/etc/nixos/git-config"

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

rm -rf $TARGET_DIR
git clone --depth 1 $REPO_URL $TARGET_DIR

ln -sf "$TARGET_DIR/flake.nix" "/etc/nixos/flake.nix"
rm -f /etc/nixos/flake.lock

nixos-rebuild boot
