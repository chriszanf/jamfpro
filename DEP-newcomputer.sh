#!/bin/sh
#
########################################################################
# Created By: Adam Codega, Swipely Inc.
# 	with help from Ross Derewianko Ping Identity Corporation
# Creation Date: June 2015 
# Last updated: Oct 2015
# Brief Description: Changes machine hostname based on first initial and
# 	last name of local user. Then, ask IT tech which department to
# 	set computer to in JSS. Follows up with installing updates
#   running a recon, and telling tech it's ready to restart.
########################################################################

#Find out where JAMF is because of the JSS 9.8 binary move
jamfbinary=`/usr/bin/which jamf`

#check for cocoaDialog and if not install it
if [ -d "/Applications/Utilities/cocoaDialog.app" ]; then
	echo "CocoaDialog.app installed, continuing on"
else
	echo "CocoaDialog.app not found, pausing to install"
	$jamf_binary policy -trigger cocoa
fi
coDi="/Applications/Utilities/cocoaDialog.app/Contents/MacOS/CocoaDialog"

#######################################################################
# Figure out the hostname
#######################################################################

#Set the hostname

# figure out the user
user=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

#figure out the user's full name
name=$(finger $user | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //' )

# get first initial
finitial="$(echo $name | head -c 1)"

# get last name
ln="$(echo $name | cut -d \  -f 2)"

# add first and last together
un=($finitial$ln)

# clean up un to have all lower case
hostname=$(echo $un | awk '{print tolower($0)}')

#######################################################################
# Functions
#######################################################################

function sethostname() {
	$jamf_binary setComputerName -name $hostname
}

function cdprompt() {
	jssdept=`"$coDi" standard-dropdown --title "Choose a Department"  --height 150 --text "Department" --items "Business Administration" Engineering Finance Marketing Product Sales Success "Talent + Office Ops"`

	if [ "$jssdept" == "2" ]; then
		echo "user cancelled"
		exit 1
	fi
	cleanjssdept
}

#cleans the first two characters out (cocoaDialog adds a 1 \n to the string value which we don't need.)
function cleanjssdept() {
	dept=${jssdept:2}
}

#sets department using JAMF Framework Recon command
function setdepartment() {
	$jamf_binary recon -department $dept
}


########################################################################
# Script
########################################################################

sethostname
cdprompt
setdepartment

# now that the dept is set let's apply profiles and policies
$jamf_binary manage
$jamf_binary policy

# manage and policy probably changed stuff, so let's submit an updated inventory
$jamf_binary recon

# install all updates and turn schedule On
softwareupdate --schedule on
softwareupdate -ia

#notify the tech that computer is ready for restart
$coDi bubble --no-timeout --title "Swipely Enrollment Complete" --text "Restart this computer to enable FileVault 2 Encryption" --icon "computer"
