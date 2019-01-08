# Change Log

## [2.0.1] - 2019/01/08
Made small change to chmod and chown for the DEPNotify configuration plist. There was an issue if EULA and Registration window were not used that the plist would not have proper permissions.

## [2.0.0] - 2018/12/10

Moved to new version release as this release does not have backwards compatibility for older versions of DEPNotify. Please review the new [RELEASES.md](RELEASES.md) page for more information.

* Added [RELEASES.md](RELEASES.md) page to track versions of script app and macOS that have been tested together
* Made small modifications to the [README.md](README.md) page to alert admins to new page
* Separated configurable variables into small chunks by use. Required configurations are closer to the top with more niche options closer to the bottom of the configuration area
* Removed `SUPPORT_URL` as newer version does not support
* Added `STATUS_TEXT_ALIGN`
* Added `HELP_BUBBLE_TITLE`
* Added `HELP_BUBBLE_BODY`
* `DEP_NOTIFY_INFO_PLIST` changed to `DEP_NOTIFY_USER_INPUT_PLIST` as there is a new plist that stores all user input separate from configuration
* EULA Enhancements
  * Added `EULA_MAIN_TITLE`
  * Added `EULA_STATUS`
  * Added `EULA_BUTTON`
  * Added `EULA_SUBTITLE`
* Registration Enhancements
  * `REGISTER_ENABLED` changed to `REGISTRATION_ENABLED` to keep registration options similar
  * Added `REGISTRATION_STATUS`
  * `REGISTER_TITLE` changed to `REGISTRATION_TITLE` to keep registration options similar
  * `REGISTER_BEGIN_STATUS` changed to `REGISTRATION_BEGIN_WORD`
  * `REGISTER_MIDDLE_STATUS` changed to `REGISTRATION_MIDDLE_WORD`
  * First text box
    * `TEXT_UPPER_DISPLAY` changed to `REG_TEXT_LABEL_1`
    * `TEXT_UPPER_PLACEHOLDER` changed to `REG_TEXT_LABEL_1_PLACEHOLDER`
    * Added `REG_TEXT_LABEL_1_OPTIONAL`
    * Added code to allow for optional items to be skipped if empty
    * Added `REG_TEXT_LABEL_1_HELP_TITLE`
    * Added `REG_TEXT_LABEL_1_HELP_TEXT`
    * `TEXT_UPPER_LOGIC` changed to `REG_TEXT_LABEL_1_LOGIC`
    * `TEXT_UPPER_VALUE` changed to `REG_TEXT_LABEL_1_VALUE`
  * Second text box
    * `TEXT_LOWER_DISPLAY` changed to `REG_TEXT_LABEL_2`
    * `TEXT_LOWER_PLACEHOLDER` changed to `REG_TEXT_LABEL_2_PLACEHOLDER`
    * Added `REG_TEXT_LABEL_2_OPTIONAL`
    * Added code to allow for optional items to be skipped if empty
    * Added `REG_TEXT_LABEL_2_HELP_TITLE`
    * Added `REG_TEXT_LABEL_2_HELP_TEXT`
    * `TEXT_LOWER_LOGIC` changed to `REG_TEXT_LABEL_2_LOGIC`
    * `TEXT_LOWER_VALUE` changed to `REG_TEXT_LABEL_2_VALUE`
  * Popup 1
    * `PICK_UPPER_DISPLAY` changed to `REG_POPUP_LABEL_1`
    * `PICK_UPPER_OPTIONS` changed to `REG_POPUP_LABEL_1_OPTIONS`
    * Added `REG_POPUP_LABEL_1_HELP_TITLE`
    * Added `REG_POPUP_LABEL_1_HELP_TEXT`
    * `PICK_UPPER_LOGIC` changed to `REG_POPUP_LABEL_1_LOGIC`
    * `PICK_UPPER_VALUE` changed to `REG_POPUP_LABEL_1_VALUE`
  * Popup 2
    * `PICK_LOWER_DISPLAY` changed to `REG_POPUP_LABEL_2`
    * `PICK_LOWER_OPTIONS` changed to `REG_POPUP_LABEL_2_OPTIONS`
    * Added `REG_POPUP_LABEL_2_HELP_TITLE`
    * Added `REG_POPUP_LABEL_2_HELP_TEXT`
    * `PICK_LOWER_LOGIC` changed to `REG_POPUP_LABEL_2_LOGIC`
    * `PICK_LOWER_VALUE` changed to `REG_POPUP_LABEL_2_VALUE`
  * Added full code to support popup 3
  * Added full code to support popup 4
  * Modified code for ownership and permissions on plists within the user's library folder

## [1.2.0] - 2018/11/01

Major enhancements and additions across the board by Kyle Bareis

* Added a version at the top of the script to allow admins to easier know what version they were running
* Fixed several comments and made descriptions clearer
* Fixed several spelling issues and learned how to use the spell checker in Atom
* Added `NO_SLEEP` mode uses the caffeinate binary for longer installs. Be careful using this option as it may expose sensitive data!
* Brought `SELF_SERVICE_APP_NAME` variable into the variables area for easier modification
* Added ability to choose between dropdown alert boxes and changing the main text and having a button on the main screen via `COMPLETE_METHOD_DROPDOWN_ALERT`. It is recommended that that you leave this set to `false` as there are issues with logout and continue drop down boxes and DEPNotify in the current shipping version
* Added configuration for the DEPNotify plist that saves EULA and Registration window info
  * `DEP_NOTIFY_INFO_PLIST_PATH` has been added as a configurable option
* Added error main screen if BOM files or key logs are found
* Added EULA logic and variables
  * `EULA_FILE_PATH` has been added as a configurable option
  * Recommended that the EULA file is packaged up and delivered via package for easiest deployment method
* Added registration window logic and variables
  * `REGISTER_TITLE` has been added as a configurable option
  * `REGISTER_BUTTON` has been added as a configurable option
  * `REGISTER_BEGIN_STATUS` has been added as a configurable option
  * `REGISTER_MIDDLE_STATUS` has been added as a configurable option
  * `TEXT_UPPER_DISPLAY` has been added as a configurable option
  * `TEXT_UPPER_PLACEHOLDER` has been added as a configurable option
  * `TEXT_UPPER_LOGIC` has been added as a configurable option
  * `TEXT_LOWER_DISPLAY` has been added as a configurable option
  * `TEXT_LOWER_PLACEHOLDER` has been added as a configurable option
  * `TEXT_LOWER_LOGIC` has been added as a configurable option
  * `PICK_UPPER_DISPLAY` has been added as a configurable option
  * `PICK_UPPER_OPTIONS` has been added as a configurable option
  * `PICK_UPPER_LOGIC` has been added as a configurable option
  * `PICK_LOWER_DISPLAY` has been added as a configurable option
  * `PICK_LOWER_OPTIONS` has been added as a configurable option
  * `PICK_LOWER_LOGIC` has been added as a configurable option
* Changed `DEP_NOTIFY_CONFIG` to `DEP_NOTIFY_LOG`
* Added policy parameter support for the `true/false` flag items. Screenshot added to [example-img](example-img) folder
* Changed `CURRENT_USER` from stat method to Python method per community feedback
* Added a kill command for exiting Self Service if `SELF_SERVICE_CUSTOM_BRANDING` is set to true
* Changed DEP Notify app calls from binary open to app open per community feedback
* Added an alert window that lets the admin know if the script is in `TESTING_MODE` when set to true
* Added `TESTING_MODE` logic to FileVault logout to make it easier to test without having to logout
* Added additional screenshots to the [example-img](example-img) folder

## [1.1.2] - 2018/10/04

Added check for Finder process by Kyle Bareis

* Thanks @remusache for finding a workflow that need to be addressed
* Script now should handle workflows which do not have an end user configure the device
* After checking to see if Setup Assistant is finished, script will now check to see if Finder is running

## [1.1.1] - 2018/09/25

Added variable and check for custom Self Service branding by Kyle Bareis

* Added true/false variable for custom Self Service branding
* Added loop for waiting for the custom branding to be downloaded
* Removed To Do list, how to use, and tested versions from bash script
* Updated GitHub Readme file with additional information

## [1.1.0] - 2018/09/24

Updated loop for verifying Apple Setup Complete by Arek Dryer and Kyle Bareis

* Changed loop to look for the Setup Assistant process rather than files and users
* Changed /dev/console lookup to stat per shellcheck.net recommendation
* Verified with 10.13.6, 10.14 and Jamf Pro 10.7.1
* Removed double \\ in the new line escapes. Has changed in a recent update.
* Added a troubleshooting and debugging log for helping out with DEP related issues.
* Debug log focused on what happens prior to DEP Notify creation.
* Changed default image to Self Service icon.

## [1.0.0] - 2018/07/13

Major updates to script logic and error correction by Kyle Bareis

* updated if statements to use true/false over yes/no
* added FileVault deferred enablement check and modified to logout or continue
* added tested versions comment
* additional cleanup and error checking

## [0.9.9] - 2018/06/28

Initial commit by Kyle Bareis
