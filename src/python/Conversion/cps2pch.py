#import event sheet module
import qutesheet
from math import log10

# get all cells by row
cells = qutesheet.cells_by_row
new_data = []

for c in cells:
    if type(c) != str:
        new_val = 117 + (12 *log10(c/440.0)/log10(2))
        c = int(new_val/12) - 1 + ((new_val%12) / 100)
        new_data.append(c)
    else:
        new_data.append(c)


# set output
qutesheet.set_cells_by_row(new_data)
