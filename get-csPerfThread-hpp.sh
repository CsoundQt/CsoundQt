#!/bin/bash

# workaround to download csPerfThread.cpp that is not bundled in in Csound 6.18.0

curl -o src/csPerfThread.hpp https://raw.githubusercontent.com/csound/csound/master/interfaces/csPerfThread.hpp 
