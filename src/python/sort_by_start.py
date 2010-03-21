#import event sheet module
import qutesheet as q

# get full rows for selected cells
rows = q.selection_full_rows_sorted()
new_data = q.sort_by_start(rows)

# set output
qutesheet.set_rows(new_data, -1, 0, -1, qutesheet.total_cols)
