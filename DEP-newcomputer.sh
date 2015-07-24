#!/bin/sh
#
########################################################################
# Created By: Adam Codega, Swipely Inc.
# 	with help from Ross Derewianko Ping Identity Corporation
# Creation Date: June 2015 
# Brief Description: Changes machine hostname based on first initial and
# 	last name of local user. Then, ask IT tech which department to
# 	set computer to in JSS.
########################################################################

#check for CocoaDialog & if not install it
if [ -d "/usr/sbin/cocoaDialog.app" ]; then
	CoDi="/usr/sbin/cocoaDialog.app/Contents/MacOS/cocoaDialog"
else
	echo "CocoaDialog.app not found installing" 
	/usr/sbin/jamf policy -trigger cocoa
fi

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
	jamf setComputerName -name $hostname
}

function cdprompt() {
	jssdept=`"$CoDi" standard-dropdown --title "Choose a Department"  --height 150 --text "Department" --items "Business Administration" Engineering Finance Marketing Product Sales Success "Talent + Office Ops"`

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
	jamf recon -department $dept
}


########################################################################
# Script
########################################################################

sethostname
cdprompt
setdepartment

# now that the dept is set let's apply profiles and policies
jamf manage
jamf policy

# manage and policy probably changed stuff, so let's submit an updated inventory
jamf recon

# install all updates and turn schedule On
softwareupdate -ia --schedule on

#notify the tech that computer is ready for restart
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -startlaunchd -windowType hud -title "JAMF Software" -heading "Enrollment Complete" -description "Enrollment has been completed. You should restart to enable FileVault 2." -button1 "OK" -defaultButton 1

