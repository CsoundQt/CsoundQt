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

#include "pyqcsobject.h"
#include "qutecsound.h"
#include "qutesheet.h"

#include <QMessageBox>
#include <QDir>
#include "csound.hpp"

PyQcsObject::PyQcsObject():QObject(NULL)
{
  m_qcs = 0;
}

void PyQcsObject::setQuteCsound(qutecsound *qcs)
{
  m_qcs = qcs;
}

//PyObject* PyQcsObject::getMainModule() {
//  return PythonQt::self()->getMainModule();
//}

//void PyQcsObject::showInformation(const QString& str)
//{
// QMessageBox::information ( NULL, "Test", str);
//}

//QStringList PyQcsObject::readDirectory(const QString& dir)
//{
//  QDir d(dir);
//  return d.entryList();
//}

//QMainWindow* PyQcsObject::createWindow()
//{
//  QMainWindow* m = new QMainWindow();
//  QPushButton* b = new QPushButton(m);
//  b->setObjectName("button1");
//
//  m->show();
//  return m;
//}

//QObject* PyQcsObject::findChild(QObject* o, const QString& name)
//{
//  return qFindChild<QObject*>(o, name);
//}

//QVariantMap PyQcsObject::testMap()
//{
//  QVariantMap m;
//  m.insert("a", QStringList() << "test1" << "test2");
//  m.insert("b", 12);
//  m.insert("c", 12.);
//  return m;
//}

CSOUND* PyQcsObject::getCurrentCsound()
{
  CSOUND *cs = (CSOUND *) m_qcs->getCurrentCsound();
  return cs;
}

QString PyQcsObject::getVersion()
{
  return QString(PYQCSVERSION);
}

void PyQcsObject::play(int index, bool realtime)
{
  qDebug() << "PyQcsObject::play " << index << realtime;
  // Notice arguments are inverted...
  m_qcs->play(realtime, index);
}

void PyQcsObject::pause(int index)
{
  m_qcs->pause(index);
}

void PyQcsObject::stop(int index)
{
  m_qcs->stop(index);
}

void PyQcsObject::stopAll()
{
  m_qcs->stopAll();
}

void PyQcsObject::setDocument(int index)
{
  QString name = m_qcs->setDocument(index);
  PythonQtObjectPtr mainContext = PythonQt::self()->getMainModule();
  QString path = name.left(name.lastIndexOf("/"));
  mainContext.call("os.chdir", QVariantList() << path );
  mainContext.evalScript("print 'cd \"" + path + "\"'");
}

void PyQcsObject::insertText(QString text, int index, int section)
{
  return m_qcs->insertText(text, index,section);
}

void PyQcsObject::setCsd(QString text, int index)
{
  return m_qcs->setCsd(text, index);
}

void PyQcsObject::setFullText(QString text, int index)
{
  return m_qcs->setFullText(text, index);
}

void PyQcsObject::setOrc(QString text, int index)
{
  return m_qcs->setOrc(text, index);
}

void PyQcsObject::setSco(QString text, int index)
{
  return m_qcs->setSco(text, index);
}

void PyQcsObject::setWidgetsText(QString text, int index)
{
  return m_qcs->setWidgetsText(text, index);
}

void PyQcsObject::setPresetsText(QString text, int index)
{
  return m_qcs->setPresetsText(text, index);
}

void PyQcsObject::setOptionsText(QString text, int index)
{
  return m_qcs->setOptionsText(text, index);
}

int PyQcsObject::getDocument(QString name)
{
  return m_qcs->getDocument(name);
}

QString PyQcsObject::getSelectedText(int index, int section)
{
  return m_qcs->getSelectedText(index,section);
}

QString PyQcsObject::getCsd(int index)
{
  return m_qcs->getCsd(index);
}

QString PyQcsObject::getFullText(int index)
{
  return m_qcs->getFullText(index);
}

QString PyQcsObject::getOrc(int index)
{
  return m_qcs->getOrc(index);
}

QString PyQcsObject::getSco(int index)
{
  return m_qcs->getSco(index);
}

QString PyQcsObject::getWidgetsText(int index)
{
  return m_qcs->getWidgetsText(index);
}

QString PyQcsObject::getPresetsText(int index)
{
  return m_qcs->getPresetsText(index);
}

QString PyQcsObject::getOptionsText(int index)
{
  return m_qcs->getOptionsText(index);
}

void PyQcsObject::setChannelValue(QString channel, double value, int index)
{
  return m_qcs->setChannelValue(channel, value, index);
}

double PyQcsObject::getChannelValue(QString channel, int index)
{
  return m_qcs->getChannelValue(channel, index);
}

void PyQcsObject::setChannelString(QString channel, QString value, int index)
{
  return m_qcs->setChannelString(channel, value, index);
}

QString PyQcsObject::getChannelString(QString channel, int index)
{
  return m_qcs->getChannelString(channel, index);
}

void PyQcsObject::createNewLabel(int x, int y, int index)
{
  return m_qcs->createNewLabel(x,y, index);
}

void PyQcsObject::createNewDisplay(int x, int y, int index)
{
  return m_qcs->createNewDisplay(x,y, index);
}

void PyQcsObject::createNewScrollNumber(int x, int y, int index)
{
  return m_qcs->createNewScrollNumber(x,y, index);
}

void PyQcsObject::createNewLineEdit(int x, int y, int index)
{
  return m_qcs->createNewLineEdit(x,y, index);
}

void PyQcsObject::createNewSpinBox(int x, int y, int index)
{
  return m_qcs->createNewSpinBox(x,y, index);
}

void PyQcsObject::createNewSlider(int x, int y, int index)
{
  return m_qcs->createNewSlider(x,y, index);
}

void PyQcsObject::createNewButton(int x, int y, int index)
{
  return m_qcs->createNewButton(x,y, index);
}

void PyQcsObject::createNewKnob(int x, int y, int index)
{
  return m_qcs->createNewKnob(x,y, index);
}

void PyQcsObject::createNewCheckBox(int x, int y, int index)
{
  return m_qcs->createNewCheckBox(x,y, index);
}

void PyQcsObject::createNewMenu(int x, int y, int index)
{
  return m_qcs->createNewMenu(x,y, index);
}

void PyQcsObject::createNewMeter(int x, int y, int index)
{
  return m_qcs->createNewMeter(x,y, index);
}

void PyQcsObject::createNewConsole(int x, int y, int index)
{
  return m_qcs->createNewConsole(x,y, index);
}

void PyQcsObject::createNewGraph(int x, int y, int index)
{
  return m_qcs->createNewGraph(x,y, index);
}

void PyQcsObject::createNewScope(int x, int y, int index)
{
  return m_qcs->createNewScope(x,y, index);
}

QuteSheet* PyQcsObject::getSheet(int index, int sheetIndex)
{
  return new QuteSheet(this, m_qcs->getSheet(index,sheetIndex));
}

QuteSheet* PyQcsObject::getSheet(int index, QString sheetName)
{
  return new QuteSheet(this, m_qcs->getSheet(index,sheetName));
}

void PyQcsObject::schedule(QVariant time, QVariant event)
{
  qDebug() << "PyQcsObject::schedule" << event;
  if (time.canConvert<double>())  { // a single event
    QString eventLine = "i ";
    if (event.canConvert<QVariantList>()) {
      QVariantList fields = event.value<QVariantList>();
      for (int f = 0; f < fields.size(); f++) {
        if (strcmp(fields[f].typeName(), "double") || strcmp(fields[f].typeName(),"int")) {
          eventLine.append(fields[f].toString() + " ");
        }
        else {
          eventLine.append("\"" + fields[f].toString() + "\"");
        }
      }
    }
    qDebug() << "PyQcsObject::schedule: " << eventLine;
  }
  else if (time.canConvert<QVariantList>()) { // list of events
  }
}

void PyQcsObject::sendEvent(QString events)
{
//  qDebug() << "PyQcsObject::sendEvent" << events;
  m_qcs->sendEvent(events);
//  if (events.type() == QVariant::String )  { // a single event in a string
//    m_qcs->sendEvent(events.toString());
//    qDebug() << "PyQcsObject::sendEvent sent: " << events.toString();
//  }
//  else if (time.canConvert<QVariantList>()) { // list of events
//
//  }
}

void PyQcsObject::sendEvent(int index, QString events)
{

}

void PyQcsObject::writeListToTable(int ftable, QVariantList values, int offset, int count)
{
  
}

QVariantList PyQcsObject::readTableToList(int ftable, int offset, int count)
{
  CSOUND *cs = getCurrentCsound();
  PythonQtObjectPtr mainContext = PythonQt::self()->getMainModule();
  QVariantList list;
  if (cs == 0) {
    mainContext.evalScript("print 'Csound Engine invalid.'");
    return list;
  }
  int tabLen = csoundTableLength(cs, ftable);
  if (tabLen < 0) {
    mainContext.evalScript("print '''readTableToList(): Invalid table " + QString::number(ftable) + "'''");
//    return QVariantList();
  }
  MYFLT **tablePtr;
  int ret = csoundGetTable(cs, tablePtr, ftable);
//  qDebug() << "PyQcsObject::readTableToList " << tablePtr << "--" << tabLen;
//  while (offset < tabLen && count > 0) {
//    list << *(tablePtr[offset]);
//    offset++;
//    count--;
//  }
  return list;
}

void PyQcsObject::writeArrayToTable(int ftable, QVariantList values, int offset, int count)
{
  qDebug() << "PyQcsObject::writeArrayToTable not implemented";
}

QVariantList PyQcsObject::readArrayToList(int ftable, int offset, int count)
{
  qDebug() << "PyQcsObject::readArrayToList not implemented";
  return QVariantList();
}

void  PyQcsObject::registerProcessCallback()
{
  qDebug() << "PyQcsObject::registerProcessCallback not implemented";
}
