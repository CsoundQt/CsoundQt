
from Tkinter import *

root = Tk()

w = Label(root, text="Hello, QuteCsound world!")
w.pack(padx=2, pady=2)
l = Label(root, text="If you can see me,\nTkinter is installed and working!")
l.pack(padx=2, pady=2)
button = Button(root, text="OK", fg="black", command=root.quit)
button.pack()

root.mainloop()
