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

While each organization will use a setup tool like DEP Notify differently, this script is designed with an end user provisioning model in mind. Changing the workflow should result in testing prior to production release.

1. Create policies in Jamf Pro to install core software during first setup. Set the frequency to ongoing and the trigger to custom and type in a manual trigger. Ex: depNotifyFirefox or installOffice201x
2. Once software policies are created, customize this script with changes to verbiage as well as updating the POLICY_ARRAY with appropriate information. Double check the testing flag once you are ready to proceed.
3. Upload DEP Notify.pkg (downloaded from https://gitlab.com/Mactroll/DEPNotify) and this script to Jamf Pro. Create a policy to install the PKG and this script using the Enrollment Complete trigger. Also set the execution frequency to ongoing.
4. Once a computer is finished enrolling, the DEP Notify policy will start and then call the other policies in order based on the array.
5. (Optional) If using the EULA window, there must be a .txt file saved somewhere locally prior to DEPNotify running. A by default, the script is looking in /Users/Shared for eula.txt.
6. (Optional) If using the registration window, you must have the departments and buildings in Jamf prior to running DEP Notify on the client. Each text box or drop down has its own code so that it can be modified to suit individual needs. Make sure to test a bunch if the logic sections are changed
7. (Optional) If you are requiring FileVault encryption, the script will automatically check at the end of running policies if deferred enablement is on. This will trigger a logout instead of a quit of DEP Notify.

More information about specific variables and options can be found in the script with comments for each item.

DEP Notify PKG and additional documentation can be found at: https://gitlab.com/Mactroll/DEPNotify

## Tested Software Versions

* macOS 10.4.0
* macOS 10.13.6
* DEPNotify 1.1.0
* Jamf Pro 10.8

## Change Log

The change log was getting a bit long and now has moved to its own page. Please visit the [CHANGELOG.md](CHANGELOG.md) for more information.