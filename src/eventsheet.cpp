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

#include <QMenu>
#include <QContextMenuEvent>
#include <QLabel>
#include <QVBoxLayout>
#include <QLineEdit>
#include <QDialog>
#include <QDoubleSpinBox>

// For rand() function
#include <cstdlib>
// Only for debug
#include <QtCore>

class OneValueDialog: public QDialog
{
  public:
  OneValueDialog(QWidget *parent, QString label, double defaultValue = 0.0):
      QDialog(parent)
  {
    l = new QVBoxLayout(this);
    lab= new QLabel(label, this);
    box = new QDoubleSpinBox(this);
    box->setRange(-999999, 999999);
    box->setDecimals(8);
    box->setValue(defaultValue);
    box->selectAll();
    l->addWidget(lab);
    l->addWidget(box);
    connect(box, SIGNAL(editingFinished()), this, SLOT(accept ()) );
  }

  double value() { return box->value();}

  QVBoxLayout *l;
  QLabel *lab;
  QDoubleSpinBox *box;
};

class ThreeValueDialog: public QDialog
{
  public:
  ThreeValueDialog(QWidget *parent, QStringList labels, QVector<double> defaultValues):
      QDialog(parent)
  {
    l = new QVBoxLayout(this);
    lab1= new QLabel(labels[0], this);
    box1 = new QDoubleSpinBox(this);
    box1->setRange(-999999, 999999);
    box1->setDecimals(8);
    box1->setValue(defaultValues[0]);
    box1->selectAll();
    lab2= new QLabel(labels[1], this);
    box2 = new QDoubleSpinBox(this);
    box2->setRange(-999999, 999999);
    box2->setDecimals(8);
    box2->setValue(defaultValues[1]);
    l->addWidget(lab1);
    l->addWidget(box1);
    l->addWidget(lab2);
    l->addWidget(box2);
    if (labels[2] != "") {
      lab3= new QLabel(labels[2], this);
      box3 = new QDoubleSpinBox(this);
      box3->setRange(-999999, 999999);
      box3->setDecimals(8);
      box3->setValue(defaultValues[2]);
      l->addWidget(lab3);
      l->addWidget(box3);
    }
//    connect(box1, SIGNAL(editingFinished()), this, SLOT(accept ()) );
//    connect(box2, SIGNAL(editingFinished()), this, SLOT(accept ()) );
    connect(box3, SIGNAL(editingFinished()), this, SLOT(accept ()) );
  }

  double value1() { return box1->value();}
  double value2() { return box2->value();}
  double value3() { return box3->value();} // Be careful, this is not checked!

  QVBoxLayout *l;
  QLabel *lab1;
  QDoubleSpinBox *box1;
  QLabel *lab2;
  QDoubleSpinBox *box2;
  QLabel *lab3;
  QDoubleSpinBox *box3;
};

EventSheet::EventSheet(QWidget *parent) : QTableWidget(parent)
{
  qDebug() << "EventSheet::EventSheet";
  this->setRowCount(10);
  this->setColumnCount(6);
  columnNames << tr("Event") << "p1 (instr)" << "p2 (start)" << "p3 (dur)" << "p4" << "p5";
  this->setHorizontalHeaderLabels(columnNames);
  this->setColumnWidth(0, 50);
  this->setColumnWidth(1, 70);
  this->setColumnWidth(2, 70);
  this->setColumnWidth(3, 70);

  m_name = "Events";
  createActions();
}

EventSheet::~EventSheet()
{
}

QString EventSheet::getPlainText(bool scaleTempo)
{
  QString t = "";
  for (int i = 0; i < this->rowCount(); i++) {
    t += getLine(i, scaleTempo) + "\n";  // Don't scale by default
  }
//  qDebug() << " EventSheet::getPlainText   " << t;
  return t;
}

QString EventSheet::getLine(int number, bool scaleTempo)
{
  QString line = "";
  for (int i = 0; i < this->columnCount(); i++) {
    bool instrEvent = false;
    QTableWidgetItem * item = this->item(number, i);
    if (item != 0) { // Item is not empty
      if (i == 0 && (item->data(Qt::DisplayRole).toString() == "i") )
        instrEvent = true;  // Check if event is intrument note to allow scale by tempo
      if (scaleTempo && instrEvent && (i == 2 || i == 3) ) { // Scale tempo only for pfields p2 and p3
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

QString EventSheet::getName()
{
  return m_name;
}

void EventSheet::setFromText(QString text)
{
 // Separataion is stored in UserRole of items
  // remember to treat comments and formulas properly
  QStringList lines = text.split("\n");
  this->setRowCount(0);
  this->setColumnCount(6);
  for (int i = 0; i < lines.size(); i++) {
    if (this->rowCount() <= i) {
      appendRow();
    }
    QString line = lines[i].trimmed(); //Remove whitespace from start and end
    int count = 0;
    int pcount = 0;
    bool formula = false;
    bool string = false;
    bool isp = true; // Assume starting on a pfield, not white space
    QString pvalue = "";
    QString spacing = "";
    if (!line.isEmpty() && (line[0] == 'i' || line[0] == 'f') ) {
      QTableWidgetItem * item = this->item(i, pcount);
      if (item == 0) {
        item = new QTableWidgetItem();
        this->setItem(i, pcount, item);
      }
      item->setData(Qt::DisplayRole, QString(line[0]));
      count++;
      isp = false; // consider p-field done with first character.
    }
    while (count < line.size()) {
      if (isp == true || formula || string) { // Processing p-field
        if (line[count] == '"') { // string takes precedence over formulas and comments
          string = !string;
        }
        else if (line[count] == '[') { //Start of formula
          formula = true;  // This should never happen as this character should always be after whitespace....
        }
        else if (line[count] == ']') { //End of formula
          formula = false;
        }
        else if (line[count] == ';') { // comment
          // First add current pfield, in case there is no spacing
          if (this->columnCount() <= pcount)
            appendColumn();
          QTableWidgetItem * item = this->item(i, pcount);
          if (item == 0) {
            item = new QTableWidgetItem();
            this->setItem(i, pcount, item);
          }
          if (pvalue != "") { // Only add it if it is not empty, e.g. the comment is the first item
            item->setData(Qt::DisplayRole, pvalue);
          }
          // Now add comment
          pcount++;
          QString comment = line.mid(count);
          qDebug() << "EventSheet::setFromText: " << i << "---" << pcount << " - - " << comment;
          if (this->columnCount() <= pcount) {
            appendColumn();
          }
          item = this->item(i, pcount);
          if (item == 0) {
            item = new QTableWidgetItem();
            this->setItem(i, pcount, item);
          }
          item->setData(Qt::DisplayRole, comment);
          isp = false;  // last p-field has been processed here
          break; // Nothing more todo for this line
        }  // End of comment processing
        // ----
        if (line[count].isSpace() && !formula && !string) { // White space so p-field has finished
          if (this->columnCount() <= pcount) {
            appendColumn();
          }
          QTableWidgetItem * item = this->item(i, pcount);
          if (item == 0) {
            item = new QTableWidgetItem();
            this->setItem(i, pcount, item);
          }
          item->setData(Qt::DisplayRole, pvalue); // TODO are double values treated correctly
          spacing = "";
          spacing.append(line[count]);
          isp = false;
        }
        else { // A character or formula so continue p-field processing
          pvalue.append(line[count]);
        }
      }
      else { // Processing white space
        if (line[count] == '"') { // string
          string = !string;
        }
        else if (line[count] == '[') { //Start of formula
          formula = true;
        }
        else if (line[count] == ';') { // comment
          if (spacing != "") { // Process spacing if any
            QTableWidgetItem * item = this->item(i, pcount);
            if (item == 0) {
              item = new QTableWidgetItem();
              this->setItem(i, pcount, item);
            }
            item->setData(Qt::UserRole, spacing);
          }
          pcount++;
          QString comment = line.mid(count);
          if (this->columnCount() <= pcount) {
            appendColumn();
          }
          QTableWidgetItem * item = this->item(i, pcount);
          if (item == 0) {
            item = new QTableWidgetItem();
            this->setItem(i, pcount, item);
          }
          item->setData(Qt::DisplayRole, comment);
          break; // Nothing more todo on this line
        }
        // ---
        if (!line[count].isSpace()) { // Not White space so new p-field has started
          QTableWidgetItem * item = this->item(i, pcount);
          if (item == 0) {
            item = new QTableWidgetItem();
            this->setItem(i, pcount, item);
          }
          item->setData(Qt::UserRole, spacing); // TODO are double values treated correctly?
          isp = true;
          pvalue = "";
          pvalue.append(line[count]);
          pcount++;
        }
        else { // Continue p-field processing
          spacing.append(line[count]);
        }
      }
      count++;
    }
    // Process final p-field
    if (isp == true) {
      if (this->columnCount() <= pcount) {
        appendColumn();
      }
      QTableWidgetItem * item = this->item(i, pcount);
      if (item == 0) {
        item = new QTableWidgetItem();
        this->setItem(i, pcount, item);
      }
      item->setData(Qt::DisplayRole, pvalue);
    }
    else {
      QTableWidgetItem * item = this->item(i, pcount);
      if (item == 0) {
        item = new QTableWidgetItem();
        this->setItem(i, pcount, item);
      }
      item->setData(Qt::UserRole, spacing);
    }
  }
  if (this->rowCount() == 0)
    this->setRowCount(1);
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
  OneValueDialog d(this, tr("Subtract"));
  d.exec();
  if (d.result() == QDialog::Accepted) {
    this->add(- d.value());
  }
}

void EventSheet::add()
{
  OneValueDialog d(this, tr("Add"));
  d.exec();
  if (d.result() == QDialog::Accepted) {
    this->add(d.value());
  }
}

void EventSheet::multiply()
{
  OneValueDialog d(this, tr("Multiply by"));
  d.exec();
  if (d.result() == QDialog::Accepted) {
    this->multiply(d.value());
  }
}

void EventSheet::divide()
{
  OneValueDialog d(this, tr("Divide by"));
  d.exec();
  if (d.result() == QDialog::Accepted) {
    this->divide(d.value());
  }
}

void EventSheet::randomize()
{
  QStringList labels;
  labels << tr("Minimum") << tr("Maximum") << tr("Mode: 0=decimals 1=Integers only");
  QVector<double> defaultValues;
  defaultValues << 0.0 << 1.0 << 0.0;
  ThreeValueDialog d(this, labels, defaultValues);
  d.exec();
  if (d.result() == QDialog::Accepted) {
    this->randomize(d.value1(), d.value2(), d.value3());
  }
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
      if (item == 0) {
        item = new QTableWidgetItem();
        this->setItem(list[(i*numRows) + j].row(), list[(i*numRows) + j].column(), item );
      }
      item->setData(Qt::DisplayRole, elements[j] );
    }
  }
}

void EventSheet::shuffle(int iterations)
{

}

//void EventSheet::mirror()
//{
//
//}

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
  qDebug() << "EventSheet::appendRow()";
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

void EventSheet::rename()
{
  QDialog d;
  QVBoxLayout l(&d);
  QLabel label("Enter new name");
  QLineEdit line;
//  d.resize(300, d.height());
//  line.resize(300, line.height());
  line.setText(m_name);
  l.addWidget(&label);
  l.addWidget(&line);
  connect(&line, SIGNAL(editingFinished()), &d, SLOT(accept ()) );
  int ret = d.exec();
  if (ret == QDialog::Accepted) {
    m_name = line.text();
  }
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
//  menu.addAction(mirrorAct);
  menu.addAction(rotateAct);
  menu.addAction(fillAct);
  menu.addSeparator();
  menu.addAction(renameAct);
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

void EventSheet::randomize(double min, double max, int mode)
{
  // Mode 0 =
  // Mode 1 = integers only
  QModelIndexList list = this->selectedIndexes();
  QTime midnight(0, 0, 0);
  qsrand(midnight.secsTo(QTime::currentTime()));
  for (int i = 0; i < list.size(); i++) {
    QTableWidgetItem * item = this->item(list[i].row(), list[i].column());
    if (item == 0) {
      item = new QTableWidgetItem();
      this->setItem(list[i].row(), list[i].column(), item);
    }
    double value = 0.0;
    if (mode == 0) {
      value = min + ((double) qrand() / (double) RAND_MAX) * (max - min);
    }
    else /*if (mode == 1)*/ {  // Integers only
      value = min + (qrand() % (int) (max-min));
    }
    item->setData(Qt::DisplayRole,
                  QVariant(value));
  }
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

//  mirrorAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Mirror"), this);
//  mirrorAct->setStatusTip(tr("Mirror the selected cells"));
//  mirrorAct->setIconText(tr("Mirror"));
//  connect(mirrorAct, SIGNAL(triggered()), this, SLOT(mirror()));

  rotateAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Rotate"), this);
  rotateAct->setStatusTip(tr("Rotate the selected cells"));
  rotateAct->setIconText(tr("Rotate"));
  connect(rotateAct, SIGNAL(triggered()), this, SLOT(rotate()));

  fillAct = new QAction(/*QIcon(":/a.png"),*/ tr("&Fill Cells"), this);
  fillAct->setStatusTip(tr("Fill selected cells"));
  fillAct->setIconText(tr("Fill"));
  connect(fillAct, SIGNAL(triggered()), this, SLOT(fill()));

  renameAct = new QAction(/*QIcon(":/a.png"),*/ tr("Rename sheet"), this);
  renameAct->setStatusTip(tr("Rename sheet"));
  renameAct->setIconText(tr("This"));
  connect(renameAct, SIGNAL(triggered()), this, SLOT(rename()));


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
