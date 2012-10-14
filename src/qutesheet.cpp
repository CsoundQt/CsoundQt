/*
	Copyright (C) 2010 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of QuteCsound.

	QuteCsound is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	QuteCsound is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "qutesheet.h"

QuteSheet::QuteSheet(QObject *parent, EventSheet *sheet) :
	QObject(parent)
{
	setSheetPointer(sheet);
}

void QuteSheet::setSheetPointer(EventSheet *sheet)
{
	m_sheet = sheet;
}

QList<QList <QVariant > > QuteSheet::data()
{
	return m_sheet->getData();
}

bool QuteSheet::testConsistency()
{
	//  if (total_rows != data.size()) {
	//        raise InconsistentData(d.num_rows, "Inconsistent number of rows.")
	//  }
	//    if ( total_cols != len(transpose(data))) {
	//        raise InconsistentData(d.num_cols, "Inconsistent number of columns.")
	//    }
}

void QuteSheet::setSheetCellValue(int row, int column, QVariant data)
{
	if (m_sheet != 0) {
		m_sheet->setCell(row,column, data);
	}
}

QList<QVariant> QuteSheet::getValuesByRow(QList<QList <QVariant > > data)
{
	QList<QVariant> cells;
	if (m_sheet != 0) {
		foreach (QList<QVariant> row, data) {
			foreach (QVariant element, row) {
				cells << element;
			}
		}
	}
	return cells;
}

bool QuteSheet::setRows(QList<QList <QVariant > > new_data,
						int new_startRow, int new_startCol,
						int new_numRows, int new_numCols) {
	//! Set the data for the text output organized by row
	if (new_startRow == -1) {
		new_startRow = startRow;
	}
	if (new_startCol == -1) {
		new_startCol = startCol;
	}
	if (new_numRows == -1) {
		new_numRows = numRows;
	}
	if (new_numCols == -1) {
		new_numCols = numCols;
	}
	//      out_text = '__@ ' + str(new_startRow) + ' ' + str(new_startCol)
	//      out_text += ' ' + str(new_numRows) + ' ' + str(new_numCols) + '\n'
	//      out_text += self._rowsToText(new_data)
	//      self._write_out_file(out_text)
}


bool QuteSheet::setValues(QList <QVariant > new_data,
						  int new_startRow, int new_startCol,
						  int new_numRows, int new_numCols)
{
	//!  """Set the data for the text output as a list of individual cells organized by rows"""
	if (new_startRow == -1) {
		new_startRow = startRow;
	}
	if (new_startCol == -1) {
		new_startCol = startCol;
	}
	if (new_numRows == -1) {
		new_numRows = numRows;
	}
	if (new_numCols == -1) {
		new_numCols = numCols;
	}
	//      out_data = []
	//      for i in range(new_numRows):
	//          out_data.append([])
	//          for j in range(new_numCols):
	//              if len(new_data) > 0:
	//                  out_data[i].append(new_data.pop(0))
	//      set_rows(out_data, new_startRow, new_startCol, new_numRows, new_numCols)
}

bool QuteSheet::setText(QString new_data,
						int new_startRow, int new_startCol,
						int new_numRows, int new_numCols)
{
	//! """Set data from a text string, each line is interpreted as a row and each cell must be separated by a space."""
	if (new_startRow == -1) {
		new_startRow = startRow;
	}
	if (new_startCol == -1) {
		new_startCol = startCol;
	}
	if (new_numRows == -1) {
		new_numRows = numRows;
	}
	if (new_numCols == -1) {
		new_numCols = numCols;
	}
	//      out_text = '__@ ' + str(new_startRow) + ' ' + str(new_startCol)
	//      out_text += ' ' + str(new_numRows) + str(new_numCols) + '\n'
	//      out_text += text
	//      _write_out_file(out_text)
}

QList<QList <QVariant> > QuteSheet::sort(QList<QList <QVariant> > vectors, int p_field)
{
	//! Sort vectors by elements in a certain index (third (p2) by default)
	//  qDebug() << "QuteSheet::sort not implemented yet.";
	QList<QList <QVariant> > new_data;
	//      for r in rows:
	//          if len(r) < p_field + 1:
	//              new_data.append(r)
	//          else:
	//              count = 0
	//              while count < len(new_data):
	//                  if type(r[p_field]) != str and r[p_field] <= new_data[count][p_field]:
	//                      break
	//                  count += 1
	//              new_data.insert(count, r)
	return new_data;
}

QList<QList <QVariant > > QuteSheet::transpose(QList<QList <QVariant > > mtx)
{
	QList<QList<QVariant> > newMtx;
	// TODO make this more efficient
	if (mtx.isEmpty()) {
		return newMtx;
	}
	for (int j = 0; j < mtx[0].size(); j++) {
		newMtx << QList<QVariant>();
	}
	for (int i = 0; i <  mtx.size(); i++) {
		for (int j = 0; j < mtx[i].size(); j++) {
			newMtx[j] << mtx[i][j];
		}
	}
	return newMtx;
}

QList<QList <QVariant > > QuteSheet::someCols(QList<QList <QVariant > > data,
											  int row,
											  int num_rows,
											  int col,
											  int num_cols)
{
	QList<QList <QVariant > >rows;
	//          for r in range(row, row + num_rows):
	//              new_row = []
	//              for c in range(col, col + num_cols):
	//                  new_row.append(data[r][c])
	//              rows.append(new_row)
	return rows;
}

QList<QList <QVariant > > QuteSheet::allCols(QList<QList <QVariant > > data,
											 int row,
											 int num_rows)
{
	QList<QList <QVariant > > rows;
	//          for r in range(row, row + num_rows):
	//              rows.append(data[r])
	return rows;
}

QString QuteSheet::rowsToText(QList<QList <QVariant > > data)
{
	QString out_text = "";
	foreach (QList<QVariant> row, data) {
		foreach (QVariant cell, row) {
			out_text += cell.toString() + " ";
		}
		out_text.chop(1);
		out_text += "\n";
	}
	return out_text;
}
