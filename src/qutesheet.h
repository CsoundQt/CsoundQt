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

class QuteCells {

};

class QuteSheet : public QObject
{
  Q_OBJECT
  public:
    QuteSheet(QObject *parent = 0, EventSheet *sheet  = 0);

    void setSheetPointer(EventSheet *sheet);

  public slots:
    // add a constructor
    QuteSheet* new_QuteSheet() { return new QuteSheet(); }

    // add a destructor
    void delete_QuteSheet(QuteSheet* o) { delete o; }

    QString text(QuteSheet* o) { return o->rowsToText(o->data()); }
    QList<QList <QVariant > > allRows(QuteSheet* o) { return o->data(); }

    QString selectionText(QuteSheet* o) { return o->rowsToText(o->selectionRows(o)); }
    QList<QVariant> selection(QuteSheet* o) { return o->getValuesByRow(selectionRows(o));  }
    QList<QList <QVariant > > selectionRows(QuteSheet* o) { return o->someCols(o->data(), startRow, numRows,
                                                                                 startCol, numCols); }
    QList<QList <QVariant > > selectionFullRows(QuteSheet* o) { return o->allCols(o->data(), startRow, numRows); }

    void setCellValue(QuteSheet* o, int row, int column, QVariant data) {return o->setSheetCellValue(row, column, data); }
    bool setRows(QList<QList <QVariant > > new_data,
                  int new_startRow = -1,
                  int new_startCol = -1,
                  int new_numRows = -1,
                  int new_numCols = -1);

    bool setValues(QList <QVariant > new_data,
                   int new_startRow = -1,
                   int new_startCol = -1,
                   int new_numRows = -1,
                   int new_numCols = -1);

    bool setText(QString text,
                 int new_startRow = -1,
                 int new_startCol = -1,
                 int new_numRows = -1,
                 int new_numCols = -1);

    // Helper functions
    QList<QList <QVariant> > sort(QList<QList <QVariant> > vectors, int p_field = 2);
    QList<QList <QVariant > > transpose(QList<QList <QVariant > > mtx);
    QString rowsToText(QList<QList <QVariant > > data);

  private:

    QList<QList <QVariant > > data();
    bool testConsistency();

    void setSheetCellValue(int row, int column, QVariant data);
    QList<QVariant> getValuesByRow(QList<QList <QVariant > > data);
    QList<QList <QVariant > > someCols(QList<QList <QVariant > > data,
                                       int row,
                                       int numRows,
                                       int col,
                                       int numCols);

    QList<QList <QVariant > > allCols(QList<QList <QVariant > > data,
                                      int row,
                                      int numRows);

    bool writeOutFile(QString text);

    EventSheet * m_sheet;
    int startRow;
    int startCol;
    int numRows;
    int numCols;
    int totalRows;
    int totalCols;
};

#endif // QUTESHEET_H
