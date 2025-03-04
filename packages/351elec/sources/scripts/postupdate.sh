#!/bin/bash
##
## This script should only run after an update
##
## Config Files
CONF="/storage/.config/distribution/configs/distribution.conf"
RACONF="/storage/.config/retroarch/retroarch.cfg"

# 2021-11-03 (konsumschaf)
# Remove the 2 minutes popup setting from distribution.conf
# Remove old setting for popup (notification.display_time)
sed -i '/int name="audio.display_titles_time" value="120"/d;
        /int name="notification.display_time"/d;
       ' /storage/.config/emulationstation/es_settings.cfg

# set savestate_thumbnail_enable = true (required for savestate menu in ES)
sed -i "/savestate_thumbnail_enable =/d" ${RACONF}
echo "savestate_thumbnail_enable = "true"" >> ${RACONF}

# Sync ES locale only after update
if [ ! -d "/storage/.config/emulationstation/locale" ]
then
  rsync -a /usr/config/locale/ /storage/.config/emulationstation/locale/ &
else
  rsync -a --delete /usr/config/locale/ /storage/.config/emulationstation/locale/ &
fi

# Sync ES resources after update
if [ ! -d "/storage/.config/emulationstation/resources" ]
then
  rsync -a /usr/config/emulationstation/resources/ /storage/.config/emulationstation/resources/ &
else
  rsync -a --delete /usr/config/emulationstation/resources/ /storage/.config/emulationstation/resources/ &
fi

## 2021-10-07
## Copy es_input.cfg over on every update
## This prevents a user with an old es_input from getting the 'input config scree'
### I don't believe there is a use case where a user needed to customize es_input.xml intentionally
if [ -f /usr/config/emulationstation/es_input.cfg ]; then
	cp /usr/config/emulationstation/es_input.cfg /storage/.emulationstation/
fi

## 2021-10-04
## Remove old bezel configs
### Done in a single sed to keep performance fast
sed -i '/global.bezel=0/d;
        /gb.bezel=351ELEC-Gameboy/d;
        /gamegear.bezel=351ELEC-Gamegear/d;
        /gbc.bezel=351ELEC-GameboyColor/d;
        /pokemini.bezel=351ELEC-PokemonMini/d;
        /supervision.bezel=351ELEC-Supervision/d;
        ' /storage/.config/distribution/configs/distribution.conf

## 2021-09-30:
## Remove any configurd ES joypads on upgrade
rm -f /storage/joypads/*.cfg


## 2021-09-27:
## Force replacement of gamecontrollerdb.txt on update
cp -f /usr/config/SDL-GameControllerDB/gamecontrollerdb.txt /storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt

## 2021-09-19:
## Replace libretro settings in distribution.conf
sed -i 's/.emulator=libretro/.emulator=retroarch/g' /storage/.config/distribution/configs/distribution.conf

## 2021-09-17:
## Reset advanemame config
if [ -d /storage/.advance ]; then
  rm -rf /storage/.advance/advmame.rc
fi

## 2021-08-01:
## Check swapfile size and delete it if necessary
. /etc/swap.conf
if [ -f "$SWAPFILE" ]; then
  if [ $(ls -l "$SWAPFILE" | awk '{print  $5}') -lt $(($SWAPFILESIZE*1024*1024)) ]; then
    swapoff "$SWAPFILE"
    rm -rf "$SWAPFILE"
  fi
fi

## 2021-07-27 (konsumschaf)
## Copy es_features.cfg over on every update
if [ -f /usr/config/emulationstation/es_features.cfg ]; then
	cp /usr/config/emulationstation/es_features.cfg /storage/.emulationstation/.
fi

## 2021-07-25:
## Clear OpenBOR data folder
if [ -d /storage/openbor ]; then
  if [ ! -f /storage/openbor/.openbor ]; then
    rm -rf /storage/openbor/*
    touch /storage/openbor/.openbor
  fi
fi

## 2021-07-24 (konsumschaf)
## Remove all settings from retroarch.cfg that are set in setsettings.sh
## Retroarch uses the settings in retroarch.cfg if there is an override file that misses them
/usr/bin/clear-retroarch.sh

## 2021-07-25:
## Remove package drastic if still installed
if [ -x /storage/.config/packages/drastic/uninstall.sh ]; then
        /usr/bin/351elec-es-packages remove drastic
fi
# forced drastic removal to allow upgrade after every image update
if [ ! -d "/storage/roms/gamedata/drastic" ]
then
  mkdir -p "/storage/roms/gamedata/drastic"
  ln -sf /storage/roms/gamedata/drastic /storage/drastic
else
  rm -f /storage/roms/gamedata/drastic/drastic.sh
  rm -f /storage/roms/gamedata/drastic/aarch64/drastic/drastic
fi

## 2021-07-02 (konsumschaf)
## Change the settings for global.retroachievements.leaderboards
if grep -q "global.retroachievements.leaderboards=0" ${CONF}; then
	sed -i "/global.retroachievements.leaderboards/d" ${CONF}
	echo "global.retroachievements.leaderboards=disabled" >> ${CONF}
elif grep -q "global.retroachievements.leaderboards=1" ${CONF}; then
	sed -i "/global.retroachievements.leaderboards/d" ${CONF}
	echo "global.retroachievements.leaderboards=enabled" >> ${CONF}
fi

## 2021-05-27
## Enable D-Pad to analogue at boot until we create a proper toggle
sed -i "/## Enable D-Pad to analogue at boot until we create a proper toggle/d" /storage/.config/distribution/configs/distribution.conf
sed -i "/global.analogue/d" /storage/.config/distribution/configs/distribution.conf
echo '## Enable D-Pad to analogue at boot until we create a proper toggle' >> /storage/.config/distribution/configs/distribution.conf
echo 'global.analogue=1' >> /storage/.config/distribution/configs/distribution.conf

## 2021-05-17:
## Remove mednafen core files from /tmp/cores
if [ "$(ls /tmp/cores/mednafen_* | wc -l)" -ge "1" ]; then
	rm /tmp/cores/mednafen_*
fi

## 2021-05-17:
## Remove package solarus if still installed
if [ -x /storage/.config/packages/solarus/uninstall.sh ]; then
	/usr/bin/351elec-es-packages remove solarus
fi

## 2021-05-12:
## After PCSX-ReARMed core update
## Cleanup the PCSX-ReARMed core remap-files, they are not needed anymore
if [ -f /storage/.config/remappings/PCSX-ReARMed/PCSX-ReARMed.rmp ]; then
	rm /storage/.config/remappings/PCSX-ReARMed/PCSX-ReARMed.rmp
fi

if [ -f /storage/roms/gamedata/remappings/PCSX-ReARMed/PCSX-ReARMed.rmp ]; then
	rm /storage/roms/gamedata/remappings/PCSX-ReARMed/PCSX-ReARMed.rmp
fi

## 2021-05-15:
## MC needs the config
if [[ -z $(ls -A /storage/.config/mc/) ]]; then
	rsync -a /usr/config/mc/* /storage/.config/mc
fi

## 2021-05-15:
## Remove retrorun package if still installed
if [ -x /storage/.config/packages/retrorun/uninstall.sh ]; then
	/usr/bin/351elec-es-packages remove retrorun
fi

## Moved over from /usr/bin/autostart.sh
## Migrate old emuoptions.conf if it exist
if [ -e "/storage/.config/distribution/configs/emuoptions.conf" ]
then
	echo "# -------------------------------" >> /storage/.config/distribution/configs/distribution.conf
	cat /storage/.config/distribution/configs/emuoptions.conf >> /storage/.config/distribution/configs/distribution.conf
	echo "# -------------------------------" >> /storage/.config/distribution/configs/distribution.conf
	mv /storage/.config/distribution/configs/emuoptions.conf /storage/.config/distribution/configs/emuoptions.conf.bak
fi

## Moved over from /usr/bin/autostart.sh
## Save old es_systems.cfg in case it is still needed
if [ -f /storage/.config/emulationstation/es_systems.cfg ]; then
	mv /storage/.config/emulationstation/es_systems.cfg\
	   /storage/.config/emulationstation/es_systems.oldcfg-rename-to:es_systems_custom.cfg-if-needed
fi

## Moved over from /usr/bin/autostart.sh
## Copy after new installation / missing logo.png
if [ "$(cat /usr/config/.OS_ARCH)" == "RG351P" ]; then
	cp -f /usr/config/splash/splash-480l.png /storage/.config/emulationstation/resources/logo.png
elif [ "$(cat /usr/config/.OS_ARCH)" == "RG351V" ] || [ "$(cat /usr/config/.OS_ARCH)" == "RG351MP" ]; then
	cp -f /usr/config/splash/splash-640.png /storage/.config/emulationstation/resources/logo.png
fi


## Just to know when the last update took place
echo Last Update: `date -Iminutes` > /storage/.lastupdate

# Clear Executing postupdate... message
echo -ne "\033[$1;$1H" >/dev/console
echo "                       " > /dev/console