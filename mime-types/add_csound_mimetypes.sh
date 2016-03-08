#!/bin/sh 

#copy icon for csound mimetypes
INSTALLDIR="$1"
if [ -z "$INSTALLDIR" ] ; then
	INSTALLDIR=/usr #~/.local # use the latter one for local install
fi
ICONDIR=$INSTALLDIR/share/icons/hicolor/128x128/mimetypes 
mkdir -v -p $ICONDIR
cp -v csound-light-128.png $ICONDIR/csound.png

#create and register mimetype
MIMEDIR=$INSTALLDIR/share/mime # or /usr/share/mime 
DESTDIR=$MIMEDIR/packages 
mkdir -v -p $DESTDIR # make if does not exist
cp -v *.xml $DESTDIR
if [ "$2" != "no-update" ] ; then
	update-mime-database -V $MIMEDIR
fi

echo "You may need to log out and log in to make changes effective." 
