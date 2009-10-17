#! /bin/sh

if [ `uname` = "Darwin" ]; then
   SVN_PATH="/opt/subversion/bin/svn"
else
   SVN_PATH="svn"
fi

echo Enter version number:
read QUTECSOUND_VERSION

$SVN_PATH export https://qutecsound.svn.sourceforge.net/svnroot/qutecsound qutecsound-$QUTECSOUND_VERSION
mv qutecsound-$QUTECSOUND_VERSION/trunk/qutecsound/* qutecsound-$QUTECSOUND_VERSION
rm -R qutecsound-$QUTECSOUND_VERSION/trunk/
#rm -R qutecsound-$QUTECSOUND_VERSION/doc/
tar -czf qutecsound-$QUTECSOUND_VERSION-src.tar.gz qutecsound-$QUTECSOUND_VERSION
rm -R qutecsound-$QUTECSOUND_VERSION/
