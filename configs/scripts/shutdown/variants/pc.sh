#!/usr/bin/env bash

cd /home/schule/ && rm -rf !(Documents)
cp -r /etc/nixos/git-config/dotfiles/pc/config/ /home/schule/.config/

bash /etc/nixos/git-config/configs/scripts/update.sh