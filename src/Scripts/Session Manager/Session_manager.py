# 

import PythonQt.QtGui as pqt
import PythonQt.QtCore as pqtc
import glob, os


try:
    f = load("sessions.txt", 'r')
    lines = f.readLines()
    sessions = [line.split('|') for line in lines]
except:
    sessions = []
    
def store():
    open_files = q.get 
