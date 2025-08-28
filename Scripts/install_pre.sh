#!/bin/bash

scrDir=$(dirname "$(realpath "$0")")
# shellcheck disable=SC1091
if ! source "${scrDir}/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

flg_DryRun=${flg_DryRun:-0}

# grub
if pkg_installed grub && [ -f /boot/grub/grub.cfg ]; then
    print_log -sec "bootloader" -b "detected :: " "grub..."

    if [ ! -f /etc/default/grub.dots.bkp ] && [ ! -f /boot/grub/grub.dots.bkp ]; then
        [ "${flg_DryRun}" -eq 1 ] || sudo cp /etc/default/grub /etc/default/grub.dots.bkp
        [ "${flg_DryRun}" -eq 1 ] || sudo cp /boot/grub/grub.cfg /boot/grub/grub.dots.bkp

        print_log -g "[bootloader] " "Select grub theme:" -y "\n[1]" -y " Yorha" -y "\n[2]" -y " Minegrub"
        read -r -p " :: Press enter to skip grub theme <or> Enter option number : " grubopt
        case ${grubopt} in
            1) grubtheme="Yorha" ;;
            2) grubtheme="Minegrub" ;;
            *) grubtheme="None" ;;
        esac

        if [ "${grubtheme}" == "Yorha" ]; then
            print_log -g "[bootloader] " -b "set :: " "grub theme // ${grubtheme}"
            echo ""

            [ "${flg_DryRun}" -eq 1 ] || git clone https://github.com/OliveThePuffin/yorha-grub-theme "${XDG_CONFIG_HOME:-$HOME}"/yorha-theme
            [ "${flg_DryRun}" -eq 1 ] || sudo mv "${XDG_CONFIG_HOME:-$HOME}"/yorha-theme/yorha-1920x1080/ /usr/share/grub/themes/

            [ "${flg_DryRun}" -eq 1 ] || sudo sed -i "/^GRUB_DEFAULT=/c\GRUB_DEFAULT=saved
            /^GRUB_THEME=/c\GRUB_THEME=\"/usr/share/grub/themes/yorha-1920x1080/theme.txt\"
            /^#GRUB_THEME=/c\GRUB_THEME=\"/usr/share/grub/themes/yorha-1920x1080/theme.txt\"
            /^#GRUB_SAVEDEFAULT=true/c\GRUB_SAVEDEFAULT=true" /etc/default/grub
            [ "${flg_DryRun}" -eq 1 ] || sudo grub-mkconfig -o /boot/grub/grub.cfg
        elif [ "${grubtheme}" == "Minegrub" ]; then
            print_log -g "[bootloader] " -b "set :: " "grub theme // ${grubtheme}"
            echo ""

            [ "${flg_DryRun}" -eq 1 ] || git clone https://github.com/Lxtharia/double-minegrub-menu "${XDG_CONFIG_HOME:-$HOME}"/minegrub

            [ "${flg_DryRun}" -eq 1 ] || sudo sed -i "/^GRUB_DEFAULT=/c\GRUB_DEFAULT=saved
                /^#GRUB_SAVEDEFAULT=true/c\GRUB_SAVEDEFAULT=true" /etc/default/grub

            print_log -g "[bootloader] " "Select minegrub language:" -y "\n[1]" -y " English" -y "\n[2]" -y " Español"
            read -r -p " :: Enter option number : " langopt
            case ${langopt} in
                1) lang="English" ;;
                2) lang="Spanish" ;;
            esac

            if [ "${lang}" == "English" ]; then
                [ "${flg_DryRun}" -eq 1 ] || sudo bash "${XDG_CONFIG_HOME:-$HOME}"/minegrub/install.sh
            else
                [ "${flg_DryRun}" -eq 1 ] || sed -i \
                    -e "s|https://github.com/Lxtharia/minegrub-theme.git|https://github.com/FeRChImoNdE/minegrub-theme-es|" \
                    -e "s|minegrub-theme/minegrub|minegrub-theme-es/minegrub|" \
                    -e "s|\.\/minegrub-theme|./minegrub-theme-es|" "${XDG_CONFIG_HOME:-$HOME}"/minegrub/install.sh
            fi
        else
            print_log -g "[bootloader] " -b "skip :: " "grub theme selection skipped..."
            echo ""
        fi
    else
        print_log -y "[bootloader] " -b "exist :: " "grub is already configured..."
    fi
fi

# pacman
if [ -f /etc/pacman.conf ] && [ ! -f /etc/pacman.conf.dots.bkp ]; then
    print_log -g "[PACMAN] " -b "modify :: " "adding extra spice to pacman..."

    # shellcheck disable=SC2154
    [ "${flg_DryRun}" -eq 1 ] || sudo cp /etc/pacman.conf /etc/pacman.conf.dots.bkp
    [ "${flg_DryRun}" -eq 1 ] || sudo sed -i "/^#Color/c\Color\nILoveCandy
    /^#VerbosePkgLists/c\VerbosePkgLists
    /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
    [ "${flg_DryRun}" -eq 1 ] || sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf

    print_log -g "[PACMAN] " -b "update :: " "packages..."
    [ "${flg_DryRun}" -eq 1 ] || sudo pacman -Syyu
    [ "${flg_DryRun}" -eq 1 ] || sudo pacman -Fy
else
    print_log -sec "PACMAN" -stat "skipped" "pacman is already configured..."
fi
