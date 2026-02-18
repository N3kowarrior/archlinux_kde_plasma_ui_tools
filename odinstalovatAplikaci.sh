#!/bin/bash

# 1. Získání názvu od uživatele
SEARCH_TERM=$(kdialog --title "Odinstalátor balíčků" --inputbox "Zadej název programu, který chceš ODINSTALOVAT:")

# Pokud uživatel klikne na Storno nebo nic nezadá
if [ $? -ne 0 ] || [ -z "$SEARCH_TERM" ]; then
    exit 0
fi

# 2. Kontrola, zda je balíček vůbec nainstalovaný
if ! pacman -Qi "$SEARCH_TERM" &> /dev/null; then
    kdialog --error "Balíček '$SEARCH_TERM' nebyl v systému nalezen. Zkontroluj, zda jsi zadal správný název."
    exit 1
fi

# 3. Potvrzení odinstalace
kdialog --title "Potvrdit odstranění" --warningyesno "Opravdu chceš odinstalovat '$SEARCH_TERM'? \n\nOdstraní se balíček i jeho nepoužívané závislosti (Rns)."

if [ $? -eq 0 ]; then
    # Spustíme odinstalaci v Konsole pro zadání hesla a přehled
    konsole -e sudo pacman -Rns "$SEARCH_TERM"

    # Finální kontrola
    if [ $? -eq 0 ]; then
        kdialog --title "Hotovo" --passivepopup "Balíček '$SEARCH_TERM' byl úspěšně odstraněn. ✅" 5
    else
        kdialog --error "Při odstraňování balíčku došlo k chybě."
    fi
fi
