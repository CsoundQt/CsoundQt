#import event sheet module
import qutesheet

# get full rows for selected cells
rows = qutesheet.rows
new_data = []

for r in rows:
    if len(r) < 3:
        new_data.append(r)
    else:
        count = 0
        while count < len(new_data):
            if type(r[2]) != str and r[2] <= new_data[count][2]:
                break
            count += 1
        new_data.insert(count, r)

# set output
qutesheet.set_rows(new_data, -1, 0, -1, qutesheet.total_cols)
