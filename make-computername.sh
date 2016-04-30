#!/bin/bash
#
# make-computername.sh
#
# Get computer user's full name
# And make a firstinitial-lastname version
# To set the computer name
#
# Adam Codega, Swipely
#

# find the JAMF binary location
jamfbinary='/usr/bin/which jamf'

# get full name
name=$(finger "`whoami` | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //'")

# get first name
finitial="$(echo $name | head -c 1)"
echo $finitial

# clean for lastname
ln="$(echo $name | cut -d \  -f 2)"
echo $ln

# add first and last together
fullname=($finitial$ln)

# clean up un to have all lower case
hostname=$(echo $fullname | awk '{print tolower($0)}')

# name the computer
$jamfbinary setComputerName -name $hostname
