# -*- coding: utf-8 -*-
# This file defines the QuteSheet API
# It is part of QuteCsound and is licensed under the GPLv3 or LGPLv2
# Please see QuteCsound for more information
# qutecsound.sourceforge.net

majorversion = 1
minorversion = 0
subversion   = 0

version_text = str(majorversion) + '.' + str(minorversion) + '.' + str(subversion)

class InconsistentData(Exception):
    """Exception raised for errors in the input.

    Attributes:
        expr -- input expression in which the error occurred
        msg  -- explanation of the error
    """

    def __init__(self, expr, msg):
        self.expr = expr
        self.msg = msg

class QuteSheet:
    """The QuteSheet API"""
    def __init__(self, qutesheet_data):
        self.data = qutesheet_data
        cons = self._test_consistency()
        self.out_filename = qutesheet_data.out_filename
        self.first_row = qutesheet_data.row
        self.first_col = qutesheet_data.col
        self.num_rows = qutesheet_data.num_rows
        self.num_cols = qutesheet_data.num_cols
        self.total_rows = qutesheet_data.total_rows
        self.total_cols = qutesheet_data.total_cols
        
    def text(self):
        return self._rows_to_text(self.data.data_all);
    
    def selection_text(self):
        return self._rows_to_text(self.selection_by_rows());
    
    # By rows  
    def selection_by_rows(self):
        return self._some_cols(self.data.data_all, self.first_row, self.num_rows,
            self.first_col, self.num_cols)
    
    def selection_full_rows(self):
        return self._all_cols(self.data.data_all, self.first_row, self.num_rows)
    
    def selection_full_rows_sorted(self):
        return self.sort_by_start(self._all_cols(self.data.data_all, 
            self.first_row, self.num_rows))
    
    def all_rows(self):
        return self.data.data_all
    
    def all_rows_sorted(self):
        return self.sort_by_start(self.data.data_all)
    
    # By Columns   
    def selection_by_cols(self):
        return self._transpose(self._some_cols(self.data.data_all, self.first_row, self.num_rows,
            self.first_col, self.num_cols))
    
    def selection_full_cols(self):
        return self._transpose(self._some_cols(self.data.data_all, 0, self.total_rows,
            self.first_col, self.num_cols))
    
    def all_cols(self):
        return self._transpose(self.data.data_all);
    
    # By Cells
    def cells_selection_by_row(self):
        return self._get_cells_by_row(self.selection_by_rows());
    
    def cells_all_by_row(self):
        return self._get_cells_by_row(self.data.data_all);
    
    def cells_selection_by_col(self):
        return self._get_cells_by_row(self._transpose(self.selection_by_rows()));
    
    def cells_all_by_col(self):
        return self._get_cells_by_row(self._transpose(self.data.data_all));

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
        out_text += self._rows_to_text(new_data)
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
        return new_data

    # ----------------
    # internal functions
    
    def _test_consistency(self):
        d = self.data
        if (d.total_rows != len(d.data_all)):
            raise InconsistentData(d.num_rows, "Inconsistent number of rows.")
        if (d.total_cols != len(self._transpose(d.data_all))):
            raise InconsistentData(d.num_cols, "Inconsistent number of columns.")

    def _get_cells_by_row(self, rows):
        cells = []
        for r in rows:
            for c in r:
                cells.append(c)
        return cells
    
    def _transpose(self, mtx):
        return zip(*mtx)
    
    def _some_cols(self, data, row, num_rows, col, num_cols):
        rows = []
        for r in range(row, row + num_rows):
            new_row = []
            for c in range(col, col + num_cols):
                new_row.append(data[r][c])
            rows.append(new_row)
        return rows
    
    def _all_cols(self, data, row, num_rows):
        rows = []
        for r in range(row, row + num_rows):
            rows.append(data[r])
        return rows
    
    def _rows_to_text(self, rows):
        out_text = ""
        for row in rows:
            for cell in row:
                if type(cell)==str:
                    out_text += "" + cell + " "
                else:
                    out_text += str(cell) + " "
            out_text += '\n'
        return out_text
    
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
# Data properties

first_col = _defObj.first_col
first_row = _defObj.first_row
num_rows = _defObj.num_rows
num_cols = _defObj.num_cols
total_rows = _defObj.total_rows
total_cols = _defObj.total_cols

def text():
    """Get the text of all data"""
    return _defObj.text()

def selection_text():
    """Get the selected data text"""
    return _defObj.selection_text()

# Data by rows
def selection_by_rows():
    """Get the selected data grouped in rows"""
    return _defObj.selection_by_rows()

def selection_full_rows():
    """Get the selected data grouped in rows containing all (even non selected) columns"""
    return _defObj.selection_full_rows()

def selection_full_rows_sorted():
    """Get the selected data grouped in rows containing all (even non selected) columns, sorted
according to the third element (p2)"""
    return _defObj.selection_full_rows_sorted()

def all_rows():
    """Get all the data grouped in rows"""
    return _defObj.all_rows()

def all_rows_sorted():
    """Get all the data grouped in rows, sorted according to the third element (p2)"""
    return _defObj.all_rows_sorted()

# By Columns   
def selection_by_cols():
    """Get the selected data grouped in columns"""
    return _defObj.selection_by_cols()

def selection_full_cols():
    """Get the selected data grouped in columns, containing all rows even non-selected ones"""
    return _defObj.selection_full_cols()

def all_cols():
    """Get all the data grouped in columns"""
    return _defObj.all_cols()

# By Cells
def cells_selection_by_row():
    """Get the selection as separate elements, read row by row"""
    return _defObj.cells_selection_by_row()

def cells_all_by_row():
    """Get all the data as separate elements, read row by row"""
    return _defObj.cells_all_by_row()

def cells_selection_by_col():
    """Get the selection as separate elements, read column by column"""
    return _defObj.cells_selection_by_col()

def cells_all_by_col():
    """Get all the data as separate elements, read column by column"""
    return _defObj.cells_all_by_col()
    
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
