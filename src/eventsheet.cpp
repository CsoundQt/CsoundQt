/*
    Copyright (C) 2009 Andres Cabrera
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

#include "eventsheet.h"
#include "onevaluedialog.h"

#include <QMenu>
#include <QContextMenuEvent>
// Only for debug
#include <QtCore>

EventSheet::EventSheet(QWidget *parent) : QTableWidget(parent)
{
  this->setRowCount(10);
  this->setColumnCount(6);
  columnNames << tr("Event") << "p1 (instr)" << "p2 (start)" << "p3 (dur)" << "p4" << "p5";
  this->setHorizontalHeaderLabels(columnNames);
  this->setColumnWidth(0, 50);
  this->setColumnWidth(1, 65);
  this->setColumnWidth(2, 65);
  this->setColumnWidth(3, 65);

  createActions();
}

EventSheet::~EventSheet()
{
}

QString EventSheet::getPlainText(bool scaleTempo)
{
  QString t = "";
  for (int i = 0; i < this->rowCount(); i++) {
    t += getLine(0, scaleTempo) + "\n";  // Don't scale by default
  }
  return t;
}

QString EventSheet::getLine(int number, bool scaleTempo)
{
  QString line = "";
  for (int i = 0; i < this->columnCount(); i++) {
    QTableWidgetItem * item = this->item(number, i);
    if (item != 0) {
      if (scaleTempo && (i == 2 || i == 3) ) { // Scale tempo only for pfields p2 and p3
        bool ok = false;
        double value = item->data(Qt::DisplayRole).toDouble(&ok);
        if (ok) {
          value = value * (60.0/tempo);
          line += QString::number(value, 'f', 8);;
        }
        else {
          line += item->data(Qt::DisplayRole).toString();
        }
      }
      else {
        line += item->data(Qt::DisplayRole).toString();
      }
      // Then add white space separation
      QString space = item->data(Qt::UserRole).toString();
      if (!space.isEmpty()) { // Separataion is stored in UserRole of items
        line += space;
      }
      else {
        line += " ";
      }
    }
  }
  return line;
}

double EventSheet::getTempo()
{
  return tempo;
}

void EventSheet::setFromText(QString text)
{
 // Separataion is stored in UserRole of items
  // remember to treat comments and formulas properly
}

void EventSheet::sendEvents()
{
  QModelIndexList list = this->selectedIndexes();
  QList<int> selectedRows;
  for (int i = 0; i < list.size(); i++) {
    if (!selectedRows.contains(list[i].row()) ) {
      selectedRows.append(list[i].row());
    }
  }
  for (int i = 0; i < selectedRows.size(); i++) {
    emit sendEvent(getLine(selectedRows[i], true));  // With tempo scaling
  }
}

void EventSheet::setTempo(double value)
{
  qDebug() << "EventSheet::setTempo " << value;
  tempo = value;
}

void EventSheet::loopEvents() {

}

void EventSheet::subtract()
{
  OneValueDialog d(this);
  d.exec();
  if (d.result() == QDialog::Accepted) {
    this->add(- d.value());
  }
}

void EventSheet::add()
{
  OneValueDialog d(this);
  d.exec();
  if (d.result() == QDialog::Accepted) {
    this->add(d.value());
  }
}

void EventSheet::multiply()
{
  OneValueDialog d(this);
  d.exec();
  if (d.result() == QDialog::Accepted) {
    this->multiply(d.value());
  }
}

void EventSheet::divide()
{
  OneValueDialog d(this);
  d.exec();
  if (d.result() == QDialog::Accepted) {
    this->divide(d.value());
  }
}

void EventSheet::randomize()
{

}

void EventSheet::reverse()
{
  QModelIndexList list = this->selectedIndexes();
  if (list.size() < 2)
    return;
  QList<int> selectedColumns;
  for (int i = 0; i < list.size(); i++) {
    if (!selectedColumns.contains(list[i].column()) ) {
      selectedColumns.append(list[i].column());
    }
  }
  int numRows = list.size() / selectedColumns.size();
  if (numRows < 2)
    return;

  QVector<QVariant> elements;
  elements.resize(numRows);
  for (int i = 0; i < selectedColumns.size(); i++) {
    for (int j = 0; j < numRows; j++) {
      QTableWidgetItem * item = this->item(list[(i*numRows) + j].row(), list[(i*numRows) + j].column());
      if (item != 0) {
        elements[numRows - j - 1] = item->data(Qt::DisplayRole);
      }
      else {
        elements[numRows - j - 1] = QVariant();
      }
    }
    for (int j = 0; j < numRows; j++) {
      QTableWidgetItem * item = this->item(list[(i*numRows) + j].row(), list[(i*numRows) + j].column());
      if (item != 0) {
        item->setData(Qt::DisplayRole, elements[j] );
      }
      else {
        QTableWidgetItem *item = new QTableWidgetItem();
        item->setData(Qt::DisplayRole, elements[j] );
        this->setItem(list[(i*numRows) + j].row(), list[(i*numRows) + j].column(), item );
      }

    }
  }
}

void EventSheet::shuffle(int iterations)
{

}

void EventSheet::mirror()
{

}

void EventSheet::rotate(int amount)
{

}

void EventSheet::fill(double start, double end, double slope)
{

}

void EventSheet::insertColumnHere()
{

}

void EventSheet::insertRowHere()
{

}

void EventSheet::appendColumn()
{
  this->insertColumn(this->columnCount());
  columnNames << QString("p%1").arg(this->columnCount() - 1);
  this->setHorizontalHeaderLabels(columnNames);
}

void EventSheet::appendRow()
{
  this->insertRow(this->rowCount());

}

void EventSheet::deleteColumn()
{
  // TODO: remove multiple columns
  this->removeColumn(this->columnCount() - 1);
  columnNames.takeLast();
}

void EventSheet::deleteRow()
{
  // TODO: remove multiple rows
  this->removeRow(this->currentRow());

}

void EventSheet::contextMenuEvent (QContextMenuEvent * event)
{
//  qDebug() << "EventSheet::contextMenuEvent";

  QMenu menu;
  menu.addAction(sendEventsAct);
  menu.addAction(loopEventsAct);
  menu.addAction(stopAllEventsAct);
  menu.addSeparator();
  menu.addAction(subtractAct);
  menu.addAction(addAct);
  menu.addAction(multiplyAct);
  menu.addAction(divideAct);
  menu.addAction(randomizeAct);
  menu.addAction(reverseAct);
  menu.addAction(shuffleAct);
  menu.addAction(mirrorAct);
  menu.addAction(rotateAct);
  menu.addAction(fillAct);
  menu.addSeparator();
  menu.addAction(insertColumnHereAct);
  menu.addAction(insertRowHereAct);
  menu.addAction(appendColumnAct);
  menu.addAction(appendRowAct);
  menu.addAction(deleteColumnAct);
  menu.addAction(deleteRowAct);
  menu.exec(event->globalPos());
}

void EventSheet::add(double value)
{
  QModelIndexList list = this->selectedIndexes();
  for (int i = 0; i < list.size(); i++) {
    QTableWidgetItem * item = this->item(list[i].row(), list[i].column());
    if (item != 0 && item->data(Qt::DisplayRole).canConvert(QVariant::Double)) {
      bool ok = false;
      double n = item->data(Qt::DisplayRole).toDouble(&ok);
      if (ok) {
        item->setData(Qt::DisplayRole,
                      QVariant(n + value));
      }
    }
  }
}

void EventSheet::multiply(double value)
{
  QModelIndexList list = this->selectedIndexes();
  for (int i = 0; i < list.size(); i++) {
    QTableWidgetItem * item = this->item(list[i].row(), list[i].column());
    if (item != 0 && item->data(Qt::DisplayRole).canConvert(QVariant::Double)) {
      bool ok = false;
      double n = item->data(Qt::DisplayRole).toDouble(&ok);
      if (ok) {
        item->setData(Qt::DisplayRole,
                      QVariant(n * value));
      }
    }
  }
}

void EventSheet::divide(double value)
{
  QModelIndexList list = this->selectedIndexes();
  for (int i = 0; i < list.size(); i++) {
    QTableWidgetItem * item = this->item(list[i].row(), list[i].column());
    if (item != 0 && item->data(Qt::DisplayRole).canConvert(QVariant::Double)) {
      bool ok = false;
      double n = item->data(Qt::DisplayRole).toDouble(&ok);
      if (ok) {
        item->setData(Qt::DisplayRole,
                      QVariant(n / value));
      }
    }
  }
}

void EventSheet::randomize(double min, double max, int dist)
{

}

void EventSheet::createActions()
{
  sendEventsAct = new QAction(/*QIcon(":/a.png"),*/ tr("&SendEvents"), this);
  sendEventsAct->setStatusTip(tr("Send Events to Csound"));
  sendEventsAct->setIconText(tr("Send Events"));
  sendEventsAct->setShortcut(QKeySequence(tr("Alt+C")));
  connect(sendEventsAct, SIGNAL(triggered()), this, SLOT(sendEvents()));

  loopEventsAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Loop Events"), this);
  loopEventsAct->setStatusTip(tr("Loop Events to Csound"));
  loopEventsAct->setIconText(tr("Loop Events"));
  connect(loopEventsAct, SIGNAL(triggered()), this, SLOT(loopEvents()));

  stopAllEventsAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Stop Events"), this);
  stopAllEventsAct->setStatusTip(tr("Stop all running and pending events"));
  stopAllEventsAct->setIconText(tr("Stop Events"));
  sendEventsAct->setShortcut(QKeySequence(tr("Alt+Q")));
  connect(stopAllEventsAct, SIGNAL(triggered()), this, SLOT(stopAllEvents()));

  subtractAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Subtract"), this);
  subtractAct->setStatusTip(tr("Subtract a value from the selected cells"));
  subtractAct->setIconText(tr("Subtract"));
  connect(subtractAct, SIGNAL(triggered()), this, SLOT(subtract()));

  addAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Add"), this);
  addAct->setStatusTip(tr("Add a value to the selected cells"));
  addAct->setIconText(tr("Add"));
  connect(addAct, SIGNAL(triggered()), this, SLOT(add()));

  multiplyAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Multiply"), this);
  multiplyAct->setStatusTip(tr("Multiply the selected cells by a value"));
  multiplyAct->setIconText(tr("Multiply"));
  connect(multiplyAct, SIGNAL(triggered()), this, SLOT(multiply()));

  divideAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Divide"), this);
  divideAct->setStatusTip(tr("Divide the selected cells by a value"));
  divideAct->setIconText(tr("Divide"));
  connect(divideAct, SIGNAL(triggered()), this, SLOT(divide()));

  randomizeAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Randomize"), this);
  randomizeAct->setStatusTip(tr("Randomize the selected cells"));
  randomizeAct->setIconText(tr("Randomize"));
  connect(randomizeAct, SIGNAL(triggered()), this, SLOT(randomize()));

  reverseAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Reverse"), this);
  reverseAct->setStatusTip(tr("Reverse the selected cells by column"));
  reverseAct->setIconText(tr("Reverse"));
  connect(reverseAct, SIGNAL(triggered()), this, SLOT(reverse()));

  shuffleAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Shuffle"), this);
  shuffleAct->setStatusTip(tr("Shuffle the selected cells"));
  shuffleAct->setIconText(tr("Shuffle"));
  connect(shuffleAct, SIGNAL(triggered()), this, SLOT(shuffle()));

  mirrorAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Mirror"), this);
  mirrorAct->setStatusTip(tr("Mirror the selected cells"));
  mirrorAct->setIconText(tr("Mirror"));
  connect(mirrorAct, SIGNAL(triggered()), this, SLOT(mirror()));

  rotateAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Rotate"), this);
  rotateAct->setStatusTip(tr("Rotate the selected cells"));
  rotateAct->setIconText(tr("Rotate"));
  connect(rotateAct, SIGNAL(triggered()), this, SLOT(rotate()));

  fillAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Fill Cells"), this);
  fillAct->setStatusTip(tr("Fill selected cells"));
  fillAct->setIconText(tr("Fill"));
  connect(fillAct, SIGNAL(triggered()), this, SLOT(fill()));


  insertColumnHereAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Insert Column"), this);
  insertColumnHereAct->setStatusTip(tr("Insert a column at the current position"));
  insertColumnHereAct->setIconText(tr("Insert Column"));
  connect(insertColumnHereAct, SIGNAL(triggered()), this, SLOT(insertColumn()));

  insertRowHereAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Insert Row"), this);
  insertRowHereAct->setStatusTip(tr("Insert a row at the current position"));
  insertRowHereAct->setIconText(tr("Insert Row"));
  connect(insertRowHereAct, SIGNAL(triggered()), this, SLOT(insertRow()));


  appendColumnAct = new QAction(/*QIcon(":/a.png"),*/ tr("Append Column"), this);
  appendColumnAct->setStatusTip(tr("Append a column to the sheet"));
  appendColumnAct->setIconText(tr("Append Column"));
  connect(appendColumnAct, SIGNAL(triggered()), this, SLOT(appendColumn()));

  appendRowAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Append Row"), this);
  appendRowAct->setStatusTip(tr("Append a row to the sheet"));
  appendRowAct->setIconText(tr("Append Row"));
  connect(appendRowAct, SIGNAL(triggered()), this, SLOT(appendRow()));

  deleteColumnAct = new QAction(/*QIcon(":/a.png"),*/ tr("Delete Last Column"), this);
  deleteColumnAct->setStatusTip(tr("Delete Last Column"));
  deleteColumnAct->setIconText(tr("Delete Last Column"));
  connect(deleteColumnAct, SIGNAL(triggered()), this, SLOT(deleteColumn()));

  deleteRowAct = new QAction(/*QIcon(":/a.png"),*/ tr("Delete Current Row"), this);
  deleteRowAct->setStatusTip(tr("Delete Row"));
  deleteRowAct->setIconText(tr("Delete Row"));
  connect(deleteRowAct, SIGNAL(triggered()), this, SLOT(deleteRow()));
}
