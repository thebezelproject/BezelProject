#!/bin/bash

#IFS=';'

# Welcome
 dialog --backtitle "The Bezel Project" --title "The Bezel Project - Bezel Pack Utility" \
    --yesno "\nThe Bezel Project Bezel Utility menu.\n\nThis utility will provide a downloader for Retroarach system bezel packs to be used for various systems within RetroPie.\n\nThese bezel packs will only work if the ROMs you are using are named according to the No-Intro naming convention used by EmuMovies/HyperSpin.\n\nThis utility provides a download for a bezel pack for a system and includes a PNG bezel file for every ROM for that system.  The download will also include the necessary configuration files needed for Retroarch to show them.  The script will also update the required retroarch.cfg files for the emulators located in the /opt/retropie/configs directory.  These changes are necessary to show the PNG bezels with an opacity of 1.\n\nPeriodically, new bezel packs are completed and you will need to run the script updater to download the newest version to see these additional packs.\n\n**NOTE**\nThe MAME bezel back is inclusive for any roms located in the arcade/fba/mame-libretro rom folders.\n\n\nDo you want to proceed?" \
    28 110 2>&1 > /dev/tty \
    || exit

# Declare associative array linking system names to display names
declare -A system_names=( ['vectrex']='GCEVectrex' 
					 ['supergrafx']='SuperGrafx' 
					 ['sega32x']='Sega32X' 
					 ['sg-1000']='SG-1000' 
					 ['arcade']='Arcade' 
					 ['fba']='Final Burn Alpha' 
					 ['mame-libretro']='MAME Libretro' 
					 ['nes']='NES' 
					 ['mastersystem']='MasterSystem' 
					 ['atari5200']='Atari 5200' 
					 ['atari7800']='Atari 7800' 
					 ['snes']='SNES' 
					 ['megadrive']='MegaDrive' 
					 ['segacd']='SegaCD' 
					 ['psx']='PSX' 
					 ['tg16']='TG16' 
					 ['tg-cd']='TG-CD' 
					 ['atari2600']='Atari 2600' 
					 ['coleco']='ColecoVision' 
					 ['n64']='Nintendo 64'
					 ['sfc']='Super Famicom' 
					 ['gb']='Game Boy' 
					 ['gbc']='Game Boy Color' ) 
      
function main_menu() {
    local choice

    while true; do
        choice=$(dialog --backtitle "$BACKTITLE" --title " MAIN MENU " \
            --ok-label OK --cancel-label Exit \
            --menu "What action would you like to perform?" 25 75 20 \
            1 "Download system bezel pack (will automatcally enable bezels)" \
            2 "Enable system bezel pack" \
            3 "Disable system bezel pack" \
            4 "Information:  Retroarch cores setup for bezels per system" \
            5 "Uninstall the bezel project completely" \
            2>&1 > /dev/tty)

        case "$choice" in
            1) download_bezel  ;;
            2) enable_bezel  ;;
            3) disable_bezel  ;;
            4) retroarch_bezelinfo  ;;
            5) removebezelproject  ;;
            *)  break ;;
        esac
    done
}

#########################################################
# Functions for download and enable/disable bezel packs #
#########################################################

function install_bezel_pack() {
    local theme="$1"
    local repo="$2"
    if [[ -z "$repo" ]]; then
        repo="default"
    fi
    if [[ -z "$theme" ]]; then
        theme="default"
        repo="default"
    fi
    atheme=`echo ${theme} | sed 's/.*/\L&/'`

    if [[ "${atheme}" == "mame" ]];then
      mv "/opt/retropie/configs/all/retroarch/config/disable_FB Alpha" "/opt/retropie/configs/all/retroarch/config/FB Alpha" 2> /dev/null
      mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003" "/opt/retropie/configs/all/retroarch/config/MAME 2003" 2> /dev/null
      mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003 (0.78)" "/opt/retropie/configs/all/retroarch/config/MAME 2003 (0.78)" 2> /dev/null
      mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2010" "/opt/retropie/configs/all/retroarch/config/MAME 2010" 2> /dev/null
    fi

    git clone "https://github.com/$repo/bezelproject-$theme.git" "/tmp/${theme}"
    cp -r "/tmp/${theme}/retroarch/" /opt/retropie/configs/all/
    sudo rm -rf "/tmp/${theme}"

    if [[ "${atheme}" == "mame" ]];then
      show_bezel "arcade"
      show_bezel "fba"
      show_bezel "mame-libretro"
    else
      show_bezel "${atheme}"
    fi
}

function uninstall_bezel_pack() {
    local theme="$1"
    if [[ -d "/opt/retropie/configs/all/retroarch/overlay/GameBezels/$theme" ]]; then
        rm -rf "/opt/retropie/configs/all/retroarch/overlay/GameBezels/$theme"
    fi
    if [[ "${theme}" == "MAME" ]]; then
      if [[ -d "/opt/retropie/configs/all/retroarch/overlay/ArcadeBezels" ]]; then
        rm -rf "/opt/retropie/configs/all/retroarch/overlay/ArcadeBezels"
      fi
    fi
}

function removebezelproject() {
hide_bezel vectrex
hide_bezel supergrafx
hide_bezel sega32x
hide_bezel sg-1000
hide_bezel arcade
hide_bezel fba
hide_bezel mame-libretro
hide_bezel nes
hide_bezel mastersystem
hide_bezel atari5200
hide_bezel atari7800
hide_bezel snes
hide_bezel megadrive
hide_bezel segacd
hide_bezel psx
hide_bezel tg16
hide_bezel tg-cd
hide_bezel atari2600
hide_bezel coleco
hide_bezel n64
hide_bezel sfc
hide_bezel gb
hide_bezel gbc

rm -rf /opt/retropie/configs/all/retroarch/overlay/GameBezels
rm -rf /opt/retropie/configs/all/retroarch/overlay/ArcadeBezels
rm /home/pi/RetroPie/retropiemenu/bezelproject.sh

}

function download_bezel() {
    local themes=(
        'thebezelproject MAME'
        'thebezelproject Atari2600'
        'thebezelproject Atari5200'
        'thebezelproject Atari7800'
        'thebezelproject GB'
        'thebezelproject GBC'
        'thebezelproject GCEVectrex'
        'thebezelproject MasterSystem'
        'thebezelproject MegaDrive'
        'thebezelproject N64'
        'thebezelproject NES'
        'thebezelproject Sega32X'
        'thebezelproject SegaCD'
        'thebezelproject SG-1000'
        'thebezelproject SNES'
        'thebezelproject SuperGrafx'
        'thebezelproject SFC'
        'thebezelproject PSX'
        'thebezelproject TG16'
        'thebezelproject TG-CD'
        'thebezelproject ColecoVision'
    )
    while true; do
        local theme
        local installed_bezelpacks=()
        local repo
        local options=()
        local status=()
        local default

        options+=(U "Update install script - script will exit when updated")

        local i=1
        for theme in "${themes[@]}"; do
            theme=($theme)
            repo="${theme[0]}"
            theme="${theme[1]}"
            if [[ $theme == "MegaDrive" ]]; then
              theme="Megadrive"
            fi
            if [[ -d "/opt/retropie/configs/all/retroarch/overlay/GameBezels/$theme" ]]; then
                status+=("i")
                options+=("$i" "Update or Uninstall $theme (installed)")
                installed_bezelpacks+=("$theme $repo")
            else
                status+=("n")
                options+=("$i" "Install $theme (not installed)")
            fi
            ((i++))
        done
        local cmd=(dialog --default-item "$default" --backtitle "$__backtitle" --menu "The Bezel Project -  Bezel Pack Downloader - Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="$choice"
        [[ -z "$choice" ]] && break
        case "$choice" in
            U)  #update install script to get new theme listings
                if [[ -d "/home/pigaming" ]]; then
                    cd "/home/pigaming/RetroPie/retropiemenu"
                else
                    cd "/home/pi/RetroPie/retropiemenu" 
                fi
                mv "bezelproject.sh" "bezelproject.sh.bkp" 
                wget "https://raw.githubusercontent.com/thebezelproject/BezelProject/master/bezelproject.sh" 
                chmod 777 "bezelproject.sh" 
                exit
                ;;
            *)  #install or update themes
                theme=(${themes[choice-1]})
                repo="${theme[0]}"
                theme="${theme[1]}"
#                if [[ "${status[choice]}" == "i" ]]; then
                if [[ -d "/opt/retropie/configs/all/retroarch/overlay/GameBezels/$theme" ]]; then
                    options=(1 "Update $theme" 2 "Uninstall $theme")
                    cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option for the bezel pack" 12 40 06)
                    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                    case "$choice" in
                        1)
                            install_bezel_pack "$theme" "$repo"
                            ;;
                        2)
                            uninstall_bezel_pack "$theme"
                            ;;
                    esac
                else
                    install_bezel_pack "$theme" "$repo"
                fi
                ;;
        esac
    done
}

function disable_bezels() {
	clear
	while true; do

		cmd=(dialog --backtitle "$BACKTITLE" --title " MAIN MENU " \
			--ok-label OK --cancel-label Exit \
			--separate-output \
			--checklist "Which systems would you like to disable bezels for?" 25 75 20)
			
		local i=1
		local options=()
		for system in "${!system_names[@]}"; do
			options+=($i "${system_names[${system}]}" off)
			((i++))
		done
	
		choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
		[[ -z "$choices" ]] && break
		for choice in $choices
		do
			keys=(${!system_names[@]})
			emulator=${keys[${choice}-1]}
			echo 'Disabling bezels for '"${system_names[${emulator}]}"'...'
			hide_bezel $emulator
		done
	done
}   

function enable_bezels() {
	clear

	while true; do
		local options=()
		
		cmd=(dialog --backtitle "$BACKTITLE" --title " MAIN MENU " \
			--ok-label OK --cancel-label Exit \
			--separate-output \
			--checklist "Which systems would you like to enable bezels for?" 25 75 20)

		local i=1
		for system in "${!system_names[@]}"; do
			options+=($i "${system_names[${system}]}" off)
			((i++))
		done
	
		choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
		[[ -z "$choices" ]] && break
		for choice in $choices
		do
			keys=(${!system_names[@]})
			emulator=${keys[${choice}-1]}
			echo 'Enabling bezels for '"${system_names[${emulator}]}"'...'
			show_bezel $emulator
		done
	done
}

function hide_bezel() {
dialog --infobox "...processing..." 3 20 ; sleep 2
emulator=$1
file="/opt/retropie/configs/${emulator}/retroarch.cfg"

case ${emulator} in
arcade)
  cp /opt/retropie/configs/${emulator}/retroarch.cfg /opt/retropie/configs/${emulator}/retroarch.cfg.bkp
  cat /opt/retropie/configs/${emulator}/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
  cp /tmp/retroarch.cfg /opt/retropie/configs/${emulator}/retroarch.cfg
  mv "/opt/retropie/configs/all/retroarch/config/FB Alpha" "/opt/retropie/configs/all/retroarch/config/disable_FB Alpha"
  mv "/opt/retropie/configs/all/retroarch/config/MAME 2003" "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003"
  mv "/opt/retropie/configs/all/retroarch/config/MAME 2003 (0.78)" "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003 (0.78)"
  mv "/opt/retropie/configs/all/retroarch/config/MAME 2010" "/opt/retropie/configs/all/retroarch/config/disable_MAME 2010"
  ;;
fba)
  cp /opt/retropie/configs/${emulator}/retroarch.cfg /opt/retropie/configs/${emulator}/retroarch.cfg.bkp
  cat /opt/retropie/configs/${emulator}/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
  cp /tmp/retroarch.cfg /opt/retropie/configs/${emulator}/retroarch.cfg
  mv "/opt/retropie/configs/all/retroarch/config/FB Alpha" "/opt/retropie/configs/all/retroarch/config/disable_FB Alpha"
  ;;
mame-libretro)
  cp /opt/retropie/configs/${emulator}/retroarch.cfg /opt/retropie/configs/${emulator}/retroarch.cfg.bkp
  cat /opt/retropie/configs/${emulator}/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
  cp /tmp/retroarch.cfg /opt/retropie/configs/${emulator}/retroarch.cfg
  mv "/opt/retropie/configs/all/retroarch/config/MAME 2003" "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003"
  mv "/opt/retropie/configs/all/retroarch/config/MAME 2003 (0.78)" "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003 (0.78)"
  mv "/opt/retropie/configs/all/retroarch/config/MAME 2010" "/opt/retropie/configs/all/retroarch/config/disable_MAME 2010"
  ;;
*)
  cp /opt/retropie/configs/${emulator}/retroarch.cfg /opt/retropie/configs/${emulator}/retroarch.cfg.bkp
  cat /opt/retropie/configs/${emulator}/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
  cp /tmp/retroarch.cfg /opt/retropie/configs/${emulator}/retroarch.cfg
  ;;
esac

}

function show_bezel() {
dialog --infobox "...processing..." 3 20 ; sleep 2
emulator=$1
file="/opt/retropie/configs/${emulator}/retroarch.cfg"

case ${emulator} in
arcade)
  ifexist=`cat /opt/retropie/configs/arcade/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/arcade/retroarch.cfg /opt/retropie/configs/arcade/retroarch.cfg.bkp
    cat /opt/retropie/configs/arcade/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/arcade/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/MAME-Horizontal.cfg"' /opt/retropie/configs/arcade/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/arcade/retroarch.cfg
    mv "/opt/retropie/configs/all/retroarch/config/disable_FB Alpha" "/opt/retropie/configs/all/retroarch/config/FB Alpha"
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003" "/opt/retropie/configs/all/retroarch/config/MAME 2003"
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003 (0.78)" "/opt/retropie/configs/all/retroarch/config/MAME 2003 (0.78)"
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2010" "/opt/retropie/configs/all/retroarch/config/MAME 2010"
  else
    cp /opt/retropie/configs/arcade/retroarch.cfg /opt/retropie/configs/arcade/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/MAME-Horizontal.cfg"' /opt/retropie/configs/arcade/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/arcade/retroarch.cfg
    mv "/opt/retropie/configs/all/retroarch/config/disable_FB Alpha" "/opt/retropie/configs/all/retroarch/config/FB Alpha"
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003" "/opt/retropie/configs/all/retroarch/config/MAME 2003"
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003 (0.78)" "/opt/retropie/configs/all/retroarch/config/MAME 2003 (0.78)"
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2010" "/opt/retropie/configs/all/retroarch/config/MAME 2010"
  fi
  ;;
fba)
  ifexist=`cat /opt/retropie/configs/fba/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/fba/retroarch.cfg /opt/retropie/configs/fba/retroarch.cfg.bkp
    cat /opt/retropie/configs/fba/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/fba/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/MAME-Horizontal.cfg"' /opt/retropie/configs/fba/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/fba/retroarch.cfg
    mv "/opt/retropie/configs/all/retroarch/config/disable_FB Alpha" "/opt/retropie/configs/all/retroarch/config/FB Alpha"
  else
    cp /opt/retropie/configs/fba/retroarch.cfg /opt/retropie/configs/fba/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/MAME-Horizontal.cfg"' /opt/retropie/configs/fba/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/fba/retroarch.cfg
    mv "/opt/retropie/configs/all/retroarch/config/disable_FB Alpha" "/opt/retropie/configs/all/retroarch/config/FB Alpha"
  fi
  ;;
mame-libretro)
  ifexist=`cat /opt/retropie/configs/mame-libretro/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/mame-libretro/retroarch.cfg /opt/retropie/configs/mame-libretro/retroarch.cfg.bkp
    cat /opt/retropie/configs/mame-libretro/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/mame-libretro/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/MAME-Horizontal.cfg"' /opt/retropie/configs/mame-libretro/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/mame-libretro/retroarch.cfg
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003" "/opt/retropie/configs/all/retroarch/config/MAME 2003"
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003 (0.78)" "/opt/retropie/configs/all/retroarch/config/MAME 2003 (0.78)"
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2010" "/opt/retropie/configs/all/retroarch/config/MAME 2010"
  else
    cp /opt/retropie/configs/mame-libretro/retroarch.cfg /opt/retropie/configs/mame-libretro/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/MAME-Horizontal.cfg"' /opt/retropie/configs/mame-libretro/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/mame-libretro/retroarch.cfg
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003" "/opt/retropie/configs/all/retroarch/config/MAME 2003"
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2003 (0.78)" "/opt/retropie/configs/all/retroarch/config/MAME 2003 (0.78)"
    mv "/opt/retropie/configs/all/retroarch/config/disable_MAME 2010" "/opt/retropie/configs/all/retroarch/config/MAME 2010"
  fi
  ;;
atari2600)
  ifexist=`cat /opt/retropie/configs/atari2600/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/atari2600/retroarch.cfg /opt/retropie/configs/atari2600/retroarch.cfg.bkp
    cat /opt/retropie/configs/atari2600/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/atari2600/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-2600.cfg"' /opt/retropie/configs/atari2600/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atari2600/retroarch.cfg
  else
    cp /opt/retropie/configs/atari2600/retroarch.cfg /opt/retropie/configs/atari2600/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-2600.cfg"' /opt/retropie/configs/atari2600/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atari2600/retroarch.cfg
  fi
  ;;
atari5200)
  ifexist=`cat /opt/retropie/configs/atari5200/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/atari5200/retroarch.cfg /opt/retropie/configs/atari5200/retroarch.cfg.bkp
    cat /opt/retropie/configs/atari5200/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/atari5200/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-5200.cfg"' /opt/retropie/configs/atari5200/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atari5200/retroarch.cfg
  else
    cp /opt/retropie/configs/atari5200/retroarch.cfg /opt/retropie/configs/atari5200/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-5200.cfg"' /opt/retropie/configs/atari5200/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atari5200/retroarch.cfg
  fi
  ;;
atari7800)
  ifexist=`cat /opt/retropie/configs/atari7800/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/atari7800/retroarch.cfg /opt/retropie/configs/atari7800/retroarch.cfg.bkp
    cat /opt/retropie/configs/atari7800/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/atari7800/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-7800.cfg"' /opt/retropie/configs/atari7800/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atari7800/retroarch.cfg
  else
    cp /opt/retropie/configs/atari7800/retroarch.cfg /opt/retropie/configs/atari7800/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-7800.cfg"' /opt/retropie/configs/atari7800/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atari7800/retroarch.cfg
  fi
  ;;
coleco)
  ifexist=`cat /opt/retropie/configs/coleco/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/coleco/retroarch.cfg /opt/retropie/configs/coleco/retroarch.cfg.bkp
    cat /opt/retropie/configs/coleco/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/coleco/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Colecovision.cfg"' /opt/retropie/configs/coleco/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/coleco/retroarch.cfg
  else
    cp /opt/retropie/configs/coleco/retroarch.cfg /opt/retropie/configs/coleco/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Colecovision.cfg"' /opt/retropie/configs/coleco/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/coleco/retroarch.cfg
  fi
  ;;
famicom)
  ifexist=`cat /opt/retropie/configs/famicom/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/famicom/retroarch.cfg /opt/retropie/configs/famicom/retroarch.cfg.bkp
    cat /opt/retropie/configs/famicom/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/famicom/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Famicom.cfg"' /opt/retropie/configs/famicom/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/famicom/retroarch.cfg
  else
    cp /opt/retropie/configs/famicom/retroarch.cfg /opt/retropie/configs/famicom/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Famicom.cfg"' /opt/retropie/configs/famicom/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/famicom/retroarch.cfg
  fi
  ;;
fds)
  ifexist=`cat /opt/retropie/configs/fds/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/fds/retroarch.cfg /opt/retropie/configs/fds/retroarch.cfg.bkp
    cat /opt/retropie/configs/fds/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/fds/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Famicom-Disk-System.cfg"' /opt/retropie/configs/fds/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/fds/retroarch.cfg
  else
    cp /opt/retropie/configs/fds/retroarch.cfg /opt/retropie/configs/fds/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Famicom-Disk-System.cfg"' /opt/retropie/configs/fds/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/fds/retroarch.cfg
  fi
  ;;
mastersystem)
  ifexist=`cat /opt/retropie/configs/mastersystem/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/mastersystem/retroarch.cfg /opt/retropie/configs/mastersystem/retroarch.cfg.bkp
    cat /opt/retropie/configs/mastersystem/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/mastersystem/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-Master-System.cfg"' /opt/retropie/configs/mastersystem/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/mastersystem/retroarch.cfg
  else
    cp /opt/retropie/configs/mastersystem/retroarch.cfg /opt/retropie/configs/mastersystem/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-Master-System.cfg"' /opt/retropie/configs/mastersystem/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/mastersystem/retroarch.cfg
  fi
  ;;
megadrive)
  ifexist=`cat /opt/retropie/configs/megadrive/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/megadrive/retroarch.cfg /opt/retropie/configs/megadrive/retroarch.cfg.bkp
    cat /opt/retropie/configs/megadrive/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/megadrive/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-Mega-Drive.cfg"' /opt/retropie/configs/megadrive/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/megadrive/retroarch.cfg
  else
    cp /opt/retropie/configs/megadrive/retroarch.cfg /opt/retropie/configs/megadrive/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-Mega-Drive.cfg"' /opt/retropie/configs/megadrive/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/megadrive/retroarch.cfg
  fi
  ;;
megadrive-japan)
  ifexist=`cat /opt/retropie/configs/megadrive-japan/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/megadrive-japan/retroarch.cfg /opt/retropie/configs/megadrive-japan/retroarch.cfg.bkp
    cat /opt/retropie/configs/megadrive-japan/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/megadrive-japan/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-Mega-Drive-Japan.cfg"' /opt/retropie/configs/megadrive-japan/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/megadrive-japan/retroarch.cfg
  else
    cp /opt/retropie/configs/megadrive-japan/retroarch.cfg /opt/retropie/configs/megadrive-japan/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-Mega-Drive-Japan.cfg"' /opt/retropie/configs/megadrive-japan/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/megadrive-japan/retroarch.cfg
  fi
  ;;
n64)
  ifexist=`cat /opt/retropie/configs/n64/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/n6n64/retroarch.cfg /opt/retropie/configs/n64/retroarch.cfg.bkp
    cat /opt/retropie/configs/n6/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/n64/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-64.cfg"' /opt/retropie/configs/n64/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/n64/retroarch.cfg
  else
    cp /opt/retropie/configs/n64/retroarch.cfg /opt/retropie/configs/n64/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-64.cfg"' /opt/retropie/configs/n64/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/n64/retroarch.cfg
  fi
  ;;
neogeo)
  ifexist=`cat /opt/retropie/configs/neogeo/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/neogeo/retroarch.cfg /opt/retropie/configs/neogeo/retroarch.cfg.bkp
    cat /opt/retropie/configs/neogeo/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/neogeo/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/MAME-Horizontal.cfg"' /opt/retropie/configs/neogeo/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/neogeo/retroarch.cfg
  else
    cp /opt/retropie/configs/neogeo/retroarch.cfg /opt/retropie/configs/neogeo/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/MAME-Horizontal.cfg"' /opt/retropie/configs/neogeo/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/neogeo/retroarch.cfg
  fi
  ;;
nes)
  ifexist=`cat /opt/retropie/configs/nes/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/nes/retroarch.cfg /opt/retropie/configs/nes/retroarch.cfg.bkp
    cat /opt/retropie/configs/nes/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport |grep -v force_aspect > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/nes/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Entertainment-System.cfg"' /opt/retropie/configs/nes/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/nes/retroarch.cfg
    sed -i '4i aspect_ratio_index = "16"' /opt/retropie/configs/nes/retroarch.cfg
    sed -i '5i video_force_aspect = "true"' /opt/retropie/configs/nes/retroarch.cfg
    sed -i '6i video_aspect_ratio = "-1.000000"' /opt/retropie/configs/nes/retroarch.cfg
  else
    cp /opt/retropie/configs/nes/retroarch.cfg /opt/retropie/configs/nes/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Entertainment-System.cfg"' /opt/retropie/configs/nes/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/nes/retroarch.cfg
    sed -i '4i aspect_ratio_index = "16"' /opt/retropie/configs/nes/retroarch.cfg
    sed -i '5i video_force_aspect = "true"' /opt/retropie/configs/nes/retroarch.cfg
    sed -i '6i video_aspect_ratio = "-1.000000"' /opt/retropie/configs/nes/retroarch.cfg
  fi
  ;;
pce-cd)
  ifexist=`cat /opt/retropie/configs/pce-cd/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/pce-cd/retroarch.cfg /opt/retropie/configs/pce-cd/retroarch.cfg.bkp
    cat /opt/retropie/configs/pce-cd/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/pce-cd/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/NEC-PC-Engine-CD.cfg"' /opt/retropie/configs/pce-cd/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/pce-cd/retroarch.cfg
  else
    cp /opt/retropie/configs/pce-cd/retroarch.cfg /opt/retropie/configs/pce-cd/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/NEC-PC-Engine-CD.cfg"' /opt/retropie/configs/pce-cd/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/pce-cd/retroarch.cfg
  fi
  ;;
pcengine)
  ifexist=`cat /opt/retropie/configs/pcengine/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/pcengine/retroarch.cfg /opt/retropie/configs/pcengine/retroarch.cfg.bkp
    cat /opt/retropie/configs/pcengine/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/pcengine/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/NEC-PC-Engine.cfg"' /opt/retropie/configs/pcengine/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/pcengine/retroarch.cfg
  else
    cp /opt/retropie/configs/pcengine/retroarch.cfg /opt/retropie/configs/pcengine/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/NEC-PC-Engine.cfg"' /opt/retropie/configs/pcengine/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/pcengine/retroarch.cfg
  fi
  ;;
psx)
  ifexist=`cat /opt/retropie/configs/psx/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/psx/retroarch.cfg /opt/retropie/configs/psx/retroarch.cfg.bkp
    cat /opt/retropie/configs/psx/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/psx/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sony-PlayStation.cfg"' /opt/retropie/configs/psx/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/psx/retroarch.cfg
  else
    cp /opt/retropie/configs/psx/retroarch.cfg /opt/retropie/configs/psx/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sony-PlayStation.cfg"' /opt/retropie/configs/psx/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/psx/retroarch.cfg
  fi
  ;;
sega32x)
  ifexist=`cat /opt/retropie/configs/sega32x/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/sega32x/retroarch.cfg /opt/retropie/configs/sega32x/retroarch.cfg.bkp
    cat /opt/retropie/configs/sega32x/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/sega32x/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-32X.cfg"' /opt/retropie/configs/sega32x/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/sega32x/retroarch.cfg
  else
    cp /opt/retropie/configs/sega32x/retroarch.cfg /opt/retropie/configs/sega32x/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-32X.cfg"' /opt/retropie/configs/sega32x/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/sega32x/retroarch.cfg
  fi
  ;;
segacd)
  ifexist=`cat /opt/retropie/configs/segacd/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/segacd/retroarch.cfg /opt/retropie/configs/segacd/retroarch.cfg.bkp
    cat /opt/retropie/configs/segacd/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/segacd/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-CD.cfg"' /opt/retropie/configs/segacd/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/segacd/retroarch.cfg
  else
    cp /opt/retropie/configs/segacd/retroarch.cfg /opt/retropie/configs/segacd/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-CD.cfg"' /opt/retropie/configs/segacd/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/segacd/retroarch.cfg
  fi
  ;;
sfc)
  ifexist=`cat /opt/retropie/configs/sfc/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/sfc/retroarch.cfg /opt/retropie/configs/sfc/retroarch.cfg.bkp
    cat /opt/retropie/configs/sfc/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/sfc/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Super-Famicom.cfg"' /opt/retropie/configs/sfc/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/sfc/retroarch.cfg
  else
    cp /opt/retropie/configs/sfc/retroarch.cfg /opt/retropie/configs/sfc/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Super-Famicom.cfg"' /opt/retropie/configs/sfc/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/sfc/retroarch.cfg
  fi
  ;;
sg-1000)
  ifexist=`cat /opt/retropie/configs/sg-1000/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/sg-1000/retroarch.cfg /opt/retropie/configs/sg-1000/retroarch.cfg.bkp
    cat /opt/retropie/configs/sg-1000/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/sg-1000/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-SG-1000.cfg"' /opt/retropie/configs/sg-1000/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/sg-1000/retroarch.cfg
  else
    cp /opt/retropie/configs/sg-1000/retroarch.cfg /opt/retropie/configs/sg-1000/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-SG-1000.cfg"' /opt/retropie/configs/sg-1000/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/sg-1000/retroarch.cfg
  fi
  ;;
snes)
  ifexist=`cat /opt/retropie/configs/snes/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/snes/retroarch.cfg /opt/retropie/configs/snes/retroarch.cfg.bkp
    cat /opt/retropie/configs/snes/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/snes/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Super-Nintendo-Entertainment-System.cfg"' /opt/retropie/configs/snes/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/snes/retroarch.cfg
  else
    cp /opt/retropie/configs/snes/retroarch.cfg /opt/retropie/configs/snes/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Super-Nintendo-Entertainment-System.cfg"' /opt/retropie/configs/snes/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/snes/retroarch.cfg
  fi
  ;;
supergrafx)
  ifexist=`cat /opt/retropie/configs/supergrafx/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/supergrafx/retroarch.cfg /opt/retropie/configs/supergrafx/retroarch.cfg.bkp
    cat /opt/retropie/configs/supergrafx/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/supergrafx/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/NEC-SuperGrafx.cfg"' /opt/retropie/configs/supergrafx/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/supergrafx/retroarch.cfg
  else
    cp /opt/retropie/configs/supergrafx/retroarch.cfg /opt/retropie/configs/supergrafx/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/NEC-SuperGrafx.cfg"' /opt/retropie/configs/supergrafx/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/supergrafx/retroarch.cfg
  fi
  ;;
tg16)
  ifexist=`cat /opt/retropie/configs/tg16/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/tg16/retroarch.cfg /opt/retropie/configs/tg16/retroarch.cfg.bkp
    cat /opt/retropie/configs/tg16/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/tg16/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/NEC-TurboGrafx-16.cfg"' /opt/retropie/configs/tg16/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/tg16/retroarch.cfg
  else
    cp /opt/retropie/configs/tg16/retroarch.cfg /opt/retropie/configs/tg16/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/NEC-TurboGrafx-16.cfg"' /opt/retropie/configs/tg16/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/tg16/retroarch.cfg
  fi
  ;;
tg-cd)
  ifexist=`cat /opt/retropie/configs/tg-cd/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/tg-cd/retroarch.cfg /opt/retropie/configs/tg-cd/retroarch.cfg.bkp
    cat /opt/retropie/configs/tg-cd/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/tg-cd/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/NEC-TurboGrafx-CD.cfg"' /opt/retropie/configs/tg-cd/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/tg-cd/retroarch.cfg
  else
    cp /opt/retropie/configs/tg-cd/retroarch.cfg /opt/retropie/configs/tg-cd/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/NEC-TurboGrafx-CD.cfg"' /opt/retropie/configs/tg-cd/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/tg-cd/retroarch.cfg
  fi
  ;;
gcevectrex)
  ifexist=`cat /opt/retropie/configs/vectrex/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/vectrex/retroarch.cfg /opt/retropie/configs/vectrex/retroarch.cfg.bkp
    cat /opt/retropie/configs/vectrex/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/vectrex/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/GCE-Vectrex.cfg"' /opt/retropie/configs/vectrex/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/vectrex/retroarch.cfg
  else
    cp /opt/retropie/configs/vectrex/retroarch.cfg /opt/retropie/configs/vectrex/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/GCE-Vectrex.cfg"' /opt/retropie/configs/vectrex/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/vectrex/retroarch.cfg
  fi
  ;;
atarilynx)
  ifexist=`cat /opt/retropie/configs/atarilynx/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/atarilynx/retroarch.cfg /opt/retropie/configs/atarilynx/retroarch.cfg.bkp
    cat /opt/retropie/configs/atarilynx/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/atarilynx/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-Lynx-Horizontal.cfg"' /opt/retropie/configs/atarilynx/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atarilynx/retroarch.cfg
  else
    cp /opt/retropie/configs/atarilynx/retroarch.cfg /opt/retropie/configs/atarilynx/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-Lynx-Horizontal.cfg"' /opt/retropie/configs/atarilynx/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atarilynx/retroarch.cfg
  fi
  ;;
gamegear)
  ifexist=`cat /opt/retropie/configs/gamegear/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/gamegear/retroarch.cfg /opt/retropie/configs/gamegear/retroarch.cfg.bkp
    cat /opt/retropie/configs/gamegear/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/gamegear/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-Game-Gear.cfg"' /opt/retropie/configs/gamegear/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/gamegear/retroarch.cfg
  else
    cp /opt/retropie/configs/gamegear/retroarch.cfg /opt/retropie/configs/gamegear/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sega-Game-Gear.cfg"' /opt/retropie/configs/gamegear/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/gamegear/retroarch.cfg
  fi
  ;;
gb)
  ifexist=`cat /opt/retropie/configs/gb/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/gb/retroarch.cfg /opt/retropie/configs/gb/retroarch.cfg.bkp
    cat /opt/retropie/configs/gb/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/gb/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Game-Boy.cfg"' /opt/retropie/configs/gb/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/gb/retroarch.cfg
  else
    cp /opt/retropie/configs/gb/retroarch.cfg /opt/retropie/configs/gb/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Game-Boy.cfg"' /opt/retropie/configs/gb/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/gb/retroarch.cfg
  fi
  ;;
gba)
  ifexist=`cat /opt/retropie/configs/gba/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/gba/retroarch.cfg /opt/retropie/configs/gba/retroarch.cfg.bkp
    cat /opt/retropie/configs/gba/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/gba/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Game-Boy-Advance.cfg"' /opt/retropie/configs/gba/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/gba/retroarch.cfg
  else
    cp /opt/retropie/configs/gba/retroarch.cfg /opt/retropie/configs/gba/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Game-Boy-Advance.cfg"' /opt/retropie/configs/gba/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/gba/retroarch.cfg
  fi
  ;;
gbc)
  ifexist=`cat /opt/retropie/configs/gbc/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/gbc/retroarch.cfg /opt/retropie/configs/gbc/retroarch.cfg.bkp
    cat /opt/retropie/configs/gbc/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/gbc/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Game-Boy-Color.cfg"' /opt/retropie/configs/gbc/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/gbc/retroarch.cfg
  else
    cp /opt/retropie/configs/gbc/retroarch.cfg /opt/retropie/configs/gbc/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Game-Boy-Color.cfg"' /opt/retropie/configs/gbc/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/gbc/retroarch.cfg
  fi
  ;;
ngp)
  ifexist=`cat /opt/retropie/configs/ngp/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/ngp/retroarch.cfg /opt/retropie/configs/ngp/retroarch.cfg.bkp
    cat /opt/retropie/configs/ngp/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/ngp/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/SNK-Neo-Geo-Pocket.cfg"' /opt/retropie/configs/ngp/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/ngp/retroarch.cfg
  else
    cp /opt/retropie/configs/ngp/retroarch.cfg /opt/retropie/configs/ngp/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/SNK-Neo-Geo-Pocket.cfg"' /opt/retropie/configs/ngp/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/ngp/retroarch.cfg
  fi
  ;;
ngpc)
  ifexist=`cat /opt/retropie/configs/ngpc/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/ngpc/retroarch.cfg /opt/retropie/configs/ngpc/retroarch.cfg.bkp
    cat /opt/retropie/configs/ngpc/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/ngpc/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/SNK-Neo-Geo-Pocket-Color.cfg"' /opt/retropie/configs/ngpc/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/ngpc/retroarch.cfg
  else
    cp /opt/retropie/configs/ngpc/retroarch.cfg /opt/retropie/configs/ngpc/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/SNK-Neo-Geo-Pocket-Color.cfg"' /opt/retropie/configs/ngpc/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/ngpc/retroarch.cfg
  fi
  ;;
psp)
  ifexist=`cat /opt/retropie/configs/psp/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/psp/retroarch.cfg /opt/retropie/configs/psp/retroarch.cfg.bkp
    cat /opt/retropie/configs/psp/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/psp/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sony-PSP.cfg"' /opt/retropie/configs/psp/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/psp/retroarch.cfg
  else
    cp /opt/retropie/configs/psp/retroarch.cfg /opt/retropie/configs/psp/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sony-PSP.cfg"' /opt/retropie/configs/psp/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/psp/retroarch.cfg
  fi
  ;;
pspminis)
  ifexist=`cat /opt/retropie/configs/pspminis/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/pspminis/retroarch.cfg /opt/retropie/configs/pspminis/retroarch.cfg.bkp
    cat /opt/retropie/configs/pspminis/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/pspminis/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sony-PSP.cfg"' /opt/retropie/configs/pspminis/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/pspminis/retroarch.cfg
  else
    cp /opt/retropie/configs/pspminis/retroarch.cfg /opt/retropie/configs/pspminis/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sony-PSP.cfg"' /opt/retropie/configs/pspminis/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/pspminis/retroarch.cfg
  fi
  ;;
virtualboy)
  ifexist=`cat /opt/retropie/configs/virtualboy/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/virtualboy/retroarch.cfg /opt/retropie/configs/virtualboy/retroarch.cfg.bkp
    cat /opt/retropie/configs/virtualboy/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/virtualboy/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Virtual-Boy.cfg"' /opt/retropie/configs/virtualboy/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/virtualboy/retroarch.cfg
  else
    cp /opt/retropie/configs/virtualboy/retroarch.cfg /opt/retropie/configs/virtualboy/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Nintendo-Virtual-Boy.cfg"' /opt/retropie/configs/virtualboy/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/virtualboy/retroarch.cfg
  fi
  ;;
wonderswan)
  ifexist=`cat /opt/retropie/configs/wonderswan/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/wonderswan/retroarch.cfg /opt/retropie/configs/wonderswan/retroarch.cfg.bkp
    cat /opt/retropie/configs/wonderswan/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/wonderswan/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Bandai-WonderSwan-Horizontal.cfg"' /opt/retropie/configs/wonderswan/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/wonderswan/retroarch.cfg
  else
    cp /opt/retropie/configs/wonderswan/retroarch.cfg /opt/retropie/configs/wonderswan/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Bandai-WonderSwan-Horizontal.cfg"' /opt/retropie/configs/wonderswan/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/wonderswan/retroarch.cfg
  fi
  ;;
wonderswancolor)
  ifexist=`cat /opt/retropie/configs/wonderswancolor/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/wonderswancolor/retroarch.cfg /opt/retropie/configs/wonderswancolor/retroarch.cfg.bkp
    cat /opt/retropie/configs/wonderswancolor/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/wonderswancolor/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Bandai-WonderSwan—Color-Horizontal.cfg"' /opt/retropie/configs/wonderswancolor/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/wonderswancolor/retroarch.cfg
  else
    cp /opt/retropie/configs/wonderswancolor/retroarch.cfg /opt/retropie/configs/wonderswancolor/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Bandai-WonderSwan—Color-Horizontal.cfg"' /opt/retropie/configs/wonderswancolor/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/wonderswancolor/retroarch.cfg
  fi
  ;;
amstradcpc)
  ifexist=`cat /opt/retropie/configs/amstradcpc/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/amstradcpc/retroarch.cfg /opt/retropie/configs/amstradcpc/retroarch.cfg.bkp
    cat /opt/retropie/configs/amstradcpc/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/amstradcpc/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Amstrad-CPC.cfg"' /opt/retropie/configs/amstradcpc/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/amstradcpc/retroarch.cfg
  else
    cp /opt/retropie/configs/amstradcpc/retroarch.cfg /opt/retropie/configs/amstradcpc/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Amstrad-CPC.cfg"' /opt/retropie/configs/amstradcpc/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/amstradcpc/retroarch.cfg
  fi
  ;;
atari800)
  ifexist=`cat /opt/retropie/configs/atari800/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/atari800/retroarch.cfg /opt/retropie/configs/atari800/retroarch.cfg.bkp
    cat /opt/retropie/configs/atari800/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/atari800/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-800.cfg"' /opt/retropie/configs/atari800/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atari800/retroarch.cfg
  else
    cp /opt/retropie/configs/atari800/retroarch.cfg /opt/retropie/configs/atari800/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-800.cfg"' /opt/retropie/configs/atari800/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atari800/retroarch.cfg
  fi
  ;;
atarist)
  ifexist=`cat /opt/retropie/configs/atarist/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/atarist/retroarch.cfg /opt/retropie/configs/atarist/retroarch.cfg.bkp
    cat /opt/retropie/configs/atarist/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/atarist/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-ST.cfg"' /opt/retropie/configs/atarist/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atarist/retroarch.cfg
  else
    cp /opt/retropie/configs/atarist/retroarch.cfg /opt/retropie/configs/atarist/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-ST.cfg"' /opt/retropie/configs/atarist/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/atarist/retroarch.cfg
  fi
  ;;
c64)
  ifexist=`cat /opt/retropie/configs/c64/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/c64/retroarch.cfg /opt/retropie/configs/c64/retroarch.cfg.bkp
    cat /opt/retropie/configs/c64/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/c64/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Commodore-64.cfg"' /opt/retropie/configs/c64/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/c64/retroarch.cfg
  else
    cp /opt/retropie/configs/c64/retroarch.cfg /opt/retropie/configs/c64/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Commodore-64.cfg"' /opt/retropie/configs/c64/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/c64/retroarch.cfg
  fi
  ;;
msx)
  ifexist=`cat /opt/retropie/configs/msx/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/msx/retroarch.cfg /opt/retropie/configs/msx/retroarch.cfg.bkp
    cat /opt/retropie/configs/msx/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/msx/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Microsoft-MSX.cfg"' /opt/retropie/configs/msx/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/msx/retroarch.cfg
  else
    cp /opt/retropie/configs/msx/retroarch.cfg /opt/retropie/configs/msx/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Microsoft-MSX.cfg"' /opt/retropie/configs/msx/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/msx/retroarch.cfg
  fi
  ;;
msx2)
  ifexist=`cat /opt/retropie/configs/msx2/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/msx2/retroarch.cfg /opt/retropie/configs/msx2/retroarch.cfg.bkp
    cat /opt/retropie/configs/msx2/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/msx2/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Microsoft-MSX2.cfg"' /opt/retropie/configs/msx2/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/msx2/retroarch.cfg
  else
    cp /opt/retropie/configs/msx2/retroarch.cfg /opt/retropie/configs/msx2/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Microsoft-MSX2.cfg"' /opt/retropie/configs/msx2/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/msx2/retroarch.cfg
  fi
  ;;
videopac)
  ifexist=`cat /opt/retropie/configs/videopac/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/videopac/retroarch.cfg /opt/retropie/configs/videopac/retroarch.cfg.bkp
    cat /opt/retropie/configs/videopac/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/videopac/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Magnavox-Odyssey-2.cfg"' /opt/retropie/configs/videopac/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/videopac/retroarch.cfg
  else
    cp /opt/retropie/configs/videopac/retroarch.cfg /opt/retropie/configs/videopac/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Magnavox-Odyssey-2.cfg"' /opt/retropie/configs/videopac/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/videopac/retroarch.cfg
  fi
  ;;
x68000)
  ifexist=`cat /opt/retropie/configs/x68000/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/x68000/retroarch.cfg /opt/retropie/configs/x68000/retroarch.cfg.bkp
    cat /opt/retropie/configs/x68000/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/x68000/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sharp-X68000.cfg"' /opt/retropie/configs/x68000/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/x68000/retroarch.cfg
  else
    cp /opt/retropie/configs/x68000/retroarch.cfg /opt/retropie/configs/x68000/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sharp-X68000.cfg"' /opt/retropie/configs/x68000/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/x68000/retroarch.cfg
  fi
  ;;
zxspectrum)
  ifexist=`cat /opt/retropie/configs/zxspectrum/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/zxspectrum/retroarch.cfg /opt/retropie/configs/zxspectrum/retroarch.cfg.bkp
    cat /opt/retropie/configs/zxspectrum/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/zxspectrum/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sinclair-ZX-Spectrum.cfg"' /opt/retropie/configs/zxspectrum/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/zxspectrum/retroarch.cfg
  else
    cp /opt/retropie/configs/zxspectrum/retroarch.cfg /opt/retropie/configs/zxspectrum/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Sinclair-ZX-Spectrum.cfg"' /opt/retropie/configs/zxspectrum/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/zxspectrum/retroarch.cfg
  fi
  ;;
supergamemachine)
  ifexist=`cat /opt/retropie/configs/supergamemachine/retroarch.cfg |grep "input_overlay" |wc -l`
  if [[ ${ifexist} > 0 ]]
  then
    cp /opt/retropie/configs/supergamemachine/retroarch.cfg /opt/retropie/configs/supergamemachine/retroarch.cfg.bkp
    cat /opt/retropie/configs/supergamemachine/retroarch.cfg |grep -v input_overlay |grep -v aspect_ratio |grep -v custom_viewport > /tmp/retroarch.cfg
    cp /tmp/retroarch.cfg /opt/retropie/configs/supergamemachine/retroarch.cfg
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/Atari-2600.cfg"' /opt/retropie/configs/supergamemachine/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/supergamemachine/retroarch.cfg
  else
    cp /opt/retropie/configs/supergamemachine/retroarch.cfg /opt/retropie/configs/supergamemachine/retroarch.cfg.bkp
    sed -i '2i input_overlay = "/opt/retropie/configs/all/retroarch/overlay/SuperGameMachine.cfg"' /opt/retropie/configs/supergamemachine/retroarch.cfg
    sed -i '3i input_overlay_opacity = "1.000000"' /opt/retropie/configs/supergamemachine/retroarch.cfg
  fi
  ;;
esac
}

function retroarch_bezelinfo() {

echo "The Bezel Project is setup with the following sytem-to-core mapping." > /tmp/bezelprojectinfo.txt
echo "" >> /tmp/bezelprojectinfo.txt

echo "To show a specific game bezel, Retroarch must have an override config file for each game.  These " >> /tmp/bezelprojectinfo.txt
echo "configuration files are saved in special directories that are named according to the Retroarch " >> /tmp/bezelprojectinfo.txt
echo "emulator core that system uses." >> /tmp/bezelprojectinfo.txt
echo "" >> /tmp/bezelprojectinfo.txt

echo "The supplied Retroarch configuration files for the bezel utility are setup to use certain " >> /tmp/bezelprojectinfo.txt
echo "emulators for certain systems." >> /tmp/bezelprojectinfo.txt
echo "" >> /tmp/bezelprojectinfo.txt

echo "In order for the supplied bezels to be shown, you must be using the proper Retroarch emulator " >> /tmp/bezelprojectinfo.txt
echo "for a system listed in the table below." >> /tmp/bezelprojectinfo.txt
echo "" >> /tmp/bezelprojectinfo.txt

echo "This table lists all of the systems that have the abilty to show bezels that The Bezel Project " >> /tmp/bezelprojectinfo.txt
echo "hopes to make bezels for." >> /tmp/bezelprojectinfo.txt
echo "" >> /tmp/bezelprojectinfo.txt
echo "" >> /tmp/bezelprojectinfo.txt

echo "System                                          Retroarch Emulator" >> /tmp/bezelprojectinfo.txt
echo "Atari 2600                                      lr-stella" >> /tmp/bezelprojectinfo.txt
echo "Atari 5200                                      lr-atari800" >> /tmp/bezelprojectinfo.txt
echo "Atari 7800                                      lr-prosystem" >> /tmp/bezelprojectinfo.txt
echo "ColecoVision                                    lr-bluemsx" >> /tmp/bezelprojectinfo.txt
echo "GCE Vectrex                                     lr-vecx" >> /tmp/bezelprojectinfo.txt
echo "NEC PC Engine CD                                lr-beetle-pce-fast" >> /tmp/bezelprojectinfo.txt
echo "NEC PC Engine                                   lr-beetle-pce-fast" >> /tmp/bezelprojectinfo.txt
echo "NEC SuperGrafx                                  lr-beetle-supergrafx" >> /tmp/bezelprojectinfo.txt
echo "NEC TurboGrafx-CD                               lr-beetle-pce-fast" >> /tmp/bezelprojectinfo.txt
echo "NEC TurboGrafx-16                               lr-beetle-pce-fast" >> /tmp/bezelprojectinfo.txt
echo "Nintendo 64                                     lr-Mupen64plus" >> /tmp/bezelprojectinfo.txt
echo "Nintendo Entertainment System                   lr-fceumm, lr-nestopia" >> /tmp/bezelprojectinfo.txt
echo "Nintendo Famicom Disk System                    lr-fceumm, lr-nestopia" >> /tmp/bezelprojectinfo.txt
echo "Nintendo Famicom                                lr-fceumm, lr-nestopia" >> /tmp/bezelprojectinfo.txt
echo "Nintendo Super Famicom                          lr-snes9x, lr-snes9x2010" >> /tmp/bezelprojectinfo.txt
echo "Sega 32X                                        lr-picodrive, lr-genesis-plus-gx" >> /tmp/bezelprojectinfo.txt
echo "Sega CD                                         lr-picodrive, lr-genesis-plus-gx" >> /tmp/bezelprojectinfo.txt
echo "Sega Genesis                                    lr-picodrive, lr-genesis-plus-gx" >> /tmp/bezelprojectinfo.txt
echo "Sega Master System                              lr-picodrive, lr-genesis-plus-gx" >> /tmp/bezelprojectinfo.txt
echo "Sega Mega Drive                                 lr-picodrive, lr-genesis-plus-gx" >> /tmp/bezelprojectinfo.txt
echo "Sega Mega Drive Japan                           lr-picodrive, lr-genesis-plus-gx" >> /tmp/bezelprojectinfo.txt
echo "Sega SG-1000                                    lr-genesis-plus-gx" >> /tmp/bezelprojectinfo.txt
echo "Sony PlayStation                                lr-pcsx-rearmed" >> /tmp/bezelprojectinfo.txt
echo "Super Nintendo Entertainment System             lr-snes9x, lr-snes9x2010" >> /tmp/bezelprojectinfo.txt
echo "" >> /tmp/bezelprojectinfo.txt

dialog --backtitle "The Bezel Project" \
--title "The Bezel Project - Bezel Pack Utility" \
--textbox /tmp/bezelprojectinfo.txt 30 110
}

# Main

main_menu

