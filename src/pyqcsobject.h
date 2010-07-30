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

#ifndef PYQCSOBJECT_H
#define PYQCSOBJECT_H

#include "PythonQt.h"

#include <QObject>
#include <QStringList>
#include <QMainWindow>
#include <QPushButton>
#include <QVariant>
#include <QLayout>

#include <csound.hpp>

class qutecsound;

class PyQcsObject : public QObject {
  Q_OBJECT

  public:
    PyQcsObject();
    void setQuteCsound(qutecsound *qcs);

  public slots:

  //! example for passing a PyObject directly from Qt to Python (without extra mashalling)
    PyObject* getMainModule();

//  void showInformation(const QString& str);
//
//  QStringList readDirectory(const QString& dir);
//
//  QMainWindow* createWindow();
//
//  QObject* findChild(QObject* o, const QString& name);
//
//  QVariantMap testMap();

    CSOUND* getCurrentCsound();

    // QuteCsound control
    void play(int index = -1, bool realtime = true);
    void pause(int index = -1);
    void stop(int index = -1);
    void stopAll();

    void setDocument(int index);

    //Scheduler
    void schedule(QVariant time, QVariant event);
    void sendEvent(QVariant events);

    // To/From Csound Engine
    void writeListToTable(int ftable, QVariantList values, int offset = 0, int count = -1);
    QVariantList readTableToList(int ftable, int offset = 0, int count = -1);

  private:
    qutecsound *m_qcs;
};

#endif // PYQCSOBJECT_H
