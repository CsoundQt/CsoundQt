#import event sheet module
import qutesheet

# get all cells by row
cells = qutesheet.cells_by_row
new_data = []

for c in cells:
    if type(c) != str:
        new_data.append(c)
    else:
        new_data.append(c)


# set output
qutesheet.set_cells_by_row(new_data)
