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

#ifndef QUTESHEET_H
#define QUTESHEET_H

#include <QObject>
#include <QList>
#include <QVariant>

#include "eventsheet.h"

class QuteSheet {
public:
  QuteSheet() {}
  QuteSheet(const QString& first, const QString& last) { _firstName = first; _lastName = last; }

  QString _firstName;
  QString _lastName;

};

class QuteSheetWrapper : public QObject
{

  Q_OBJECT

public slots:
  // add a constructor
  QuteSheet* new_QuteSheet() { return new QuteSheet(); }

  // add a destructor
  void delete_QuteSheet(QuteSheet* o) { delete o; }

  // add access methods
    QString firstName(QuteSheet* o) { return o->_firstName; }

    QString lastName(QuteSheet* o) { return o->_lastName; }

    void setFirstName(QuteSheet* o, const QString& name) { o->_firstName = name; }

    void setLastName(QuteSheet* o, const QString& name) { o->_lastName = name; }
};

//class QuteSheet : public QObject
//{
//  Q_OBJECT
//public:
//  explicit QuteSheet(QObject *parent = 0);
//
//  QString text() { return rows_to_text(data); }
//  QString selection_text() { return rows_to_text(selection_by_rows()); }
//
//  QList<QList <QVariant > > selection_by_rows() { return some_cols(data, first_row, num_rows,
//                                                 first_col, num_cols); }
//  QList<QList <QVariant > > selection_full_rows() { return all_cols(data, first_row, num_rows); }
//  QList<QList <QVariant > > selection_full_rows_sorted()  { return sort_by_col(all_cols(data,
//                                                                                first_row, num_rows)); }
//  QList<QList <QVariant > > all_rows() { return data; }
//  QList<QList <QVariant > > all_rows_sorted() { return sort_by_col(data); }
//
//  QList<QList <QVariant > > selection_by_cols() { return transpose(some_cols(data, first_row, num_rows,
//                                                                   first_col, num_cols)); }
//  QList<QList <QVariant > > selection_full_cols() { return transpose(some_cols(data, 0, total_rows,
//                                                                     first_col, num_cols)); }
//  QList<QList <QVariant > > all_cols() {  return transpose(data); }
//
//  QList<QVariant> cells_selection_by_row() { return get_cells_by_row(selection_by_rows());  }
//  QList<QVariant> cells_all_by_row() { return get_cells_by_row(data); }
//  QList<QVariant> cells_selection_by_col() { return get_cells_by_row(transpose(selection_by_rows())); }
//  QList<QVariant> cells_all_by_col() { return get_cells_by_row(transpose(data)); }
//
//  bool set_rows(QList<QList <QVariant > > new_data,
//                int new_first_row = -1,
//                int new_first_col = -1,
//                int new_num_rows = -1,
//                int new_num_cols = -1) {
//      //! Set the data for the text output organized by row
//    if (new_first_row == -1) {
//      new_first_row = first_row;
//    }
//    if (new_first_col == -1) {
//      new_first_col = first_col;
//    }
//    if (new_num_rows == -1) {
//      new_num_rows = num_rows;
//    }
//    if (new_num_cols == -1) {
//      new_num_cols = num_cols;
//    }
////      out_text = '__@ ' + str(new_first_row) + ' ' + str(new_first_col)
////      out_text += ' ' + str(new_num_rows) + ' ' + str(new_num_cols) + '\n'
////      out_text += self._rows_to_text(new_data)
////      self._write_out_file(out_text)
//    }
//
//  bool set_cols(QList<QList <QVariant > > new_data,
//                 int new_first_row = -1,
//                 int new_first_col = -1,
//                 int new_num_rows = -1,
//                 int new_num_cols = -1)
//  {
//    //! Set the data for the text output organized by columns
//    set_rows(transpose(new_data), new_first_row, new_first_col, new_num_rows, new_num_cols);
//  }
//
//  bool set_cells_by_row(QList<QList <QVariant > > new_data,
//                        int new_first_row = -1,
//                        int new_first_col = -1,
//                        int new_num_rows = -1,
//                        int new_num_cols = -1)
//  {
//     //!  """Set the data for the text output as a list of individual cells organized by rows"""
//    if (new_first_row == -1) {
//      new_first_row = first_row;
//    }
//    if (new_first_col == -1) {
//      new_first_col = first_col;
//    }
//    if (new_num_rows == -1) {
//      new_num_rows = num_rows;
//    }
//    if (new_num_cols == -1) {
//      new_num_cols = num_cols;
//    }
////      out_data = []
////      for i in range(new_num_rows):
////          out_data.append([])
////          for j in range(new_num_cols):
////              if len(new_data) > 0:
////                  out_data[i].append(new_data.pop(0))
////      set_rows(out_data, new_first_row, new_first_col, new_num_rows, new_num_cols)
//  }
//
//  bool set_cells_by_col(QList<QList <QVariant > > new_data,
//                        int new_first_row = -1,
//                        int new_first_col = -1,
//                        int new_num_rows = -1,
//                        int new_num_cols = -1)
//  {
//    //! Set the data for the text output as a list of individual cells organized by columns
////    QDebug() <<  "Warning! set_cells_by_col() not implemented yet!";
//  }
//
//  bool set_text(QList<QList <QVariant > > new_data,
//                int new_first_row = -1,
//                int new_first_col = -1,
//                int new_num_rows = -1,
//                int new_num_cols = -1)
//  {
//      //! """Set data from a text string, each line is interpreted as a row and each cell must be separated by a space."""
//    if (new_first_row == -1) {
//      new_first_row = first_row;
//    }
//    if (new_first_col == -1) {
//      new_first_col = first_col;
//    }
//    if (new_num_rows == -1) {
//      new_num_rows = num_rows;
//    }
//    if (new_num_cols == -1) {
//      new_num_cols = num_cols;
//    }
////      out_text = '__@ ' + str(new_first_row) + ' ' + str(new_first_col)
////      out_text += ' ' + str(new_num_rows) + str(new_num_cols) + '\n'
////      out_text += text
////      _write_out_file(out_text)
//    }
//
//  QList<QList <QVariant> > sort_by_col(QList<QList <QVariant> > rows, int p_field = 2)
//  {
//      //! """Sort rows by start time (p2 by default)"""
//      QList<QList <QVariant> > new_data;
////      for r in rows:
////          if len(r) < p_field + 1:
////              new_data.append(r)
////          else:
////              count = 0
////              while count < len(new_data):
////                  if type(r[p_field]) != str and r[p_field] <= new_data[count][p_field]:
////                      break
////                  count += 1
////              new_data.insert(count, r)
//      return new_data;
//    }
//
//signals:
//
//public slots:
//
//private:
//  QList<QList <QVariant > > data;
//  int first_row;
//  int first_col;
//  int num_rows;
//  int num_cols;
//  int total_rows;
//  int total_cols;
//
//  bool test_consistency()
//  {
//    if (total_rows != data.size()) {
////        raise InconsistentData(d.num_rows, "Inconsistent number of rows.")
//    }
////    if ( total_cols != len(transpose(data))) {
////        raise InconsistentData(d.num_cols, "Inconsistent number of columns.")
////    }
//  }
//
//    QList<QVariant> get_cells_by_row(QList<QList <QVariant > > data)
//    {
//      QList<QVariant> cells;
////          for r in rows:
////              for c in r:
////                  cells.append(c)
//      return cells;
//    }
//
//    QList<QList <QVariant > > transpose(QList<QList <QVariant > > mtx)
//    {
////      return zip(*mtx);
//    }
//
//    QList<QList <QVariant > > some_cols(QList<QList <QVariant > > data,
//                                       int row,
//                                       int num_rows,
//                                       int col,
//                                       int num_cols)
//    {
//      QList<QList <QVariant > >rows;
////          for r in range(row, row + num_rows):
////              new_row = []
////              for c in range(col, col + num_cols):
////                  new_row.append(data[r][c])
////              rows.append(new_row)
//      return rows;
//    }
//
//    QList<QList <QVariant > > all_cols(QList<QList <QVariant > > data,
//                                      int row,
//                                      int num_rows)
//    {
//      QList<QList <QVariant > > rows;
////          for r in range(row, row + num_rows):
////              rows.append(data[r])
//      return rows;
//    }
//
//    QString rows_to_text(QList<QList <QVariant > > data)
//    {
//      QString out_text = "";
////          for row in rows:
////              for cell in row:
////                  if type(cell)==str:
////                      out_text += "" + cell + " "
////                  else:
////                      out_text += str(cell) + " "
////              out_text += '\n'
//      return out_text;
//    }
//
//      bool write_out_file(QString text)
//      {
////          f = open(self.out_filename, "w")
////          f.write(text);
////          f.close()
//      }
//
//};

#endif // QUTESHEET_H
