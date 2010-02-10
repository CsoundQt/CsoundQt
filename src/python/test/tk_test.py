#import event sheet module
import qutesheet

from Tkinter import *

root = Tk()

w = Label(root, text="Hello, world!")
w.pack()
button = Button(root, text="OK", fg="black", command=root.quit)
button.pack()

root.mainloop()
