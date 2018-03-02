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

Exit out of Emulation Station by pressing F4 (or remote into the Pi using something like Putty)

Type the following commands:

cd /home/pi/RetroPie/retropiemenu/ 
wget https://raw.githubusercontent.com/thebezelproject/BezelProject/master/bezelproject.sh

chmod +x "bezelproject.sh"

Restart Emulation Station and you should then see the new script in the RetroPie menu.

---------------
Contact information:

Look for the Facebook group called:  Bezel Bin

