#!/usr/bin/env bash

shopt -s extglob # Match !(...)

cd /home/schule/ && rm -rf !(Documents)
cp -r /etc/nixos/git-config/configs/dotfiles/pc/config/ /home/schule/.config/

bash /etc/nixos/git-config/configs/scripts/update.sh