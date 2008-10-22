#! /bin/sh

if [ `uname` = "Darwin" ]; then
   SVN_PATH="/opt/subversion/bin/"
fi

echo Enter version number:
read QUTECSOUND_VERSION

$SVN_PATH svn export https://qutecsound.svn.sourceforge.net/svnroot/qutecsound qutecsound-$QUTECSOUND_VERSION
mv qutecsound-$QUTECSOUND_VERSION/trunk/qutecsound/* qutecsound-$QUTECSOUND_VERSION
rm -R qutecsound-$QUTECSOUND_VERSION/trunk/
tar -czf qutecsound-src-$QUTECSOUND_VERSION.tar.gz qutecsound-$QUTECSOUND_VERSION
rm -R qutecsound-$QUTECSOUND_VERSION/
