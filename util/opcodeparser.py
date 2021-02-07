#!/usr/bin/env python3

# This script generates the opcode.xml file
# by Andres Cabrera June 2006-2010
# Licensed under the GPL licence version 3 or later
# modification for empty arg in command and links on opcodes by Francois Pinot February 2007

from xml.dom import minidom
import os
import glob
import sys
from pathlib import Path
# categories holds the list of valid categories for opcodes
from categories import categories

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-o", "--outfile", default="opcodes.xml")
parser.add_argument("--manual", default='', help='The root to the manual repository')
parser.add_argument("--xo", action="store_true")

args = parser.parse_args()
outfilename = args.outfile
XO = args.xo

manualroot = Path(args.manual) 

opcodelist = []

# outfilename = 'opcodes.xml'
quickref = open(outfilename, 'w')
quickref.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!-- Don't modify this file. It is generated automatically by opcodeparser.py\nThis file is distributed under the GNU Free Documentation Licence-->")
quickref.write('''<opcodes>\n''')

entries = []
for i in categories:
    entries.append([])

manualxml = manualroot/'manual.xml'

if not manualxml.exists():
    print(f'\nManual file "{manualxml}" not found', file=sys.stderr)
    print('Use the --manual option to set the path to the manual repository')
    sys.exit(-1)

manual = open(manualxml, 'r')
text = manual.read()
manual.close()

files = list(manualroot.glob('opcodes/*.xml'))
files.extend(manualroot.glob('opcodes/*/*.xml'))
files.extend(manualroot.glob('vectorial/*.xml'))
files.extend(manualroot.glob('utility/*.xml'))

files = list(set(files))
files.sort()

files = [f for f in files if 'topXO.xml' not in str(f)]

headerText = text[:text.find('<book id="index"')]


fixes = {
    'adds.xml': '<synopsis>a <opcodename>+</opcodename> b  (any rate)</synopsis>\n',
    'dollar.xml': '<synopsis><opcodename>$NAME</opcodename></synopsis>\n<para/>',
    'divides.xml': '<synopsis>a <opcodename>/</opcodename> b  (any rate)</synopsis>\n',
    'modulus.xml': '<synopsis>a <opcodename>%</opcodename> b  (any rate)</synopsis>\n',
    'multiplies.xml': '<synopsis>a <opcodename>*</opcodename> b  (any rate)</synopsis>\n',
    'opbitor.xml': '<synopsis>a <opcodename>'+'|</opcodename> b  (bitwise OR)</synopsis>\n',
    'opor.xml': '<synopsis>a <opcodename>'+'||</opcodename> b  (logical OR; not audio-rate)</synopsis>\n',
    'raises.xml': '<synopsis>a <opcodename>^</opcodename> b  (b not audio-rate)</synopsis>\n',
    'subtracts.xml': '<synopsis>a <opcodename>-</opcodename> b (any rate)</synopsis>\n',
    'ifdef.xml':
        '<synopsis><opcodename>#ifndef</opcodename> NAME</synopsis><synopsis>  ...</synopsis>' + 
        '<synopsis><opcodename>#else</opcodename></synopsis><synopsis>  ...</synopsis>' + 
        '<synopsis><opcodename>#end</opcodename></synopsis>\n',
    'define.xml': 
        '<synopsis><opcodename>#define</opcodename> NAME # replacement text #</synopsis>\n' +
        '<synopsis><opcodename>#define</opcodename> NAME(a&apos; b&apos; c&apos;) # replacement text #</synopsis>\n',
    'include.xml': '<synopsis><opcodename>#include</opcodename> &quot;filename&quot;</synopsis>\n',
    'undef.xml': '<synopsis><opcodename>#undef</opcodename> NAME</synopsis>\n',
    '0dbfs.xml': '<synopsis><opcodename>0dbfs</opcodename> = iarg</synopsis>\n'
}

fixes2 = {os.path.join('opcodes', key):entry for key, entry in fixes.items()}

for i, filename in enumerate(files):
    print("filename", filename)
    entry = ''
    source = open(filename)
    entryText = source.read().replace("\xef\xbb\xbf","")
    newfile = headerText + '<book id="index" lang="en">' + entryText + '</book>'
    newfile = newfile.replace("\r", "")
    source.close()
    xmldoc = minidom.parseString(newfile)
    xmldocId = xmldoc.documentElement.getAttribute('id')

    if filename in fixes2:
        entry = fixes2[filename]
    else:
        synopsis = xmldoc.getElementsByTagName('synopsis')
        if not synopsis:
            entry = ''
        else:
            # There can be more than 1 synopsis per file
            for synops in synopsis:
                tmp = synops.toxml()
                if XO:
                    opcodename = tmp[tmp.find('<command>') + 9:tmp.find('</command>')]
                else:
                    opcodename = ""
                tmp = tmp.replace('<command>', '<opcodename>')
                entry += tmp.replace('</command>', '</opcodename>')

    info = xmldoc.getElementsByTagName('refentryinfo')
    if info and entry:
        category = info[0].toxml()
        category = category[21:-23]
    else:
        print(f"no refentryinfo tag for file {filename}")
        category = "Miscellaneous"
        if (entry!=''):
            print(filename + " sent to Miscellaneous")
    desc = xmldoc.getElementsByTagName('refpurpose')
    description = ""
    if (len(desc)!=0 and entry != ''):
        description = desc[0].firstChild.toxml().strip()
    else:
        print(f"no refpurpose tag for file {filename}")
    match = False
    for j, thiscategory in enumerate(categories):
        if (category == thiscategory):
            entries[j].append([entry, description])
            match = True
    if not match:
        print(str(filename) + "---- WARNING! No Category Match!")

for i in range(len(categories)):
    if (len(entries[i])==0):
        print("No entries for category: "+categories[i]+"...Skipping")
        continue
    # quickref.write("<para></para><formalpara>\n")
    quickref.write("<category name=\"" + categories[i] + "\">\n")
    count = 0
    for j in range(len(entries[i])):
        newentry = entries[i].pop(0)
        # entry = entry.replace("&dollar;", "$")
        # entry = entry.replace("&#160;", " ")
        quickref.write("<opcode><desc>" + description)
        quickref.write(newentry[1] + "</desc>")
        quickref.write(newentry[0] + "</opcode>\n")
        count += 1
    quickref.write("</category>\n")
    print(str(count) + " entries in category: " + categories[i])

quickref.write('</opcodes>\n')
quickref.close()
print(entries)
