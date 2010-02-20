import sys
from Tkinter import *

root = Tk()

t =  "Python Information\n"
t += "executable: " + sys.executable + "\n"
t += "version: " + sys.version + "\n"
t += "prefix: " + sys.prefix + "\n"
t += "exec_prefix: " + sys.exec_prefix + "\n"

w = Label(root, text=t)
w.pack()
button = Button(root, text="OK", fg="black", command=root.quit)
button.pack()

root.mainloop()
