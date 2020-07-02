#!/bin/sh

#copy icon for csound mimetypes
SHAREDIR="$1"
if [ -z "$SHAREDIR" ] ; then
	SHAREDIR=/usr/share #~/.local/share # use the latter one for local install
fi
ICONDIR=$SHAREDIR/icons/hicolor/128x128/mimetypes
mkdir -v -p $ICONDIR
# cp -v csound-light-128.png $ICONDIR/csound.png
cp -v csound-dark-128.png $ICONDIR/csound.png

#create and register mimetype
MIMEDIR=$SHAREDIR/mime # or /usr/share/mime
DESTDIR=$MIMEDIR/packages
mkdir -v -p $DESTDIR # make if does not exist
cp -v *.xml $DESTDIR
# Only update db if it already exists
# packages will install into empty trees and
# do not need to update

#if [ -f "$MIMEDIR/mime.cache" ] ; then
#	update-mime-database -V $MIMEDIR
#fi

echo "You may need to log out and log in to make changes effective."
