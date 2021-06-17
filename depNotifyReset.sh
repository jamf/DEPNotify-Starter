#!/bin/bash

# Must be run in sudo

# Removing config files in /var/tmp
  rm /var/tmp/depnotify*

# Removing bom files in /var/tmp
  rm /var/tmp/com.depnotify.*

# Removing plists in local user folder
  CURRENT_USER=$(/usr/bin/stat -f "%Su" /dev/console)
  rm /Users/"$CURRENT_USER"/Library/Preferences/menu.nomad.DEPNotify*

# Restarting cfprefsd due to plist changes
  killall cfprefsd
