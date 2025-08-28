#!/bin/bash

scrDir=$(dirname "$(dirname "$(realpath "$0")")")
# shellcheck disable=SC1091
source "${scrDir}/global_fn.sh"
# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

cloneDir=$(dirname "$(realpath "$cloneDir")")

#// spotify

if pkg_installed spotify && pkg_installed spicetify-cli && pkg_installed spicetify-marketplace-bin; then
    spotify &> /dev/null &
    sleep 2
    killall spotify

    sudo chmod a+wr /opt/spotify
    sudo chmod a+wr /opt/spotify/Apps -R

    spicetify config inject_css 1 replace_colors 1 current_theme marketplace

    spicetify backup apply
fi