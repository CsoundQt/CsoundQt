# 01_Intro.py

# The q object contains all the functions of the Python API
# For CsoundQt. You can run these functions from a Python file
# or from the interactive Python Console.
# The Scripts menu runs Python scripts directly, which allows
# running scripts to operate directly on selected text and other
# features of the currently open document, which could be a csd
# file.

# You can access many actions from the CsoundQt interface, as well
# as interacting with the text editors, or the running Csound
# instances from any of the open documents.

# You can also open documents or switch to them through this API
# For example, this script opens itself in the editor!
# (calling a Script from the Scripts menu runs it but doesn't
# open it in an editor tab)

q.loadDocument("01_Intro.py")
