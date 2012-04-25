import shutil
import glob
import os
import pdb
from subprocess import call

def change_link(link,new_link, bin_file):
    arguments = ['-change',  link, new_link, bin_file]
    retcode = call(['install_name_tool'] + arguments)
    if retcode != 0:
        print "Failed ---------"
    print "changed link:", link, "to", new_link, 'in', bin_file, 'ret:', retcode

def change_id(new_id, file_name):
    arguments = ['-id',  new_id, file_name]
    retcode = call(['install_name_tool'] + arguments)
    print "changed id:", new_id, 'in', file_name, 'ret:', retcode

def adjust_link(old_link, new_link, app_name, bin_name, suffix = '64'):

    change_id(new_link, app_name + '/Contents/Frameworks/' + new_link[new_link.rindex('/') + 1:])
    change_link(old_link, new_link, app_name + '/Contents/Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix, suffix))
    change_link(old_link, new_link, app_name + '/Contents/Frameworks/CsoundLib%s.framework/Versions/5.2/lib_csnd.dylib'%suffix)
    
def copy_files(app_name, bin_name, doubles=True):
    suffix = '64' if doubles else ''
    cs_framework = '/Library/Frameworks/CsoundLib%s.framework'%suffix
    try:
        shutil.copytree(cs_framework, app_name + '/Contents/Frameworks/CsoundLib%s.framework'%suffix, symlinks=True )
    except Exception:
        print "Warning: Csound Framework not copied"
        pass
    
    libs = { 'libsndfile.1.dylib': 'libsndfile.1.dylib',
             'libportaudio.2.dylib': 'libportaudio.dylib',
             'libportmidi.dylib': 'libportmidi.dylib',
             #'libmpadec.dylib': 'libmpadec.dylib',
             'liblo.0.dylib' : 'liblo.dylib',
             'libfltk.1.3.dylib' : 'libfltk.dylib',
             'libfltk_images.1.3.dylib' : 'libfltk_images.dylib',
             'libfluidsynth.1.dylib' : 'libfluidsynth.dylib',
             'libpng12.0.dylib' : 'libpng12.dylib',
             'libfluidsynth.1.dylib' : 'libfluidsynth.dylib'}

    lib_dir = '/usr/local/lib/'
    for lib, dest_lib in libs.items():
        shutil.copy(lib_dir + lib, app_name + '/Contents/Frameworks/' + dest_lib )
        adjust_link('/usr/local/lib/' + lib , '@executable_path/../Frameworks/' + dest_lib, app_name, bin_name, suffix)
    
    change_link('/Library/Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
            '@executable_path/../Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
            bin_name)
    change_link('/Library/Frameworks/CsoundLib%s.framework/Versions/5.2/lib_csnd.dylib'%suffix,
            '@executable_path/../Frameworks/CsoundLib%s.framework/Versions/5.2/lib_csnd.dylib'%suffix,
            bin_name)
    change_link('/Library/Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
            '@executable_path/../Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
            app_name + '/Contents/Frameworks/CsoundLib%s.framework/Versions/5.2/lib_csnd.dylib'%suffix)
                
    
    change_link('/usr/local/lib/libfltk.1.3.dylib',
            '@executable_path/../libfltk.dylib',
            app_name + '/Contents/Frameworks/libfltk_images.dylib')
    change_link('/usr/local/lib/libpng12.0.dylib',
            '@executable_path/../libpng12.dylib',
            app_name + '/Contents/Frameworks/libfltk_images.dylib')

    opcode_dir = '/Content/Frameworks/CsoundLib%s.framework/Resources/Opcodes%s'%(suffix,suffix)
    opcode_libs = glob.glob(app_name + opcode_dir + '/*.dylib')

    for op_lib in opcode_libs:
        for dep_lib, dep_dest_lib in libs.items():
            change_link('/usr/local/lib/' + dep_lib , '@executable_path/../Frameworks/' + dep_dest_lib,
                    op_lib)
            change_link('/usr/local/lib/' + dep_lib , '@executable_path/../Frameworks/' + dep_dest_lib,
                    op_lib)
            change_link('/Library/Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
                    '@executable_path/../Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
                    op_lib)

if (not os.path.exists('build')):
    os.mkdir("build")

os.chdir("build")
qute_app_dir = 'bin/'
qtbindir = '/Users/acabrera/QtSDK/Desktop/Qt/4.8.1/gcc/bin/'
qmake = qtbindir + "qmake"
macdeployqt = qtbindir + "macdeployqt"

doubles = False
os.system(qmake + " /Users/acabrera/src/qutecsound/trunk/qutecsound/QuteApp/QuteApp.pro -r -spec macx-g++ CONFIG+=release CONFIG+=buildFloats")
#os.system("make clean")
os.system("make -w")
binary = 'QuteApp_' + ('d' if doubles else 'f')
pdb.set_trace()
os.system(macdeployqt + ' ' + qute_app_dir + binary + '.app')
copy_files(qute_app_dir + binary + '.app', qute_app_dir + binary + '.app/Contents/MacOS/' + binary, doubles)
if (os.path.exists(qute_app_dir + '../../../src/res/osx/' + binary + '.app')):
    shutil.rmtree(qute_app_dir + '../../../src/res/osx/' + binary + '.app')
shutil.copytree(qute_app_dir + binary + '.app', qute_app_dir + '../../../src/res/osx/' + binary + '.app' , symlinks=True )

doubles = True
os.system(qmake + " /Users/acabrera/src/qutecsound/trunk/qutecsound/QuteApp/QuteApp.pro -r -spec macx-g++ CONFIG+=release CONFIG+=buildDoubles")
#os.system("make clean")
os.system("make -w")
binary = 'QuteApp_' + ('d' if doubles else 'f')
os.system(macdeployqt + ' ' + qute_app_dir + binary + '.app')
copy_files(qute_app_dir + binary + '.app', qute_app_dir + binary + '.app/Contents/MacOS/' + binary, doubles)
if (os.path.exists(qute_app_dir + '../../../src/res/osx/' + binary + '.app')):
    shutil.rmtree(qute_app_dir + '../../../src/res/osx/' + binary + '.app')
shutil.copytree(qute_app_dir + binary + '.app', qute_app_dir + '../../../src/res/osx/' + binary + '.app' , symlinks=True )


