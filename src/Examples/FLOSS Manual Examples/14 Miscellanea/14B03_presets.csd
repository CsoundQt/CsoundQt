from PythonQt.Qt import *

def again():
    inpdia = QInputDialog()
    myInt = inpdia.getInt(inpdia,"Example 1","How many?")
    if myInt == 1:
        print "If you continue to enter '1'"
        print "I will come back again and again."
        again()
    else:
        print "Thanks - Leaving now."
again()
# example by joachim heintz