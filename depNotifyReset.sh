#!/bin/bash

# Must be run in sudo

# Removing config files in /var/tmp
  rm /var/tmp/depnotify*

# Removing bom files in /var/tmp
  rm /var/tmp/com.depnotify.*

# Removing plists in local user folder
  CURRENT_USER=$(/usr/bin/stat -f "%Su" /dev/console)
  USER_HOME=$(dscl . -read /Users/$CURRENT_USER NFSHomeDirectory | cut -d' ' -f2)
  rm "$USER_HOME"/Library/Preferences/menu.nomad.DEPNotify*

# Restarting cfprefsd due to plist changes
  killall cfprefsd
