from Tkinter import *
import qutesheet as q

disp = ""

disp += "first_col = " + str(q.first_col) + "\n"
disp += "first_row = " + str(q.first_row) + "\n"
disp += "num_rows = " + str(q.num_rows) + "\n"
disp += "num_cols = " + str(q.num_cols) + "\n"
disp += "total_rows = " + str(q.total_rows) + "\n"
disp += "total_cols = " + str(q.total_cols) + "\n"

disp += "\n"
disp += "text() =\n"
disp += q.text()
disp += "\n"
disp += "selection_text() =\n"
disp += q.selection_text()

disp += "\n"
disp += "selection_by_rows() =\n"
disp += str(q.selection_by_rows())

disp += "\n"
disp += "selection_full_rows() =\n"
disp += str(q.selection_full_rows())

disp += "\n"
disp += "selection_full_rows_sorted() =\n"
disp += str(q.selection_full_rows_sorted())

disp += "\n"
disp += "all_rows() =\n"
disp += str(q.all_rows())
disp += "\n"
disp += "all_rows_sorted() =\n"
disp += str(q.all_rows_sorted())

disp += "\n"
disp += "selection_by_cols() =\n"
disp += str(q.selection_by_cols())

disp += "\n"
disp += "selection_full_cols() =\n"
disp += str(q.selection_full_cols())

disp += "\n"
disp += "all_cols() =\n"
disp += str(q.all_cols())

disp += "\n"
disp += "cells_selection_by_row() =\n"
disp += str(q.cells_selection_by_row())

disp += "\n"
disp += "cells_all_by_row() =\n"
disp += str(q.cells_all_by_row())

disp += "\n"
disp += "cells_selection_by_col() =\n"
disp += str(q.cells_selection_by_col())

disp += "\n"
disp += "cells_all_by_col() =\n"
disp += str(q.cells_all_by_col())


root = Tk()
root.title("Test API")
text = Text(root)
text.insert(INSERT, disp, "a")
text.pack(fill=BOTH, expand=1)

root.mainloop()
