# DEP Notify for Jamf Pro
Template bash script to start DEP Notify and run Policies during enrollment with Jamf. App installer, source code, and documentation can be found at: https://gitlab.com/Mactroll/DEPNotify

![](https://github.com/jamfprofessionalservices/DEP-Notify/blob/master/example-img/fullscreen-mode.png)

## How to Use

This script is designed to make implementation of DEP Notify very easy with limited scripting knowledge. The script has variables that may be modified to customize the end user experience. DO NOT modify things in or below the CORE LOGIC area unless major testing and validation is performed.

**Please note, the script is set to testing mode by default.** Having testing mode on will cause the following things to occur:
* Sleep commands in place of running Policies
* Removal of BOM and configuration files
* Command + Control + x is set to quit or interrupt DEP Notify

The script will need to be changed from `TESTING_MODE=true` to `TESTING_MODE=false` for polices to run properly.

**It is recommended that you read the script fully and make changes that suit your organization prior to deployment to end user devices.**

## Overview of Jamf Pro Setup

While each organization will use a setup tool like DEP Notify differently, here is the most common way that it is delivered as well as how the script was designed to function. Changing the workflow should result in testing prior to production release.

1. Create policies in Jamf Pro to install core software during first setup. Set the frequency to ongoing and the trigger to custom and type in a manual trigger. Ex: depNotifyFirefox or installOffice201x
2. Once software policies are created, customize this script with changes to verbiage as well as updating the POLICY_ARRAY with appropriate information. Double check the testing flag once you are ready to proceed.
3. Upload DEP Notify.pkg (downloaded from https://gitlab.com/Mactroll/DEPNotify) and this script to Jamf Pro. Create a policy to install the PKG and this script using the Enrollment Complete trigger. Also set the execution frequency to ongoing.
4. Once a computer is finished enrolling, the DEP Notify policy will start and then call the other policies in order based on the array.
5. (Optional) If using the EULA window, there must be a .txt file saved somewhere locally prior to DEPNotify running. A by default, the script is looking in /Users/Shared for eula.txt.
6. (Optional) If using the registration window, you must have the departments and buildings in Jamf prior to running DEP Notify on the client.
7. (Optional) If you are requiring FileVault encryption, the script will automatically check at the end of running policies if deferred enablement is on. This will trigger a logout instead of a quit of DEP Notify.

DEP Notify PKG and additional documentation can be found at: https://gitlab.com/Mactroll/DEPNotify

## Tested Software Versions

* macOS 10.4.0
* macOS 10.13.6
* DEPNotify 1.1.0
* Jamf Pro 10.7.1

## Change Log

xx/xx/xx - Release v1.2.0: Major enhancements and additions across the board by Kyle Bareis
* Fixed several comments and made descriptions clearer
* Brought SELF_SERVICE_APP_NAME variable into the variables area for easier modification
* Added configuration for the DEPNotify plist that saves EULA and Registration window info
  * DEP_NOTIFY_INFO_PLIST has been added as a configurable option
* Added EULA logic and variables
  * Currently turned off as it causes issues with the app exiting gracefully
  * EULA_FILE_PATH has been added as a configurable option
* Added registration window logic
  * Currently turned off as it causes issues with the app exiting gracefully
  * REGISTER_TITLE has been added as a configurable option
  * REGISTER_BUTTON has been added as a configurable option
  * REGISTER_BEGIN_STATUS has been added as a configurable option
  * REGISTER_MIDDLE_STATUS has been added as a configurable option
  * TEXT_UPPER_DISPLAY has been added as a configurable option
  * TEXT_UPPER_PLACEHOLDER has been added as a configurable option
  * TEXT_UPPER_LOGIC has been added as a configurable option
  * TEXT_LOWER_DISPLAY has been added as a configurable option
  * TEXT_LOWER_PLACEHOLDER has been added as a configurable option
  * TEXT_LOWER_LOGIC has been added as a configurable option
  * PICK_UPPER_DISPLAY has been added as a configurable option
  * PICK_UPPER_OPTIONS has been added as a configurable option
  * PICK_UPPER_LOGIC has been added as a configurable option
  * PICK_LOWER_DISPLAY has been added as a configurable option
  * PICK_LOWER_OPTIONS has been added as a configurable option
  * PICK_LOWER_LOGIC has been added as a configurable option
* Added a kill command for exiting Self Service if SELF_SERVICE_CUSTOM_BRANDING is set to true
* Added an alert window that lets the admin know if the script is in TESTING_MODE when set to true
* Added TESTING_MODE logic to FileVault logout to make it easier to test without having to logout

9/25/18 - Release v1.1.1: Added variable and check for custom Self Service branding by Kyle Bareis
* Added true/false variable for custom Self Service branding
* Added loop for waiting for the custom branding to be downloaded
* Removed To Do list, how to use, and tested versions from bash script
* Updated GitHub Readme file with additional information

9/24/18 - Release v1.1.0: Updated loop for verifying Apple Setup Complete by Arek Dryer and Kyle Bareis
* Changed loop to look for the Setup Assistant process rather than files and users
* Changed /dev/console lookup to stat per shellcheck.net recommendation
* Verified with 10.13.6, 10.14 and Jamf Pro 10.7.1
* Removed double \\ in the new line escapes. Has changed in a recent update.
* Added a troubleshooting and debugging log for helping out with DEP related issues.
* Debug log focused on what happens prior to DEP Notify creation.
* Changed default image to Self Service icon.

7/13/18 - Release v1.0.0: Major updates to script logic and error correction by Kyle Bareis
* updated if statements to use true/false over yes/no
* added FileVault deferred enablement check and modified to logout or continue
* added tested versions comment
* additional cleanup and error checking

6/28/18 - Initial commit by Kyle Bareis
