
import shutil

def change_link(link,new_link,file_name):
    arguments = ['-change',  link, new_link, file_name]
    retcode = call(['install_name_tool'] + arguments)
    print "changed link:", link, 'in', file_name, 'ret:', retcode

def change_id(new_id, file_name):
    arguments = ['-id',  new_id, file_name]
    retcode = call(['install_name_tool'] + arguments)
    print "changed id:", new_id, 'in', file_name, 'ret:', retcode

doubles = True
def copy_files(app_name, doubles=True):
    suffix =''
    if doubles:
        suffix = '64'
    cs_framework = '/Library/Frameworks/CsoundLib%s.framework'%
    shutil.copy(cs_framework, app_name + '/Contents/Frameworks/' )

    libs = { 'libsndfile.1.dylib': 'libsndfile.dylib',
             'libportaudio.2.0.0.dylib': 'libportaudio.dylib',
             'libportmidi.dylib': 'libportmidi.dylib',
             'libmpadec.dylib': 'libmpadec.dylib',
             'liblo.0.6.0.dylib' : 'liblo.dylib',
             'libfltk.1.1.dylib' : 'libfltk.dylib',
             'libfltk_images.1.1.dylib' : 'libfltk_images.dylib',
             'libfluidsynth.1.dylib' : 'libfluidsynth.dylib',
             'libpng12.0.dylib' : 'libpng12.dylib',
             'libpng12.0.dylib' : 'libpng12.dylib'}

    lib_dir = '/usr/local/lib/'
    for lib, dest_lib in libs.items():
        shutil.copy(lib_dir + lib, app_name + '/Contents/Frameworks/' + dest_lib )

    change_id('@executable_path/../Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
              app_name + '/Contents/Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix))
    change_link(cs_framework,
                '@executable_path/../Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
                app_name + '/Contents/MacOS/${ORIGINAL_NAME}')
    
install_name_tool -change  /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
install_name_tool -change /Library/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
install_name_tool -change /Library/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib @executable_path/../Frameworks/CsoundLib.framework/Versions/Current/CsoundLib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib


install_name_tool -id @executable_path/../libsndfile.dylib $APP_NAME/Contents/libsndfile.dylib
install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib
install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}

install_name_tool -id @executable_path/../libportaudio.dylib $APP_NAME/Contents/libportaudio.dylib
install_name_tool -change /usr/local/lib/libportaudio.2.dylib @executable_path/../libportaudio.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libportaudio.2.dylib @executable_path/../libportaudio.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libportmidi.dylib $APP_NAME/Contents/libportmidi.dylib
install_name_tool -change /usr/local/lib/libportmidi.dylib @executable_path/../libportmidi.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libportmidi.dylib @executable_path/../libportmidi.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libmpadec.dylib $APP_NAME/Contents/libmpadec.dylib
install_name_tool -change /usr/local/lib/libmpadec.dylib @executable_path/../libmpadec.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libmpadec.2.dylib @executable_path/../libmpadec.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../liblo.dylib $APP_NAME/Contents/liblo.dylib
install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libfltk.dylib $APP_NAME/Contents/libfltk.dylib
install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libfltk_images.dylib $APP_NAME/Contents/libfltk_images.dylib
install_name_tool -change /usr/local/lib/libfltk_images.1.1.dylib @executable_path/../libfltk_images.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libfltk_images.1.1.dylib @executable_path/../libfltk_images.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib
install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $APP_NAME/Contents/libfltk_images.dylib
install_name_tool -change /usr/local/lib/libpng12.0.dylib @executable_path/../libpng12.dylib $APP_NAME/Contents/libfltk_images.dylib

install_name_tool -id @executable_path/../libpng12.dylib $APP_NAME/Contents/libpng12.dylib

install_name_tool -id @executable_path/../libfluidsynth.dylib $APP_NAME/Contents/libfluidsynth.dylib
install_name_tool -change /usr/local/lib/libfluidsynth.1.dylib @executable_path/../libfluidsynth.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libfluidsynth.1.dylib @executable_path/../libfluidsynth.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

# TODO include dot and Jack installers in an optional directory.

otool -L $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
otool -L $APP_NAME/Contents/libsndfile.dylib
otool -L $APP_NAME/Contents/libportaudio.dylib
otool -L $APP_NAME/Contents/libportmidi.dylib
otool -L $APP_NAME/Contents/libmpadec.dylib
otool -L $APP_NAME/Contents/liblo.dylib
otool -L $APP_NAME/Contents/libpng12.dylib
otool -L $APP_NAME/Contents/libfltk_images.dylib
otool -L $APP_NAME/Contents/libfluidsynth.dylib

# Process plugin opcodes dylibs

cd $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/Resources/Opcodes/

for f in *
do
  echo "---------------- Processing $f file..."
  # take action on each file. $f stores current file name

install_name_tool -id @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/Resources/Opcodes/$f $f
install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $f
install_name_tool -change /usr/local/lib/libportaudio.2.dylib @executable_path/../libportaudio.dylib $f
install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $f
install_name_tool -change libmpadec.dylib @executable_path/../libmpadec.dylib $f
otool -L $f
#  cat $f
done

# Extra changes for plugins with dependencies

install_name_tool -change /usr/local/lib/libfluidsynth.1.dylib @executable_path/../libfluidsynth.dylib libfluidOpcodes.dylib

install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib libimage.dylib
install_name_tool -change /usr/local/lib/libpng12.0.dylib @executable_path/../libpng12.dylib libimage.dylib

install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib libosc.dylib
install_name_tool -change /usr/local/lib/libpng12.0.dylib @executable_path/../libpng12.dylib libosc.dylib

install_name_tool -change /usr/local/lib/libportmidi.dylib @executable_path/../libportmidi.dylib libpmidi.dylib
