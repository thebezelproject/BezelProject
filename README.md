# bezelproject

-------
OVERVIEW

The Bezel Project Bezel Utility menu.

This utility will provide a downloader for Retroarach system bezel packs to be used for various systems within RetroPie.

This utility provides a download for a bezel pack for a system and includes a PNG bezel file for every ROM for that system.  The download will also include the necessary configuration files needed for Retroarch to show them.  The script will also update the required retroarch.cfg files for the emulators located in the /opt/retropie/configs directory.  These changes are necessary to show the PNG bezels with an opacity of 1.

Periodically, new bezel packs are completed and you will need to run the script updater to download the newest version to see these additional packs.

The instructions below will demonstrate how to instal the script and have it show up in the RetroPie menu within Emulation Station.

***NOTE***
To have global support, these bezel packs will only work if the ROMs you are using are named according to the No-Intro naming convention used by EmuMovies/HyperSpin.

-------
INSTALLATION - using a Raspberry Pi build of RetroPie

NOTE: do not install the script as user 'root'.  Only install the script as user 'pi'...otherwise it may cause future errors.

Exit out of Emulation Station by pressing F4 (or remote into the Pi using something like Putty)

Type the following commands:

***cd /home/pi/RetroPie/retropiemenu/*** 

***wget https://raw.githubusercontent.com/thebezelproject/BezelProject/master/bezelproject.sh***

***chmod +x "bezelproject.sh"***

Restart Emulation Station and you should then see the new script in the RetroPie menu.

-------
Supported cores

Arcade                                          lr-mame2003, lr-mame2010, lr-fba

Atari 2600                                      lr-stella

Atari 5200                                      lr-atari800

Atari 7800                                      lr-prosystem

ColecoVision                                    lr-bluemsx

GCE Vectrex                                     lr-vecx

NEC PC Engine CD                                lr-beetle-pce-fast

NEC PC Engine                                   lr-beetle-pce-fast

NEC SuperGrafx                                  lr-beetle-supergrafx

NEC TurboGrafx-CD                               lr-beetle-pce-fast

NEC TurboGrafx-16                               lr-beetle-pce-fast

Nintendo 64                                     lr-Mupen64plus

Nintendo Entertainment System                   lr-fceumm, lr-nestopia

Nintendo Famicom Disk System                    lr-fceumm, lr-nestopia

Nintendo Famicom                                lr-fceumm, lr-nestopia

Nintendo Super Famicom                          lr-snes9x, lr-snes9x2010

Sega 32X                                        lr-picodrive, lr-genesis-plus-gx

Sega CD                                         lr-picodrive, lr-genesis-plus-gx

Sega Genesis                                    lr-picodrive, lr-genesis-plus-gx

Sega Master System                              lr-picodrive, lr-genesis-plus-gx

Sega Mega Drive                                 lr-picodrive, lr-genesis-plus-gx

Sega Mega Drive Japan                           lr-picodrive, lr-genesis-plus-gx

Sega SG-1000                                    lr-genesis-plus-gx

Sony PlayStation                                lr-pcsx-rearmed

Super Nintendo Entertainment System             lr-snes9x, lr-snes9x2010


