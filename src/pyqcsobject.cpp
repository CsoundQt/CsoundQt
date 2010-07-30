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

PyObject* PyQcsObject::getMainModule() {
  return PythonQt::self()->getMainModule();
}

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
}

void PyQcsObject::play(int index, bool realtime)
{
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

void PyQcsObject::sendEvent(QVariant events)
{
//  qDebug() << "PyQcsObject::sendEvent" << events;
  if (events.type() == QVariant::String )  { // a single event in a string
    m_qcs->sendEvent(events.toString());
//    qDebug() << "PyQcsObject::sendEvent sent: " << events.toString();
  }
//  else if (time.canConvert<QVariantList>()) { // list of events
//
//  }
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
