#!/bin/bash
# 1. Nastavení cest
SOURCE_DIR=$(dirname "$(readlink -f "$0")")
TARGET_DIR="$HOME/.GUIHelpers"
APP_MENU_DIR="$HOME/.local/share/applications"
DESKTOP_DIR=$(xdg-user-dir DESKTOP)

CURRENT_USER=$(whoami)
CURRENT_GROUP=$(id -gn)

# Definice skriptů pro zpracování
data=(
    "aktualizovatSystém.sh|Aktualizace systému"
    "nainstalovatAplikaci.sh|Instalovat aplikaci"
    "odinstalovatAplikaci.sh|Odinstalovat aplikaci"
)

# FUNKCE PRO ODINSTALACI
uninstall() {
    echo "--- Detekována existující instalace. Zahajuji odinstalaci... ---"
    for entry in "${data[@]}"; do
        IFS="|" read -r filename name <<< "$entry"

        # Smazání .desktop souborů (Menu + Plocha)
        rm -f "$APP_MENU_DIR/${filename%.*}.desktop"
        rm -f "$DESKTOP_DIR/${filename%.*}.desktop"
        echo "🗑️ Ikony pro $name byly odstraněny."
    done

    # Smazání hlavní složky se skripty
    rm -rf "$TARGET_DIR"
    echo "--- Hotovo. Vše bylo odstraněno. ---"
}

# FUNKCE PRO INSTALACI
install() {
    echo "--- Zahajuji instalaci do: $TARGET_DIR ---"
    mkdir -p "$TARGET_DIR"
    mkdir -p "$APP_MENU_DIR"

    for entry in "${data[@]}"; do
        IFS="|" read -r filename name <<< "$entry"
        # Tady si pro instalaci definujeme ikony a popis (aby to bylo čisté)
        case "$filename" in
            "aktualizovatSystém.sh") icon="system-software-update"; desc="Update a údržba";;
            "nainstalovatAplikaci.sh") icon="system-software-install"; desc="Instalace balíčků";;
            "odinstalovatAplikaci.sh") icon="edit-delete"; desc="Odstranění balíčků";;
        esac

        if [ -f "$SOURCE_DIR/$filename" ]; then
            # Kopírování a práva
            cp "$SOURCE_DIR/$filename" "$TARGET_DIR/"
            sudo chown "$CURRENT_USER":"$CURRENT_GROUP" "$TARGET_DIR/$filename"
            chmod +x "$TARGET_DIR/$filename"

            # Vytvoření .desktop souboru
            DESKTOP_FILE_NAME="${filename%.*}.desktop"
            cat << EOF > "$APP_MENU_DIR/$DESKTOP_FILE_NAME"
[Desktop Entry]
Name=$name
Comment=$desc
Exec=$TARGET_DIR/$filename
Icon=$icon
Terminal=false
Type=Application
Categories=System;
EOF
            chmod +x "$APP_MENU_DIR/$DESKTOP_FILE_NAME"

            # Kopie na plochu
            cp "$APP_MENU_DIR/$DESKTOP_FILE_NAME" "$DESKTOP_DIR/"
            chmod +x "$DESKTOP_DIR/$DESKTOP_FILE_NAME"

            echo "$name: Nainstalováno."
        else
            echo "$filename nenalezen v $SOURCE_DIR!"
        fi
    done
    echo "--- Instalace dokončena. ---"
}

# HLAVNÍ LOGIKA: Pokud složka existuje, odinstaluj. Pokud ne, nainstaluj.
if [ -d "$TARGET_DIR" ]; then
    uninstall
else
    install
fi
