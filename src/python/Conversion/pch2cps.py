#import event sheet module
import qutesheet
from math import log10, modf

# get all cells by row
cells = qutesheet.cells_by_row
new_data = []

for c in cells:
    if type(c) != str:
        new_val = (int(c + 1)*12) + (modf(c%12)[0] * 100)
        c = 440 * pow(2, (new_val - 117)/12)
        new_data.append(c)
    else:
        new_data.append(c)


# set output
qutesheet.set_cells_by_row(new_data)
