#!/bin/sh

#
# Fix Spotlight on OS X due to Casper Imaging 9.72 bug
#

rm -rf /.metadata_never_index
rm -rf /.Spotlight-V100

sleep 1

mdutil -i on -a