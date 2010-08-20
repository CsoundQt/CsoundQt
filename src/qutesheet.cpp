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

QList<QVariant> QuteSheet::get_cells_by_row(QList<QList <QVariant > > data)
{
  QList<QVariant> cells;
  //          for r in rows:
  //              for c in r:
  //                  cells.append(c)
  return cells;
}

QList<QList <QVariant > > QuteSheet::transpose(QList<QList <QVariant > > mtx)
{
  //      return zip(*mtx);
}

QList<QList <QVariant > > QuteSheet::some_cols(QList<QList <QVariant > > data,
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

QList<QList <QVariant > > QuteSheet::all_cols(QList<QList <QVariant > > data,
                                   int row,
                                   int num_rows)
{
  QList<QList <QVariant > > rows;
  //          for r in range(row, row + num_rows):
  //              rows.append(data[r])
  return rows;
}

QString QuteSheet::rows_to_text(QList<QList <QVariant > > data)
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
