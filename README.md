# DEP Notify
Template bash script to start DEP Notify and run Policies during enrollment with Jamf. App installer, source code, and documentation can be found at https://gitlab.com/Mactroll/DEPNotify

![](https://github.com/jamfprofessionalservices/DEP-Notify/blob/master/example-img/fullscreen-mode.png)

## Change Log

9/24/18 - Updated loop for verifying Apple Setup Complete by Arek Dryer and Kyle Bareis
* Changed loop to look for the Setup Assistant process rather than files and users
* Changed /dev/console lookup to stat per shellcheck.net recommendation
* Verified with 10.13.6, 10.14 and Jamf Pro 10.7.1
* Removed double \\ in the new line escapes. Has changed in a recent update.
* Added a troubleshooting and debugging log for helping out with DEP related issues.
* Debug log focused on what happens prior to DEP Notify creation.
* Changed default image to Self Service icon.

7/13/18 - Major updates to script logic and error correction by Kyle Bareis
* updated if statements to use true/false over yes/no
* added FileVault deferred enablement check and modified to logout or continue
* added tested versions comment
* additional cleanup and error checking

6/28/18 - Initial commit by Kyle Bareis

## Tested Software Versions

* macOS 10.13.6 and macOS 10.4.0
* DEPNotify 1.1.0
* Jamf Pro 10.7.1

## How to Use

This script is designed to make implementation of DEP Notify very easy with limited scripting knowledge. The section below has variables that may be modified to customize the end user experience. DO NOT modify things in or below the CORE LOGIC area unless major testing and validation is performed.

The script is set to testing mode by default. Having testing mode on will cause sleep commands to be run instead of Policies from Jamf. Also, removal of BOM files that are created happen as well to reduce in troubleshooting issues. Finally, Command + Control + x is set to quit or interrupt DEP Notify for testing purposes. The script will need to be changed from `TESTING_MODE=true` to `TESTING_MODE=false` for polices to run properly.

## Overview of Jamf Pro Setup
1. Create policies to install core software during first setup. Set the frequency to ongoing and the trigger to custom and type in a trigger. Ex: depNotifyFirefox
2. Once software policies are created, customize this script with changes to verbiage as well as updating the POLICY_ARRAY with appropriate information
3. Upload DEP Notify.pkg and this script to Jamf Pro. Create a policy to install the PKG and this script using the Enrollment Complete trigger. Also set the execution frequency to ongoing.
4. Once a computer is finished enrolling, the DEP Notify policy will start and then call the other policies in order based on the array.

DEP Notify PKG and Documentation can be found at: https://gitlab.com/Mactroll/DEPNotify

## To Do List

* Finalize EULA process - Open issue: https://gitlab.com/Mactroll/DEPNotify/issues/19
* Create generic registration module
