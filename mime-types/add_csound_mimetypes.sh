#!/bin/sh 

#copy icon for csound mimetypes
ICONDIR=~/.local/share/icons/hicolor/48x48/mimetypes
mkdir -v -p $ICONDIR
cp -v csound.png $ICONDIR/csound.png

#create and register mimetype
MIMEDIR=~/.local/share/mime # or /usr/share/mime 
DESTDIR=$MIMEDIR/packages 
mkdir -v -p $DESTDIR # make if does not exist
cp -v *.xml $DESTDIR
update-mime-database -V $MIMEDIR

echo "You may need to log out and log in to make changes effective." 
