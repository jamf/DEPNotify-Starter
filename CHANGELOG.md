# Change Log

## [1.2.0] - 2018/10/29

Major enhancements and additions across the board by Kyle Bareis

* Started versioning the script's name to make it easier for folks to know what version of the script they have
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
