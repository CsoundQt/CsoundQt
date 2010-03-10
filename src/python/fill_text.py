#import event sheet module
import qutesheet
from Tkinter import *

# get all cells by row
cells = qutesheet.cells_by_row
new_data = []

def fill():
    global cells
    print text_var.get()
    for c in cells:
        new_data.append(text_var.get())
     # set output
    qutesheet.set_cells_by_row(new_data)
    # and quit

root = Tk()
root.title("Fill cells with text")
l = Label(root, text="Text")
l.grid(row=0)
text_var = StringVar(root)
textentry = Entry(root, textvariable=text_var)
textentry.grid(row=0, column=1, columnspan = 2)
text_var.set("i") # initial value

button = Button(root, text="Fill", fg="black", command=fill)
button.grid(row=1, column=1)

button2 = Button(root, text="Close", fg="black", command=root.quit)
button2.grid(row=1, column=2)

root.mainloop()

