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
  # - Sleep commands instead of polcies or other changes being called
  # - Quit Key set to command + control + x
  TESTING_MODE=true # Set variable to true or false

# Flag the app to open fullscreen or as a window
  FULLSCREEN=true # Set variable to true or false

# Banner image can be 600px wide by 100px high. Images will be scaled to fit
# If this variable is left blank, the generic image will appear
  BANNER_IMAGE_PATH="/Applications/Self Service.app/Contents/Resources/AppIcon.icns"

  # Flag for using the custom branding icon from Self Service and Jamf Pro
  # This will override the banner image specified above. If you have changed the
  # name of Self Service, make sure to modify the Self Service path in the Core
  # Logic area under the heading Variables for File Paths
    SELF_SERVICE_CUSTOM_BRANDING=false # Set variable to true or false

    # If using a name other than Self Service with Custom branding. Change the
    # name with the SELF_SERVICE_APP_NAME variable below
      SELF_SERVICE_APP_NAME="Self Service.app"

# Main heading that will be displayed under the image
# If this variable is left blank, the generic banner will appear
  BANNER_TITLE="Welcome to Organization"

# Paragraph text that will display under the main heading. For a new line, use \n
# If this variable is left blank, the generic message will appear. Leave single
# quotes below as double quotes will break the new lines.
  MAIN_TEXT='Thanks for choosing a Mac at Organization! We want you to have a few applications and settings configured before you get started with your new Mac. This process should take 10 to 20 minutes to complete. \n \n If you need addtional software or help, please visit the Self Service app in your Applications folder or on your Dock.'

# URL for support or help that will open when the ? is clicked
# If this variable is left blank, the ? will not appear
# If using fullscreen mode, Safari will be launched behind the DEP Notify window
  SUPPORT_URL="https://support.apple.com"

# Initial Start Status text that shows as things are firing up
  INITAL_START_STATUS="Initial Configuration Starting..."

# If using EULA or Registration Window below, this will configure where the file
# is saved. You may want to save the file for puropses like verifying EULA accpetance
  DEP_NOTIFY_INFO_PLIST_PATH="/var/tmp/"

# EULA configuration
# CURRENTLY BROKEN - seeing issues with the EULA and continue buttons
  EULA_ENABLED=false # Set variable to true or false

  # Path to the EULA file you would like the user to read and agree to. It is
  # best to package this up with Composer or another tool and deliver it to a
  # shared area like /Users/Shared/
    EULA_FILE_PATH="/Users/Shared/eula.txt"

# Registration window configuration
# CURRENTLY BROKEN - seeing issues with the registration and continue buttons
  REGISTER_ENABLED=false # Set variable to true or false

  # Registration window title
    REGISTER_TITLE="Register Your Mac"

  # Registraiton window submit or finish button text
    REGISTER_BUTTON="Register"

  # The text and pick list sections below will right the folling lines out for
  # end users. Use the variables below to configure what the sentance says
  # Ex: Setting Computer Name to macBook0132
    REGISTER_BEGIN_STATUS="Setting"
    REGISTER_MIDDLE_STATUS="to"

  # Registration window can have up to two text fields. Leaving the text display
  # variable empty will hide the input box. Display text is to the side of the
  # input and placeholder text is they grey text inside the input box.
    TEXT_UPPER_DISPLAY="Computer Name"
    TEXT_UPPER_PLACEHOLDER="mac0128371"

    # Logic below was put in this section rather than in core code as folks may
    # want to chnage what the field does. This is a function that gets called
    # when needed later on. BE VERY CAREFUL IN CHANGING THE FUNCTION!
      TEXT_UPPER_LOGIC (){
        TEXT_UPPER_VALUE=$(defaults read "$DEP_NOTIFY_INFO_PLIST" "$TEXT_UPPER_DISPLAY")
        echo "Status: $REGISTER_BEGIN_STATUS $TEXT_UPPER_DISPLAY $REGISTER_MIDDLE_STATUS $TEXT_UPPER_VALUE" >> "$DEP_NOTIFY_LOG"
        if [ "$TESTING_MODE" = true ]; then
           sleep 10
        else
          "$JAMF_BINARY" setComputerName -name "$TEXT_UPPER_VALUE"
        fi
      }

    TEXT_LOWER_DISPLAY="Asset Tag"
    TEXT_LOWER_PLACEHOLDER="1234567890"

    # Logic below was put in this section rather than in core code as folks may
    # want to chnage what the field does. This is a function that gets called
    # when needed later on. BE VERY CAREFUL IN CHANGING THE FUNCTION!
      TEXT_LOWER_LOGIC (){
        TEXT_LOWER_VALUE=$(defaults read "$DEP_NOTIFY_INFO_PLIST" "$TEXT_LOWER_DISPLAY")
        echo "Status: $REGISTER_BEGIN_STATUS $TEXT_LOWER_DISPLAY $REGISTER_MIDDLE_STATUS $TEXT_LOWER_VALUE" >> "$DEP_NOTIFY_LOG"
        if [ "$TESTING_MODE" = true ]; then
           sleep 10
        else
          "$JAMF_BINARY" recon -assetTag "$TEXT_LOWER_VALUE"
        fi
      }

  # Registration window can have up to two dropdown / pick list inputs. Leaving
  # the pick display variable empty will hide the dropdown / pick list.
    PICK_UPPER_DISPLAY="Building"
    PICK_UPPER_OPTIONS=(
      "Amsterdam"
      "Eau Claire"
      "Minneapolis"
    )

    # Logic below was put in this section rather than in core code as folks may
    # want to chnage what the field does. This is a function that gets called
    # when needed later on. BE VERY CAREFUL IN CHANGING THE FUNCTION!
      PICK_UPPER_LOGIC (){
        PICK_UPPER_VALUE=$(defaults read "$DEP_NOTIFY_INFO_PLIST" "$PICK_UPPER_DISPLAY")
        echo "Status: $REGISTER_BEGIN_STATUS $PICK_UPPER_DISPLAY $REGISTER_MIDDLE_STATUS $PICK_UPPER_VALUE" >> "$DEP_NOTIFY_LOG"
        if [ "$TESTING_MODE" = true ]; then
           sleep 10
        else
          "$JAMF_BINARY" recon -building "$PICK_UPPER_VALUE"
        fi
      }

    PICK_LOWER_DISPLAY="Department"
    PICK_LOWER_OPTIONS=(
      "Customer Onboarding"
      "Professional Services"
      "Sales Engineering"
    )

    # Logic below was put in this section rather than in core code as folks may
    # want to chnage what the field does. This is a function that gets called
    # when needed later on. BE VERY CAREFUL IN CHANGING THE FUNCTION!
      PICK_LOWER_LOGIC (){
        PICK_LOWER_VALUE=$(defaults read "$DEP_NOTIFY_INFO_PLIST" "$PICK_LOWER_DISPLAY")
        echo "Status: $REGISTER_BEGIN_STATUS $PICK_LOWER_DISPLAY $REGISTER_MIDDLE_STATUS $PICK_LOWER_VALUE" >> "$DEP_NOTIFY_LOG"
        if [ "$TESTING_MODE" = true ]; then
           sleep 10
        else
          "$JAMF_BINARY" recon -department "$PICK_LOWER_VALUE"
        fi
      }

# The policy array must be formatted "Progress Bar text,customTrigger". These will be
# run in order as they appear below.
  POLICY_ARRAY=(
    "Installing Chrome,chrome"
    "Installing Firefox,firefox"
    "Installing XYZ,xyzCustomTrigger"
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
  DEP_NOTIFY_LOG="/var/tmp/depnotify.log"
  DEP_NOTIFY_DEBUG="/var/tmp/depnotifyDebug.log"
  DEP_NOTIFY_DONE="/var/tmp/com.depnotify.provisioning.done"

# Standard Testing Mode Enahcements
  if [ "$TESTING_MODE" = true ]; then
    # Removing old config file if present (Testing Mode Only)
      if [ -f "$DEP_NOTIFY_LOG" ]; then
        rm "$DEP_NOTIFY_LOG"
      fi
      if [ -f "$DEP_NOTIFY_DONE" ]; then
        rm "$DEP_NOTIFY_DONE"
      fi
      if [ -f "$DEP_NOTIFY_DEBUG" ]; then
        rm "$DEP_NOTIFY_DEBUG"
      fi

    # Setting Quit Key set to command + control + x (Testing Mode Only)
      echo "Command: QuitKey: x" >> "$DEP_NOTIFY_LOG"
  fi

# Validating true/false flags
  if [ "$TESTING_MODE" != true ] && [ "$TESTING_MODE" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Testing configuration not set properly. Currently set to $TESTING_MODE. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi
  if [ "$FULLSCREEN" != true ] && [ "$FULLSCREEN" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Fullscreen configuration not set properly. Currently set to $FULLSCREEN. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi
  if [ "$SELF_SERVICE_CUSTOM_BRANDING" != true ] && [ "$SELF_SERVICE_CUSTOM_BRANDING" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Self Service Custom Branding configuration not set properly. Currently set to $SELF_SERVICE_CUSTOM_BRANDING. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi
  if [ "$EULA_ENABLED" != true ] && [ "$EULA_ENABLED" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): EULA configuration not set properly. Currently set to $EULA_ENABLED. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi
  if [ "$REGISTER_ENABLED" != true ] && [ "$REGISTER_ENABLED" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Registeration configuration not set properly. Currently set to $REGISTER_ENABLED. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi

# Run DEP Notify will run after Apple Setup Assistant and must be run as the end user.
  SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
  until [ "$SETUP_ASSISTANT_PROCESS" = "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Setup Assistant Still Running. PID $SETUP_ASSISTANT_PROCESS." >> "$DEP_NOTIFY_DEBUG"
    sleep 10
    SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
  done

# After the Apple Setup completed. Now safe to grab the current user.
  CURRENT_USER=$(stat -f "%Su" "/dev/console")
  echo "$(date "+%a %h %d %H:%M:%S"): Current user set to $CURRENT_USER." >> "$DEP_NOTIFY_DEBUG"

# If SELF_SERVICE_CUSTOM_BRANDING is set to true. Loading the updated icon
  if [ "$SELF_SERVICE_CUSTOM_BRANDING" = true ]; then
    open -a "/Applications/$SELF_SERVICE_APP_NAME" --hide

  # Loop waiting on the branding image to properly show in the users library
  CUSTOM_BRANDING_PNG="/Users/$CURRENT_USER/Library/Application Support/com.jamfsoftware.selfservice.mac/Documents/Images/brandingimage.png"
    until [ -f "$CUSTOM_BRANDING_PNG" ]; do
      echo "$(date "+%a %h %d %H:%M:%S"): Waiting for branding image from Jamf Pro." >> "$DEP_NOTIFY_DEBUG"
       sleep 1
    done

  # Setting Banner Image for DEP Notify to Self Service Custom Branding
    BANNER_IMAGE_PATH="$CUSTOM_BRANDING_PNG"

  # Closing Self Service
    for SELF_SERVICE_PID in $(pgrep -f "$SELF_SERVICE_APP_NAME"); do
      echo "$(date "+%a %h %d %H:%M:%S"): Self Service custom branding icon has been loaded. Killing DEPNotify PID $SELF_SERVICE_PID." >> "$DEP_NOTIFY_DEBUG"
      kill "$SELF_SERVICE_PID"
    done
  fi

# Setting custom image if specified
  if [ "$BANNER_IMAGE_PATH" != "" ]; then
    echo "Command: Image: $BANNER_IMAGE_PATH" >> "$DEP_NOTIFY_LOG"
  fi

# Setting custom title if specified
  if [ "$BANNER_TITLE" != "" ]; then
    echo "Command: MainTitle: $BANNER_TITLE" >> "$DEP_NOTIFY_LOG"
  fi

# Setting custom main text if specified
  if [ "$MAIN_TEXT" != "" ]; then
    echo "Command: MainText: $MAIN_TEXT" >> "$DEP_NOTIFY_LOG"
  fi

# Adding help url and button if specified
  if [ "$SUPPORT_URL" != "" ]; then
    echo "Command: Help: $SUPPORT_URL" >> "$DEP_NOTIFY_LOG"
  fi

# Plist Location configuration
# The plist information below is used by EULA and Regisration windows
  DEP_NOTIFY_CONFIG_PLIST="/Users/$CURRENT_USER/Library/Preferences/menu.nomad.DEPNotify.plist"
  DEP_NOTIFY_INFO_PLIST="$DEP_NOTIFY_INFO_PLIST_PATH/DEPNotify.plist"

  # If testing mode is on, this will remove some old configuration files
    if [ "$TESTING_MODE" = true ] && [ -f "$DEP_NOTIFY_CONFIG_PLIST" ]; then
        rm "$DEP_NOTIFY_CONFIG_PLIST"
    fi
    if [ "$TESTING_MODE" = true ] && [ -f "$DEP_NOTIFY_INFO_PLIST" ]; then
        rm "$DEP_NOTIFY_INFO_PLIST"
    fi

  # Setting default path to the plist which stores all the user completed info
    defaults write "$DEP_NOTIFY_CONFIG_PLIST" PathToPlistFile "$DEP_NOTIFY_INFO_PLIST_PATH"

# EULA Configuration
  if [ "$EULA_ENABLED" =  true ]; then
    DEP_NOTIFY_EULA_DONE="/var/tmp/com.depnotify.agreement.done"

    # If testing mode is on, this will remove EULA specific configuration files
      if [ "$TESTING_MODE" = true ] && [ -f "$DEP_NOTIFY_EULA_DONE" ]; then
          rm "$DEP_NOTIFY_EULA_DONE"
      fi

    # Writing the location of the EULA file and changing ownership of the file
      defaults write "$DEP_NOTIFY_CONFIG_PLIST" pathToEULA "$EULA_FILE_PATH"
      chown "$CURRENT_USER" "$EULA_FILE_PATH"
      chown "$CURRENT_USER" "$DEP_NOTIFY_CONFIG_PLIST"
  fi

# Registration Plist Configuration
  if [ "$REGISTER_ENABLED" = true ]; then
    DEP_NOTIFY_REGISTER_DONE="/var/tmp/com.depnotify.registration.done"

    # If testing mode is on, this will remove registration specific configuration files
      if [ "$TESTING_MODE" = true ] && [ -f "$DEP_NOTIFY_REGISTER_DONE" ]; then
          rm "$DEP_NOTIFY_REGISTER_DONE"
      fi

    # Main Window Text Configuration
      defaults write "$DEP_NOTIFY_CONFIG_PLIST" RegisterMainTitle "$REGISTER_TITLE"
      defaults write "$DEP_NOTIFY_CONFIG_PLIST" RegisterButtonLabel "$REGISTER_BUTTON"

    # Upper Text Box Configuration
      if [ "$TEXT_UPPER_DISPLAY" != "" ]; then
        defaults write "$DEP_NOTIFY_CONFIG_PLIST" UITextFieldUpperLabel "$TEXT_UPPER_DISPLAY"
        defaults write "$DEP_NOTIFY_CONFIG_PLIST" UITextFieldUpperPlaceholder "$TEXT_UPPER_PLACEHOLDER"
      fi

    # Lower Text Box Configuration
      if [ "$TEXT_LOWER_DISPLAY" != "" ]; then
        defaults write "$DEP_NOTIFY_CONFIG_PLIST" UITextFieldLowerLabel "$TEXT_LOWER_DISPLAY"
        defaults write "$DEP_NOTIFY_CONFIG_PLIST" UITextFieldLowerPlaceholder "$TEXT_LOWER_PLACEHOLDER"
      fi

    # Upper Pick List / Dropdown Configuration
      if [ "$PICK_UPPER_DISPLAY" != "" ]; then
        defaults write "$DEP_NOTIFY_CONFIG_PLIST" UIPopUpMenuUpperLabel "$PICK_UPPER_DISPLAY"
        for PICK_UPPER_OPTION in "${PICK_UPPER_OPTIONS[@]}"; do
           defaults write "$DEP_NOTIFY_CONFIG_PLIST" UIPopUpMenuUpper -array-add "$PICK_UPPER_OPTION"
        done
      fi

    # Lower Pick List / Dropdown Configuration
      if [ "$PICK_LOWER_DISPLAY" != "" ]; then
        defaults write "$DEP_NOTIFY_CONFIG_PLIST" UIPopUpMenuLowerLabel "$PICK_LOWER_DISPLAY"
        for PICK_LOWER_OPTION in "${PICK_LOWER_OPTIONS[@]}"; do
           defaults write "$DEP_NOTIFY_CONFIG_PLIST" UIPopUpMenuLower -array-add "$PICK_LOWER_OPTION"
        done
      fi
    # Changing Ownership of the plist file
      chown "$CURRENT_USER" "$DEP_NOTIFY_CONFIG_PLIST"
  fi

# Opening the app after initial configuration
  if [ "$FULLSCREEN" = true ]; then
    sudo -u "$CURRENT_USER" "$DEP_NOTIFY_APP"/Contents/MacOS/DEPNotify -path "$DEP_NOTIFY_LOG" -fullScreen&
  elif [ "$FULLSCREEN" = false ]; then
    sudo -u "$CURRENT_USER" "$DEP_NOTIFY_APP"/Contents/MacOS/DEPNotify -path "$DEP_NOTIFY_LOG"&
  fi

# Adding an alert prompt to let admins know that the script is in testing mode
  if [ "$TESTING_MODE" = true ]; then
    echo "Command: Alert: DEP Notify is in TESTING_MODE. Script will not run Policies or other commands that make change to this computer."  >> "$DEP_NOTIFY_LOG"
  fi

# Adding nice text and a brief pause for prettiness
  echo "Status: $INITAL_START_STATUS" >> "$DEP_NOTIFY_LOG"
  sleep 5

# Setting the status bar
  # Counter is for making the determinate look nice. Starts at one and adds
  # more based on EULA or register options.
    ADDITIONAL_OPTIONS_COUNTER=1
    if [ "$EULA_ENABLED" = true ]; then
      ((ADDITIONAL_OPTIONS_COUNTER++))
    fi
    if [ "$REGISTER_ENABLED" = true ]; then
      ((ADDITIONAL_OPTIONS_COUNTER++))
    fi
    if [ "$TEXT_UPPER_DISPLAY" != "" ]; then
      ((ADDITIONAL_OPTIONS_COUNTER++))
    fi
    if [ "$TEXT_LOWER_DISPLAY" != "" ]; then
      ((ADDITIONAL_OPTIONS_COUNTER++))
    fi
    if [ "$PICK_UPPER_DISPLAY" != "" ]; then
      ((ADDITIONAL_OPTIONS_COUNTER++))
    fi
    if [ "$PICK_LOWER_DISPLAY" != "" ]; then
      ((ADDITIONAL_OPTIONS_COUNTER++))
    fi

  # Checking policy array and adding the count from the additional options above.
    ARRAY_LENGTH="$((${#POLICY_ARRAY[@]}+ADDITIONAL_OPTIONS_COUNTER))"
    echo "Command: Determinate: $ARRAY_LENGTH" >> "$DEP_NOTIFY_LOG"

# EULA Window Display Logic
  if [ "$EULA_ENABLED" = true ]; then
    echo "Status: Waiting on EULA Acceptance" >> "$DEP_NOTIFY_LOG"
    echo "Command: ContinueButtonEULA: EULA" >> "$DEP_NOTIFY_LOG"
    while [ ! -f "$DEP_NOTIFY_EULA_DONE" ]; do
      sleep 1
    done
  fi

# Registration Window Display Logic
  if [ "$REGISTER_ENABLED" = true ]; then
    echo "Status: $REGISTER_TITLE" >> "$DEP_NOTIFY_LOG"
    echo "Command: ContinueButtonRegister: Register" >> "$DEP_NOTIFY_LOG"
    while [ ! -f "$DEP_NOTIFY_REGISTER_DONE" ]; do
      sleep 1
    done
    # Running Logic For Each Registeration Box
      if [ "$TEXT_UPPER_DISPLAY" != "" ]; then
        TEXT_UPPER_LOGIC
      fi
      if [ "$TEXT_LOWER_DISPLAY" != "" ]; then
        TEXT_LOWER_LOGIC
      fi
      if [ "$PICK_UPPER_DISPLAY" != "" ]; then
        PICK_UPPER_LOGIC
      fi
      if [ "$PICK_LOWER_DISPLAY" != "" ]; then
        PICK_LOWER_LOGIC
      fi
  fi

# Loop to run policies
  for POLICY in "${POLICY_ARRAY[@]}"; do
    echo "Status: $(echo "$POLICY" | cut -d ',' -f1)" >> "$DEP_NOTIFY_LOG"
    if [ "$TESTING_MODE" = true ]; then
      sleep 10
    elif [ "$TESTING_MODE" = false ]; then
      "$JAMF_BINARY" policy -event "$(echo "$POLICY" | cut -d ',' -f2)"
    fi
  done

# Nice completion text
  echo "Status: $INSTALL_COMPLETE_TEXT" >> "$DEP_NOTIFY_LOG"

# Check to see if FileVault Deferred enablement is active
  FV_DEFERRED_STATUS=$($FDE_SETUP_BINARY status | grep "Deferred" | cut -d ' ' -f6)

  # Logic to log user out if FileVault is detected. Otherwise, app will close.
    if [ "$FV_DEFERRED_STATUS" = "active" ] && [ "$TESTING_MODE" = true ]; then
      echo "Command: Quit: This is typically where your FV_LOGOUT_TEXT would be displayed. However, TESTING_MODE is set to true and FileVault deferred status is on." >> "$DEP_NOTIFY_LOG"
    elif [ "$FV_DEFERRED_STATUS" = "active" ] && [ "$TESTING_MODE" = false ]; then
      echo "Command: Logout: $FV_LOGOUT_TEXT" >> "$DEP_NOTIFY_LOG"
    else
      echo "Command: Quit: $COMPLETE_ALERT_TEXT" >> "$DEP_NOTIFY_LOG"
    fi

  exit 0
