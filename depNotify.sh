#!/bin/bash
#########################################################################################
# License information
#########################################################################################

# Copyright 2018 Jamf Professional Services
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
# to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

#########################################################################################
# General Information
#########################################################################################

# This script is designed to make implementation of DEPNotify very easy with limited
# scripting knowledge. The section below has variables that may be modified to customize
# the end user experience. DO NOT modify things in or below the CORE LOGIC area unless
# major testing and validation is performed.

# More information at: https://github.com/jamfprofessionalservices/DEP-Notify

#########################################################################################
# Variables to Modify
#########################################################################################
# Testing flag will enable the following things to change:
  # - Auto removal of BOM files to reduce errors
  # - Sleep commands instead of polcies being called
  # - Quit Key set to command + control + x
  TESTING_MODE=true # Set variable to true or false

# Flag the app to open fullscreen or as a window
  FULLSCREEN=true # Set variable to true or false

# Banner image can be 600px wide by 100px high. Images will be scaled to fit
# If this variable is left blank, the generic image will appear
  BANNER_IMAGE_PATH="/Applications/Self Service.app/Contents/Resources/AppIcon.icns"

# Flag for using the custom branding icon from Self Service and Jamf Pro
# This will override the banner image specified above
  SELF_SERVICE_CUSTOM_BRANDING=false # Set variable to true or false

# Main heading that will be displayed under the image
# If this variable is left blank, the generic banner will appear
  BANNER_TITLE="Welcome to Organization"

# Paragraph text that will display under the main heading. For a new line, use \n
# this variable is left blank, the generic message will appear. Leave single
# quotes below as double quotes will break the new line.
  MAIN_TEXT='Thanks for choosing a Mac at Organization! We want you to have a few applications and settings configured before you get started with your new Mac. This process should take 10 to 20 minutes to complete. \n \n If you need addtional software or help, please visit the Self Service app in your Applications folder or on your Dock.'

# URL for support or help that will open when the ? is clicked
# If this variable is left blank, the ? will not appear
# If using fullscreen mode, Safari will be launched behind the DEP Notify window
  SUPPORT_URL="https://support.apple.com"

# Initial Start Status text that shows as things are firing up
  INITAL_START_STATUS="Initial Configuration Starting..."

# EULA configuration
  EULA_ENABLED=false # Set variable to true or false
  
# Registration configuration
  REG_ENABLED=true # Set variable to true or false

# The policy array must be formatted "Progress Bar text,customTrigger". These will be
# run in order as they appear below.
  POLICY_ARRAY=(
    "Installing Chrome,chrome"
    "Installing Firefox,firefox"
    "Installing XYZ,xyzCustomTrigger"
  )

# The Registration preferences array must be formatted "Preference Key 'value".
# Remove any un-wanted prefs
  REG_PREFS_ARRAY=(
    "RegisterMainTitle,ComputerName"
    "RegisterButtonLabel,Submit"
    "UITextFieldUpperLabel,ComputerName"
    "UITextFieldUpperPlaceholder,Type 'SERIAL' for auto name"
    "pathToEULA,/var/tmp/DEPNotifyEULA.txt"
  )

# Text that will display in the progress bar
  INSTALL_COMPLETE_TEXT="Configuration Complete!"

# Script designed to automatically logout user to start FileVault process if
# deferred enablement is detected. Text displayed if deferred status is on.
  FV_LOGOUT_TEXT="Your Mac must logout to start the encryption process. You will be asked to enter your password and click OK or Contiune a few times. Your Mac will be usable while encryption takes place."

# Text that will display inside the alert once policies have finished
  COMPLETE_ALERT_TEXT="Your Mac is now finished with initial setup and configuration. Press Quit to get started!"

#########################################################################################
# Core Script Logic - Don't Change Without Major Testing
#########################################################################################

# Variables for File Paths
  JAMF_BINARY="/usr/local/bin/jamf"
  FDE_SETUP_BINARY="/usr/bin/fdesetup"
  DEP_NOTIFY_APP="/Applications/Utilities/DEPNotify.app"
  DEP_NOTIFY_CONFIG="/var/tmp/depnotify.log"
  DEP_NOTIFY_DONE="/var/tmp/com.depnotify.provisioning.done"
  DEP_NOTIFY_EULA="/var/tmp/com.depnotify.agreement.done"
  DEP_NOTIFY_REG="/var/tmp/com.depnotify.registration.done"
  DEP_NOTIFY_REG_PLIST_PATH="/var/tmp/"
  TMP_DEBUG_LOG="/var/tmp/depNotifyDebug.log"
  DEP_NOTIFY_FILES=$(find /private/var/tmp | grep "depnotify" && find /private/var/tmp | grep "depNotify" && find /private/var/tmp | grep "DEPNotify")

# Validating true/false flags
  if [ "$TESTING_MODE" != true ] && [ "$TESTING_MODE" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Testing configuration not set properly. Currently set to '$TESTING_MODE'. Please update to true or false." >> "$TMP_DEBUG_LOG"
    exit 1
  fi
  if [ "$FULLSCREEN" != true ] && [ "$FULLSCREEN" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Fullscreen configuration not set properly. Currently set to '$FULLSCREEN'. Please update to true or false." >> "$TMP_DEBUG_LOG"
    exit 1
  fi
  if [ "$EULA_ENABLED" != true ] && [ "$EULA_ENABLED" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): EULA configuration not set properly. Currently set to '$EULA_ENABLED'. Please update to true or false." >> "$TMP_DEBUG_LOG"
    exit 1
  fi
  if [ "$REG_ENABLED" != true ] && [ "$REG_ENABLED" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Registation configuration not set properly. Currently set to '$REG_ENABLED'. Please update to true or false." >> "$TMP_DEBUG_LOG"
    exit 1
  fi

# Run DEP Notify will run after Apple Setup Assistant and must be run as the end user.
  SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
  until [ "$SETUP_ASSISTANT_PROCESS" = "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Setup Assistant Still Running. PID $SETUP_ASSISTANT_PROCESS." >> "$TMP_DEBUG_LOG"
    sleep 1
    SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
  done

# Checking to see if the Finder is running now before continuing. This can help
# in scenarios where an end user is not configuring the device.
  FINDER_PROCESS=$(pgrep -l "Finder")
  until [ "$FINDER_PROCESS" != "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Finder process not found. Assuming device is at login screen." >> "$TMP_DEBUG_LOG"
    sleep 1
    FINDER_PROCESS=$(pgrep -l "Finder")
  done

# After the Apple Setup completed. Now safe to grab the current user.
  CURRENT_USER=$(stat -f "%Su" "/dev/console")
  echo "$(date "+%a %h %d %H:%M:%S"): Current user set to $CURRENT_USER." >> "$TMP_DEBUG_LOG"

# If SELF_SERVICE_CUSTOM_BRANDING is set to true. Loading the updated icon
  if [ "$SELF_SERVICE_CUSTOM_BRANDING" = true ]; then
    open -a "/Applications/Self Service.app" --hide

  # Loop waiting on the branding image to properly show in the users library
  CUSTOM_BRANDING_PNG="/Users/$CURRENT_USER/Library/Application Support/com.jamfsoftware.selfservice.mac/Documents/Images/brandingimage.png"
    until [ -f "$CUSTOM_BRANDING_PNG" ]; do
      echo "$(date "+%a %h %d %H:%M:%S"): Waiting for branding image from Jamf Pro." >> "$TMP_DEBUG_LOG"
      sleep 1
    done

  # Setting Banner Image for DEP Notify to Self Service Custom Branding
    BANNER_IMAGE_PATH="$CUSTOM_BRANDING_PNG"
  fi

# Testing Mode Enhancements
  if [ "$TESTING_MODE" = true ]; then
    # Setting Quit Key set to command + control + x (Testing Mode Only)
      echo "Command: QuitKey: x" >> "$DEP_NOTIFY_CONFIG"

    # Removing old config file if present (Testing Mode Only)
      if [ -f "$DEP_NOTIFY_CONFIG" ]; then
        rm "$DEP_NOTIFY_CONFIG"
      fi
      if [ -f "$DEP_NOTIFY_DONE" ]; then
        rm "$DEP_NOTIFY_DONE"
      fi
      if [ -f "$DEP_NOTIFY_EULA" ]; then
        rm "$DEP_NOTIFY_EULA"
      fi
      
      # Removing old config file if present
      for i in $DEP_NOTIFY_FILES; do
      	rm $i
      done
      
      sudo -u "$CURRENT_USER" defaults delete menu.nomad.DEPNotify
      
  fi

# Setting custom image if specified
  if [ "$BANNER_IMAGE_PATH" != "" ]; then
    echo "Command: Image: $BANNER_IMAGE_PATH" >> "$DEP_NOTIFY_CONFIG"
  fi

# Setting custom title if specified
  if [ "$BANNER_TITLE" != "" ]; then
    echo "Command: MainTitle: $BANNER_TITLE" >> "$DEP_NOTIFY_CONFIG"
  fi

# Setting custom main text if specified
  if [ "$MAIN_TEXT" != "" ]; then
    echo "Command: MainText: $MAIN_TEXT" >> "$DEP_NOTIFY_CONFIG"
  fi

# Adding help url and button if specified
  if [ "$SUPPORT_URL" != "" ]; then
    echo "Command: Help: $SUPPORT_URL" >> "$DEP_NOTIFY_CONFIG"
  fi

# Opening the app after initial configuration
  if [ "$FULLSCREEN" = true ]; then
    sudo -u "$CURRENT_USER" "$DEP_NOTIFY_APP"/Contents/MacOS/DEPNotify -path "$DEP_NOTIFY_CONFIG" -fullScreen&
  elif [ "$FULLSCREEN" = false ]; then
    sudo -u "$CURRENT_USER" "$DEP_NOTIFY_APP"/Contents/MacOS/DEPNotify -path "$DEP_NOTIFY_CONFIG"&
  fi

# Adding nice text and a brief pause for prettiness
  echo "Status: $INITAL_START_STATUS" >> "$DEP_NOTIFY_CONFIG"
  sleep 5

# Setting the status bar
  # Counter is for making the determinate look nice. Starts at one and adds
  # more based on EULA or register options.
    ADDITIONAL_OPTIONS_COUNTER=1
    if [ "$EULA_ENABLED" = true ]; then
      ((ADDITIONAL_OPTIONS_COUNTER++))
    fi
    
    if [ "$REG_ENABLED" = true ]; then
      ((ADDITIONAL_OPTIONS_COUNTER++))
    fi

  # Checking policy array and adding the count from the additional options above.
    ARRAY_LENGTH="$((${#POLICY_ARRAY[@]}+ADDITIONAL_OPTIONS_COUNTER))"
    echo "Command: Determinate: $ARRAY_LENGTH" >> "$DEP_NOTIFY_CONFIG"

# EULA prompt prior to configuration
  if [ "$EULA_ENABLED" = true ]; then
    echo "Status: Waiting on EULA Acceptance" >> "$DEP_NOTIFY_CONFIG"
    echo "Command: ContinueButtonEULA: EULA" >> "$DEP_NOTIFY_CONFIG"
    while [ ! -f "$DEP_NOTIFY_EULA" ]; do
      sleep 1
    done
  fi
  
# REG prompt prior to configuration
  if [ "$REG_ENABLED" = true ]; then

	sudo -u "$CURRENT_USER" defaults write menu.nomad.DEPNotify PathToPlistFile "$DEP_NOTIFY_REG_PLIST_PATH"
	for PREF_SET in "${REG_PREFS_ARRAY[@]}"; do
		KEY=$(echo "$PREF_SET" | cut -d ',' -f1)
		PREF=$(echo "$PREF_SET" | cut -d ',' -f2)
		sudo -u "$CURRENT_USER" defaults write menu.nomad.DEPNotify $KEY "$PREF"
	done
	sleep 2
    echo "Status: Waiting on Registration Information" >> "$DEP_NOTIFY_CONFIG"
    echo "Command: ContinueButtonRegister: Continue" >> "$DEP_NOTIFY_CONFIG"
    while [ ! -f "$DEP_NOTIFY_REG" ]; do
      sleep 1
    done
  fi

# Loop to run policies
  for POLICY in "${POLICY_ARRAY[@]}"; do
    echo "Status: $(echo "$POLICY" | cut -d ',' -f1)" >> "$DEP_NOTIFY_CONFIG"
    if [ "$TESTING_MODE" = true ]; then
      sleep 10
    elif [ "$TESTING_MODE" = false ]; then
      "$JAMF_BINARY" policy -event "$(echo "$POLICY" | cut -d ',' -f2)"
    fi
  done

# Check to see if FileVault Deferred enablement is active
  FV_DEFERRED_STATUS=$($FDE_SETUP_BINARY status | grep "Deferred" | cut -d ' ' -f6)

# Exit gracefully after things are finished
  echo "Status: $INSTALL_COMPLETE_TEXT" >> "$DEP_NOTIFY_CONFIG"
  if [ "$FV_DEFERRED_STATUS" = "active" ]; then
    echo "Command: LogoutNow:" >> "$DEP_NOTIFY_CONFIG"
  else	
	if [ "$REG_ENABLED" = true ] || [ "$EULA_ENABLED" = true ]; then
		echo "Command: Quit" >> "$DEP_NOTIFY_CONFIG"
    	killall DEPNotify
		"$JAMF_BINARY" displayMessage -message "$COMPLETE_ALERT_TEXT"
	else
		echo "Command: Quit: $COMPLETE_ALERT_TEXT" >> "$DEP_NOTIFY_CONFIG"
		sleep 60
    	echo "Command: Quit" >> "$DEP_NOTIFY_CONFIG"
    	killall DEPNotify
    fi
  fi
  exit 0
