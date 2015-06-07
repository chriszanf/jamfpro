#!/bin/bash

DOCKUTIL=/usr/local/bin/dockutil

$DOCKUTIL --remove all

$DOCKUTIL --add '/Applications/Launchpad.app' --no-restart

$DOCKUTIL --add '/Applications/Google Chrome.app' --no-restart

$DOCKUTIL --add 'System Preferences' --no-restart

$DOCKUTIL --add '~/Downloads'

exit 0