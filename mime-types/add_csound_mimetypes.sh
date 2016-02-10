#!/bin/sh 

#copy icon for csound mimetypes
ICONDIR=~/.local/share/icons/hicolor/256x256/mimetypes
mkdir -v -p $ICONDIR
cp -v csound-256x256.png $ICONDIR/csound.png

#create and register mimetype
MIMEDIR=~/.local/share/mime # or /usr/share/mime 
DESTDIR=$MIMEDIR/packages 
mkdir -v -p $DESTDIR # make if does not exist
cp -v *.xml $DESTDIR
update-mime-database -V $MIMEDIR

echo "You may need to log out and log in to make changes effective." 
