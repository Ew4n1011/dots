#!/bin/bash

scrDir=$(dirname "$(realpath "$0")")
# shellcheck disable=SC1091
if ! source "${scrDir}/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

cloneDir="${cloneDir:-$CLONE_DIR}"
flg_DryRun=${flg_DryRun:-0}

# sddm
if pkg_installed sddm; then
    print_log -c "[DISPLAYMANAGER] " -b "detected :: " "sddm"
    if [ ! -d /etc/sddm.conf.d ]; then
        [ "${flg_DryRun}" -eq 1 ] || sudo mkdir -p /etc/sddm.conf.d
    fi
    if [ ! -f /etc/sddm.conf.d/dots_backup.conf ] || [ "${DOTS_INSTALL_SDDM}" = true ]; then
        print_log -g "[DISPLAYMANAGER] " -b " :: " "configuring sddm..."
        print_log -g "[DISPLAYMANAGER] " -b " :: " "Select sddm theme:" -r "\n[1]" -b " Catppuccin Mocha (SilentSDDM)" -r "\n[2]" -b " MineSDDM"
        read -p " :: Enter option number : " -r sddmopt

        case $sddmopt in
            1) sddmtheme="SilentSDDM" ;;
            *) sddmtheme="MineSDDM" ;;
        esac

        if [[ ${flg_DryRun} -ne 1 ]]; then
            sudo cp /etc/sddm.conf /etc/sddm.conf.d/dots_backup.conf

            if [[ "${sddmtheme}" == "SilentSDDM" ]]; then
                if pkg_installed sddm-silent-theme; then
                    print_log -sec "SDDM" -stat "exist" "SilentSDDM is already installed..."
                else
                    yay -S --no-confirm sddm-silent-theme
                fi

                sudo tee /etc/sddm.conf > /dev/null <<'EOF'
# Make sure these options are correct:
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard

[Theme]
Current=silent
EOF

                sudo sed -i 's/^ConfigFile=configs\/default.conf$/; &/; s/^; ConfigFile=configs\/catppuccin-mocha.conf$/ConfigFile=configs\/catppuccin-mocha.conf/' /usr/share/sddm/themes/silent/metadata.desktop
            else
                git clone https://github.com/Davi-S/sddm-theme-minesddm "${XDG_CONFIG_HOME:-$HOME}"/sddm-theme-minesddm
                sudo cp -r "${XDG_CONFIG_HOME:-$HOME}"/sddm-theme-minesddm/minesddm /usr/share/sddm/themes/
                sudo tee /etc/sddm.conf > /dev/null <<'EOF'
[Theme]
Current=minesddm
EOF
            fi
            print_log -g "[DISPLAYMANAGER] " -b " :: " "sddm configured with ${sddmtheme} theme..."
        else
            print_log -y "[DISPLAYMANAGER] " -b " :: " "sddm is already configured..."
        fi
    fi
fi

# shell
"${scrDir}/restore_shl.sh"

# flatpak
if ! pkg_installed flatpak; then
    echo ""
    print_log -g "[FLATPAK]" -b " list :: " "flatpak application"
    awk -F '#' '$1 != "" {print "["++count"]", $1}' "${scrDir}/extra/custom_flat.lst"
    prompt_timer 60 "Install these flatpaks? [Y/n]"
    fpkopt=${PROMPT_INPUT,,}

    if [ "${fpkopt}" = "y" ]; then
        print_log -g "[FLATPAK]" -b " install :: " "flatpaks"
        [ "${flg_DryRun}" -eq 1 ] || "${scrDir}/extra/install_fpk.sh"
    else
        print_log -y "[FLATPAK]" -b " skip :: " "flatpak installation"
    fi

else
    print_log -y "[FLATPAK]" -b " :: " "flatpak is already installed"
fi