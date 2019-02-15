#!/bin/bash
# Version 2.1.0

#########################################################################################
# License information
#########################################################################################
# Copyright 2018 Jamf Professional Services

# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
# to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.

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

# This script will not work without depNotify.sh Please review the readme for more info.

#########################################################################################
# Testing Mode
#########################################################################################
# Testing flag will enable the following things to change:
# Auto removal of BOM files to reduce errors
# Sleep commands instead of policies or other changes being called
# Quit Key set to command + control + x
  TESTING_MODE=true # Set variable to true or false

#########################################################################################
# Policy Variable to Modify
#########################################################################################
# The policy array must be formatted "Progress Bar text,customTrigger". These will be
# run in order as they appear below.
  POLICY_ARRAY=(
    "Installing Adobe Creative Cloud,adobeCC"
    "Installing Adobe Reader,adobeReader"
    "Installing Chrome,chrome"
    "Installing CrashPlan,crashplan"
    "Installing Firefox,firefox"
    "Installing Java,java"
    "Installing NoMAD,nomad"
    "Installing Office,msOffice"
    "Installing Webex,webex"
    "Installing Critical Updates,updateSoftware"
  )

#########################################################################################
#########################################################################################
# Core Script Logic - Don't Change Without Major Testing
#########################################################################################
#########################################################################################

# Variables for File Paths
  JAMF_BINARY="/usr/local/bin/jamf"
  DEP_NOTIFY_LOG="/var/tmp/depnotify.log"
  DEP_NOTIFY_DEBUG="/var/tmp/depnotifyDebug.log"

# Testing Mode
  if [ "$4" != "" ]; then TESTING_MODE="$4"; fi

# Validating true/false flags
  if [ "$TESTING_MODE" != true ] && [ "$TESTING_MODE" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Testing configuration not set properly. Currently set to $TESTING_MODE. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
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
