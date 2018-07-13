# DEP-Notify
Bash script to start DEP Notify and run Policies during enrollment with Jamf

## Change Log

7/13/18 - Major updates to script logic and error correction by Kyle Bareis
* updated if statements to use true/false over yes/no
* added FileVault deferred enablement check and modified to logout or continue
* added tested versions comment
* additional cleanup and error checking 

6/28/18 - Initial commit by Kyle Bareis

## Tested Software Versions

* macOS 10.13.5
* DEPNotify 1.1.0
* Jamf Pro 10.5

## How to Use

This script is designed to make implementation of DEPNotify very easy with limited scripting knowledge. The section below has variables that may be modified to customize the end user experience. DO NOT modify things in or below the CORE LOGIC area unless major testing and validation is performed.

## Overview of Jamf Pro Setup
1. Create policies to install core software during first setup. Set the frequency to ongoing and the trigger to custom and type in a trigger. Ex: depNotifyFirefox
2. Once software policies are created, customize this script with changes to verbiage as well as updating the POLICY_ARRAY with appropriate information
 3. Upload DEP Notify.pkg and this script to Jamf Pro. Create a policy to install the PKG and this script using the Enrollment Complete trigger. Also set the execution frequency to ongoing.
4. Once a computer is finished enrolling, the DEP Notify policy will start and then call the other policies in order based on the array.

DEP Notify PKG and Documentation can be found at: https://gitlab.com/Mactroll/DEPNotify

## To Do List

* Finalize EULA process - Open issue: https://gitlab.com/Mactroll/DEPNotify/issues/19
* Create generic registration module
