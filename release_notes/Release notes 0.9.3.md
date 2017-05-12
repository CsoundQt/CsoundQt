# CsoundQt 0.9.3 released
 

version 0.9.3 introduces some new features, fixes a number of bugs and although not in the final release, the new qt based html5 support is available for testing from branch ***qthtml***.
For instructions how to use the branch see
<https://github.com/CsoundQt/CsoundQt/wiki/Checking-out-develop,-qthtml-or-other-branch>

The source and upcoming binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/0.9.3>.



### New in version 0.9.3:

* Table editor for GEN07 tables     

* Improved and extended Insert/Update CabbageText -  conversion of CsoundQt widgets into < Cabbage> definition.

* Experimental html5 support based on Qt libraries -  no CEF dependency any more, available also on OSX and Linux.


 

### Fixes

* Fixed wrong widgets behaviour if MIDI channel is 0 and widget's CC and Channel are unset.

* Support for building both with older and newer Csound source code (CS_APIVERSION 4)

* Numerous fixes in examples, correction of spelling errors

* Better colour for word completion box

### Plans for further development
* More work and release of html support
* Conversion of CsoundQt widgets to html
* Table editor for GEN7 and bezier curves
* Import of Cabbage files (convert CabbageText to widgets)
* Work with QMLwidget 

