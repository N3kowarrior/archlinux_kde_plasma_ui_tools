#!/bin/bash

# 1. Získání názvu od uživatele přes KDE Input Box
SEARCH_TERM=$(kdialog --title "Instalátor balíčků" --inputbox "Zadej název programu na instalaci:")

# Pokud uživatel klikne na Storno nebo nic nezadá
if [ $? -ne 0 ] || [ -z "$SEARCH_TERM" ]; then
    exit 0
fi

# 2. Kontrola v oficiálních repozitářích
if pacman -Si "$SEARCH_TERM" &> /dev/null; then
    kdialog --title "Balíček nalezen" --yesno "Program '$SEARCH_TERM' je v oficiálním repu. Chceš ho nainstalovat?"
    if [ $? -eq 0 ]; then
        # Spustíme instalaci v novém okně terminálu, abychom viděli průběh a mohli zadat heslo
        konsole -e sudo pacman -S "$SEARCH_TERM"
    fi
    exit 0
fi

# 3. Pokud není v repu, zkusíme AUR
if paru -Si "$SEARCH_TERM" &> /dev/null; then
    kdialog --title "AUR Balíček" --yesno "V oficiálním repu nic není, ale '$SEARCH_TERM' je v AUR. Chceš ho sestavit a nainstalovat?"
    if [ $? -eq 0 ]; then
        konsole -e paru -S "$SEARCH_TERM"
    fi
else
    # 4. Nenalezeno - nabídka hledání
    kdialog --error "Bohužel, balíček '$SEARCH_TERM' nebyl nalezen."

    # Volitelně: Zobrazíme výsledky hledání v textovém okně
    RESULTS=$(paru -Ss "$SEARCH_TERM")
    kdialog --title "Podobné výsledky" --msgbox "$RESULTS"
fi
