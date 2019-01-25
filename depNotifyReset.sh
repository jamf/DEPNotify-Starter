#!/bin/bash

# Must be run in sudo

# Removing config files in /var/tmp
  rm /var/tmp/depnotify*

# Removing bom files in /var/tmp
  rm /var/tmp/com.depnotify.*

# Removing plists in local user folder
  CURRENT_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
  rm /Users/"$CURRENT_USER"/Library/Preferences/menu.nomad.DEPNotify*

# Restarting cfprefsd due to plist changes
  killall cfprefsd
