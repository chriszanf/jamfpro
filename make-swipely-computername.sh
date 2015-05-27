#!/bin/bash
# 
# make-swipely-computername.sh
#
# Get computer user's full name
# And make a firstinitial-lastname version
# To set the computer name
#
# Adam Codega, Swipely
#

#check for cocoa dialogue & if not install it

if [ -d "<cocodialaog location>" ]; then
        CD="<cocodialaog location>/Contents/MacOS/CocoaDialog"
else
        echo "CocoaDialog.app not found installing"
        /usr/sbin/jamf policy -trigger cocoa
fi

JAMFH="/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

# get full name
name=$(finger `whoami` | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //' )

# get first name
finitial="$(echo $name | head -c 1)"
echo $finitial

# clean for lastname
ln="$(echo $name | cut -d \  -f 2)"
echo $ln

# add first and last together
un=($finitial$ln)

# clean up un to have all lower case
un=$(echo $un | awk '{print tolower($0)}')

