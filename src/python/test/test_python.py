import sys

text =  "Python Information\n"
text += "executable: " + sys.executable + "\n"
text += "version: " + sys.version + "\n"
text += "prefix: " + sys.prefix + "\n"
text += "exec_prefix: " + sys.exec_prefix + "\n"

from Tkinter import *

root = Tk()

w = Label(root, text=text)
w.pack()
button = Button(root, text="OK", fg="black", command=root.quit)
button.pack()

root.mainloop()
