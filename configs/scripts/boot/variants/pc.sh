#!/run/current-system/sw/bin/bash

find /home/schule -mindepth 1 -maxdepth 1 ! -name Documents -exec rm -rf {} +

rsync -r /etc/nixos/git-config/configs/dotfiles/config/ /home/schule/.config/
chown -R schule:users /home/schule/

if id lehrer &>/dev/null; then
    rsync -r --ignore-existing /etc/nixos/git-config/configs/dotfiles/config/ /home/lehrer/.config/
    chown -R lehrer:users /home/lehrer/.config
fi
