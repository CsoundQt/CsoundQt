#import event sheet module
import qutesheet as q
from math import log10

# get all cells by row
cells = q.cells_selection_by_row()
new_data = []

for c in cells:
    if type(c) != str and c > 0:
        new_val = 69 + (12 * log10(c/440.0)/log10(2.0))
        new_data.append(new_val)
    else:
        new_data.append(c)


# set output
q.set_cells_by_row(new_data)
