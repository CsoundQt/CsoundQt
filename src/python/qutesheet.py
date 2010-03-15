# -*- coding: utf-8 -*-
# This file defines the QuteSheet API
# It is part of QuteCsound and is licensed under the GPLv3 or LGPLv2
# Please see QuteCsound for more information
# qutecsound.sourceforge.net

version = "1.0.0"
majorversion = 1
minorversion = 0
subversion   = 0

class QuteSheet:
    """The QuteSheet API"""
    def __init__(self, qutesheet_data):
        self.out_filename = qutesheet_data.out_filename
        self.first_row = qutesheet_data.row
        self.first_col = qutesheet_data.col
        self.num_rows = qutesheet_data.num_rows
        self.num_cols = qutesheet_data.num_cols
        self.total_rows = qutesheet_data.total_rows
        self.total_cols = qutesheet_data.total_cols
        
        # Data organized in different ways
        self.rows_selection = qutesheet_data.data
        self.rows = self._all_cols(qutesheet_data.data_all, self.first_row, self.num_rows)
        self.rows_sorted = self.sort_by_start(self._all_cols(qutesheet_data.data_all, self.first_row, self.num_rows))
        self.rows_all =  qutesheet_data.data_all
        self.rows_all_sorted = self.sort_by_start(qutesheet_data.data_all)
        
        #cols_selection = _transpose(qutesheet_data.data);
        self.cols = self._transpose(self._all_cols(self._transpose(qutesheet_data.data_all), self.first_col, self.num_cols))
        self.cols_all = self._transpose(self.rows_all);
        
        self.cells_by_row = self._get_cells_by_row(self.rows_selection)
        self.cells_by_row_all = self._get_cells_by_row(self.rows_all)
        #cells_by_col = _get_cells_by_row(cols_selection)
        self.cells_by_col_all = self._get_cells_by_row(self.cols_all)
    
    # ----------------
    # Data setting functions (for data output from script)
    
    def set_rows(self, new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
        """Set the data for the text output organized by rows"""
        if new_first_row == -1:
            new_first_row = self.first_row
        if new_first_col == -1:
            new_first_col = self.first_col
        if new_num_rows == -1:
            new_num_rows = self.num_rows
        if new_num_cols == -1:
            new_num_cols = self.num_cols
        out_text = '__@ ' + str(new_first_row) + ' ' + str(new_first_col) 
        out_text += ' ' + str(new_num_rows) + ' ' + str(new_num_cols) + '\n'
        for row in new_data:
            for cell in row:
                if type(cell)==str:
                    out_text += "" + cell + " "
                else:
                    out_text += str(cell) + " "
            out_text += '\n'
        self._write_out_file(out_text)
        sys.exit()
    
    def set_cols(self, new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
        """Set the data for the text output organized by columns"""
        self.set_rows(self._transpose(new_data), new_first_row, new_first_col, new_num_rows, new_num_cols)
    
    def set_cells_by_row(self, new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
        """Set the data for the text output as a list of individual cells organized by rows"""
        if new_first_row == -1:
            new_first_row = self.first_row
        if new_first_col == -1:
            new_first_col = self.first_col
        if new_num_rows == -1:
            new_num_rows = self.num_rows
        if new_num_cols == -1:
            new_num_cols = self.num_cols
        out_data = []
        for i in range(new_num_rows):
            out_data.append([])
            for j in range(new_num_cols):
                if len(new_data) > 0:
                    out_data[i].append(new_data.pop(0))
        set_rows(out_data, new_first_row, new_first_col, new_num_rows, new_num_cols)
    
    def set_cells_by_col(self, new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
        """Set the data for the text output as a list of individual cells organized by columns"""
        print "Warning! set_cells_by_col() not implemented yet!"
        
    def set_text(self, text, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
        """Set data from a text string, each line is interpreted as a row and each cell must be separated by a space."""
        if new_first_row == -1:
            new_first_row = self.first_row
        if new_first_col == -1:
            new_first_col = self.first_col
        if new_num_rows == -1:
            new_num_rows = self.num_rows
        if new_num_cols == -1:
            new_num_cols = self.num_cols
        out_text = '__@ ' + str(new_first_row) + ' ' + str(new_first_col) 
        out_text += ' ' + str(new_num_rows) + str(new_num_cols) + '\n'
        out_text += text
        _write_out_file(out_text)
    
    # ----------------
    # Utility functions

    def sort_by_start(self, rows, p_field = 2):
        """Sort rows by start time (p2 by default)"""
        new_data = []
        for r in rows:
            if len(r) < p_field + 1:
                new_data.append(r)
            else:
                count = 0
                while count < len(new_data):
                    if type(r[p_field]) != str and r[p_field] <= new_data[count][p_field]:
                        break
                    count += 1
                new_data.insert(count, r)

    # ----------------
    # internal functions

    def _get_cells_by_row(self, rows):
        cells = []
        for r in rows:
            for c in r:
                cells.append(c)
        return cells
    
    def _transpose(self, mtx):
        return zip(*mtx)
    
    def _all_cols(self, data, row, num_rows):
        rows = []
        for r in range(row, row + num_rows):
            rows.append(data[r])
        return rows
    
    def _write_out_file(self, text):
        f = open(self.out_filename, "w")
        f.write(text);
        f.close()

#-----------------------------------------------------------------------------


import sys

try:
    import qutesheet_data
except ImportError:
    print "QuteSheet: Can't find Event Sheet Data. Aborting!"
    sys.exit()

_defObj = QuteSheet(qutesheet_data)
#_defObj.set_out_filename(qutesheet_data.out_filename)


# ----------------
# Data gathering functions

first_col = _defObj.first_col
num_rows = _defObj.num_rows
num_cols = _defObj.num_cols
total_rows = _defObj.total_rows
total_cols = _defObj.total_cols

# Data organized in different ways
rows_selection = _defObj.rows_selection
rows = _defObj.rows
rows_sorted = _defObj.rows_sorted
rows_all =  _defObj.rows_all
rows_all_sorted = _defObj.rows_all_sorted

#cols_selection = _transpose(qutesheet_data.data);
cols = _defObj.cols
cols_all = _defObj.cols_all

cells_by_row = _defObj.cells_by_row
cells_by_row_all = _defObj.cells_by_row_all
#cells_by_col = _defObj.
cells_by_col_all = _defObj.cells_by_col_all
    
# ----------------
# Data setting functions (for data output from script)
    
def set_rows(new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
    """Set the data for the text output organized by rows"""
    _defObj.set_rows(new_data, new_first_row, new_first_col, new_num_rows, new_num_cols)
    
def set_cols(new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
    """Set the data for the text output organized by columns"""
    _defObj.set_cols(new_data, new_first_row, new_first_col, new_num_rows, new_num_cols)
    
def set_cells_by_row(new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
    """Set the data for the text output as a list of individual cells organized by rows"""
    _defObj.set_cells_by_row(new_data, new_first_row, new_first_col, new_num_rows, new_num_cols)
    
def set_cells_by_col(new_data, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
    """Set the data for the text output as a list of individual cells organized by columns"""
    _defObj.set_cells_by_col(new_data, new_first_row, new_first_col, new_num_rows, new_num_cols)
        
def set_text(text, new_first_row = -1, new_first_col = -1, new_num_rows = -1, new_num_cols = -1):
    """Set data from a text string, each line is interpreted as a row and each cell must be separated by a space."""
    _defObj.set_text(text, new_first_row, new_first_col, new_num_rows, new_num_cols)
    
# ----------------
# Utility functions

def sort_by_start(rows, p_field = 2):
    _defObj.sort_by_start(rows, p_field)

if __name__ == '__main__':
    print "QuteSheet python module. Part of QuteCsound."
