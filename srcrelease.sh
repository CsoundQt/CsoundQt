#! /bin/sh

echo Enter version number:
read QUTECSOUND_VERSION

git clone git://qutecsound.git.sourceforge.net/gitroot/qutecsound/qutecsound csoundqt-$QUTECSOUND_VERSION-src
rm -Rf csoundqt-$QUTECSOUND_VERSION-src/.git
tar -czf csoundqt-$QUTECSOUND_VERSION-src.tar.gz csoundqt-$QUTECSOUND_VERSION-src
rm -Rf csoundqt-$QUTECSOUND_VERSION-src

