#!/bin/bash

# 1. Kontrola kdialogu
if ! command -v kdialog &> /dev/null; then
    sudo pacman -S kdialog --noconfirm
fi

# 2. Úvodní dotaz
kdialog --title "Správce systému" --yesno "Chceš zahájit údržbu systému krok za krokem?" || exit 0

REAL_USER=$USER
DESCRIPTION="Pre-update backup $(date +"%Y-%m-%d %H:%M")"

# Spuštění v Konsole (bez --hold se okno po skončení zavře)
konsole -e bash -c '
    REAL_USER="'$REAL_USER'"
    LOG_FILE=$(sudo -u "'$REAL_USER'" xdg-user-dir DESKTOP)/odstranene_balicky.txt

    # --- KROK 1: Timeshift ---
    if kdialog --title "Krok 1/4" --yesno "Vytvořit zálohu systému (Timeshift)?"; then
        echo "--- Vytváření zálohy ---"
        sudo timeshift --create --comments "'"$DESCRIPTION"'" --tags D --scripted
    fi

    # --- KROK 2: Mirrory ---
    if kdialog --title "Krok 2/4" --yesno "Optimalizovat zrcadla serverů (Reflector)?"; then
        echo "--- Hledám nejrychlejší servery ---"
        sudo reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    fi

    # --- KROK 3: Update ---
    kdialog --title "Krok 3/4" --msgbox "Nyní proběhne aktualizace systému a AUR."
    sudo pacman -Syyu --noconfirm
    sudo -u "'$REAL_USER'" paru -Sua --noconfirm

    # --- KROK 4: Čištění a GRUB ---
    ORPHANS=$(pacman -Qtdq)
    if [ -n "$ORPHANS" ]; then
        if kdialog --title "Krok 4/4" --yesno "Nalezeni sirotci. Odstranit a uložit seznam na plochu?"; then
            echo "$ORPHANS" >> "$LOG_FILE"
            chown "'$REAL_USER':'$REAL_USER'" "$LOG_FILE"
            sudo pacman -Rns $ORPHANS --noconfirm
        fi
    fi

    echo "--- Aktualizace GRUBu ---"
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    # --- FINÁLE ---
    # Dialog o restartu (tento dialog je poslední věc, co skript udělá)
    if kdialog --title "Hotovo" --yesno "Údržba dokončena. Chceš systém nyní restartovat?"; then
        sudo reboot
    fi

    exit # Zavře shell a tím i okno Konsole
'
