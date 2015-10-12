#!/bin/sh
# File Name:CheckDownloadsFolder.sh
# Check and report via EA size of user's Downloads folder
# github.com/acodega
#

#find logged in user
loggedinuser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

#find how large downloads is
downloads=`du -hd 1 /Users/$loggedinuser/Downloads | awk 'END{print $1}'`

#echo it for EA
echo "<result>$downloads</result>" 