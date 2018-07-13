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
# Change Log
#########################################################################################

# 7/13/18 - Major updates to script logic and error correction by Kyle Bareis
#           * updated if statements to use true/false over yes/no
#           * added FileVault deferred enablement check and modified to logout or continue
#           * added tested versions comment
#           * additional cleanup and error checking
# 6/28/18 - Initial commit by Kyle Bareis

#########################################################################################
# Tested Software Versions
#########################################################################################

# macOS 10.13.5
# DEPNotify 1.1.0
# Jamf Pro 10.5

#########################################################################################
# How to Use
#########################################################################################

# This script is designed to make implementation of DEPNotify very easy with limited
# scripting knowledge. The section below has variables that may be modified to customize
# the end user experience. DO NOT modify things in or below the CORE LOGIC area unless
# major testing and validation is performed.

# Overview of Jamf Pro Setup
# 1. Create policies to install core software during first setup. Set the frequency to
#    ongoing and the trigger to custom and type in a trigger. Ex: depNotifyFirefox
# 2. Once software policies are created, customize this script with changes to verbiage
#    as well as updating the POLICY_ARRAY with appropriate information
# 3. Upload DEP Notify.pkg and this script to Jamf Pro. Create a policy to install the
#    PKG and this script using the Enrollment Complete trigger. Also set the
#    execution frequency to ongoing.
# 4. Once a computer is finished enrolling, the DEP Notify policy will start and then
#    call the other policies in order based on the array.

# DEP Notify PKG and Documentation can be found at: https://gitlab.com/Mactroll/DEPNotify

#########################################################################################
# To Do List
#########################################################################################

# Finalize EULA process - Open issue: https://gitlab.com/Mactroll/DEPNotify/issues/19
# Create generic registration module

#########################################################################################
# Variables to Modify
#########################################################################################
# Testing flag will enable the following things to change:
  # - Auto removal of BOM files to reduce errors
  # - Sleep commands instead of polcies being called
  # - Quit Key set to command + control + x
  TESTING_MODE=true # Set variable to true or false

# Flag the app to open fullscreen or as a window
  FULLSCREEN=false # Set variable to true or false

# Banner image can be 600px wide by 100px high. Images will be scaled to fit
# If this variable is left blank, the generic image will appear
  BANNER_IMAGE_PATH="/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/remote_management.tiff"

# Main heading that will be displayed under the image
# If this variable is left blank, the generic banner will appear
  BANNER_TITLE="Welcome to Organization"

# Paragraph text that will display under the main heading. For a new line, use \\n
# If this variable is left blank, the generic message will appear. Leave single
# quotes below as double quotes will break the new line.
  MAIN_TEXT='Thanks for choosing a Mac at Organization! We want you to have a few applications and settings configured before you get started with your new Mac. This process should take 10 to 20 minutes to complete. \\n \\n If you need addtional software or help, please visit the Self Service app in your Applications folder or on your Dock.'

# URL for support or help that will open when the ? is clicked
# If this variable is left blank, the ? will not appear
  SUPPORT_URL="https://support.apple.com"

# Initial Start Status text that shows as things are firing up
  INITAL_START_STATUS="Initial Configuration Starting..."

# EULA configuration
# CURRENTLY BROKEN - seeing issues with the EULA and contiune buttons
  EULA_ENABLED=false # Set variable to true or false
  EULA_TXT_FILE="/var/tmp/eula.txt"

# The policy array must be formatted "Progress Bar text,customTrigger". These will be
# run in order as they appear below.
  POLICY_ARRAY=(
    "Installing Chrome,depNotifyChrome"
    "Installing Firefox,depNotifyFirefox"
  )

# Text that will display in the progress bar
  INSTALL_COMPLETE_TEXT="Configuration Complete!"

# Script designed to automatically logout user to start FileVault process if
# deferred enablement is detected. Text displayed if deferred status is on.
  FV_LOGOUT_TEXT="Your Mac must logout to start the disk encryption process. After reboot, you may use your Mac normally."

# Text that will display inside the alert once policies have finished
  COMPLETE_ALERT_TEXT="Your Mac is now finished with initial setup and configuration. Press Quit to get started!"

#########################################################################################
# Core Script Logic - Don't Change Without Major Testing
#########################################################################################

# Variables for File Paths
  JAMF_BINARY="/usr/local/bin/jamf"
  FDE_SETUP_BINARY="/usr/bin/fdesetup"
  APPLE_SETUP_DONE="/var/db/.AppleSetupDone"
  DEP_NOTIFY_APP="/Applications/Utilities/DEPNotify.app"
  DEP_NOTIFY_CONFIG="/var/tmp/depnotify.log"
  DEP_NOTIFY_DONE="/var/tmp/com.depnotify.provisioning.done"
  DEP_NOTIFY_EULA="/var/tmp/com.depnotify.agreement.done"

# Validating true/false flags
  if [ "$TESTING_MODE" != true ] && [ "$TESTING_MODE" != false ]; then
    echo "Testing configuration not set properly. Currently set to '$TESTING_MODE'. Please update to true or false."
    exit 1
  fi
  if [ "$FULLSCREEN" != true ] && [ "$FULLSCREEN" != false ]; then
    echo "Fullscreen configuration not set properly. Currently set to '$FULLSCREEN'. Please update to true or false."
    exit 1
  fi
  if [ "$EULA_ENABLED" != true ] && [ "$EULA_ENABLED" != false ]; then
    echo "EULA configuration not set properly. Currently set to '$EULA_ENABLED'. Please update to true or false."
    exit 1
  fi

# Run DEP Notify as the current logged in user. If there is none, it will exit
   CURRENT_USER=$(ls -la /dev/console | cut -d " " -f 4)
   while [ "$CURRENT_USER" = "" ] || [ "$CURRENT_USER" = "root" ] || [ ! -f "$APPLE_SETUP_DONE" ]; do
     echo "Cannot run without a user at the desktop or has not finished Setup Assistant. Sleeping 5 seconds"
     sleep 5
   done

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
    echo "Command: Logout: $FV_LOGOUT_TEXT" >> "$DEP_NOTIFY_CONFIG"
  else
    echo "Command: Quit: $COMPLETE_ALERT_TEXT" >> "$DEP_NOTIFY_CONFIG"
  fi
  exit 0
