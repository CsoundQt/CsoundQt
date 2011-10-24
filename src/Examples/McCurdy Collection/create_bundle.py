import zipfile
import glob

dirs = glob.glob("*")

dirs.remove("create_bundle.py")

zfilename = "McCurdy Colection.zip"
zout = zipfile.ZipFile(zfilename, "w")

for dir in dirs:
    files = glob.glob(dir + "/*")
    for f in files:
        zout.write(f)

zout.close()
