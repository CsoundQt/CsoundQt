#!/bin/bash

# workaround to download csPerfThread.cpp that is not bundled in in Csound 6.18.0

curl -o csPerfThread.hpp https://raw.githubusercontent.com/csound/csound/master/interfaces/csPerfThread.hpp 

#on MacOS:
#sudo mv csPerfThread.hpp /Library/Frameworks/CsoundLib64.framework/Versions/Current/Headers
