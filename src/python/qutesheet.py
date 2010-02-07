import sys

try:
    import qutesheet_data
except ImportError:
    print "Can't find Event Sheet Data. Aborting!"
    sys.exit()

# Selection position data
first_row = qutesheet_data.row
first_col = qutesheet_data.col
num_rows = qutesheet_data.num_rows
num_cols = qutesheet_data.num_cols

# Data organized in different ways
rows = qutesheet_data.data
rows_all =  qutesheet_data.data_all

cols = _transpose(rows);
cols_all = _transpose(rows_all);

cells_by_row = _get_cells_by_row(rows)
cells_by_row_all = _get_cells_by_row(rows_all)
cells_by_col = _get_cells_by_row(transpose(rows))
cells_by_col_all = _get_cells_by_row(transpose(rows_all))

# Data return functions

def set_rows(new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
    global first_row, first_col, num_rows, num_cols
    if new_first_row == -1:
        new_first_row = first_row
    if new_first_col == -1:
        new_first_col = first_col
    if new_num_rows == -1:
        new_num_rows = num_rows
    if new_num_cols == -1:
        new_num_cols = num_cols
    out_text = '__@ ' + str(new_first_row) + str(new_first_col)+ str(new_num_rows)+ str(new_num_cols) + '\n'
    for row in new_data:
        for cell in row:
            if type(cell)==str:
                out_text += "'''" + cell + "''' "
            else:
                out_text += str(cell) + " "
        out_text += '\n'
    _write_out_file(out_text)
    sys.exit()

def set_cols(new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
    set_rows(_transpose(new_data), new_first_row, new_first_col, new_num_rows, new_num_cols)

def set_cells_by_row(new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
    print "Warning! set_cells_by_row() not implemented yet!

def set_cells_by_col(new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
    print "Warning! set_cells_by_col() not implemented yet!
    
def set_text(text, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
    '''set_text() receives a text string, each line is interpreted as a row
    and each cell must be separated by a space.'''
    global first_row, first_col, num_rows, num_cols
    if new_first_row == -1:
        new_first_row = first_row
    if new_first_col == -1:
        new_first_col = first_col
    if new_num_rows == -1:
        new_num_rows = num_rows
    if new_num_cols == -1:
        new_num_cols = num_cols
    out_text = '__@ ' + str(new_first_row) + str(new_first_col)+ str(new_num_rows)+ str(new_num_cols) + '\n'
    out_text += text
    _write_out_file(out_text)

# Private functions

_out_filename = "qutesheet_out_data.txt"
_set_out_filename(qutesheet_data.out_filename)

def _set_out_filename(name):
    global _out_filename
    _out_filename = name

def _get_cells_by_row(rows):
    cells = []
    for row in rows:
        for cell in row:
            cells.append(cell)
    return cells

def _transpose(mtx):
    return zip(*mtx)

def _write_out_file(text):
    global _out_filename
    f = open(_out_filename, "w")
    f.write(text);
    f.close()

if __name__ == '__main__':
    print "qutesheet python module. Part of QuteCsound."
