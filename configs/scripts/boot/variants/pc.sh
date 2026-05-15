#!/run/current-system/sw/bin/bash

find /home/schule -mindepth 1 -maxdepth 1 ! -name Documents -delete

rsync -r /etc/nixos/git-config/configs/dotfiles/config/ /home/schule/.config/
chown -R schule:users /home/schule/