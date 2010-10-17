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

#define PYQCSVERSION "1.0.0"

class qutecsound;
class QuteSheet;

class PyQcsObject : public QObject {
  Q_OBJECT

  public:
    PyQcsObject();
    void setQuteCsound(qutecsound *qcs);

  public slots:
//  ! example for passing a PyObject directly from Qt to Python (without extra mashalling)
//    PyObject* getMainModule();
//  void showInformation(const QString& str);
//  QStringList readDirectory(const QString& dir);
//  QMainWindow* createWindow();
//  QObject* findChild(QObject* o, const QString& name);
//  QVariantMap testMap();

    CSOUND* getCurrentCsound();

    QString getVersion();

    // Csound controls
    void play(int index = -1, bool realtime = true);
    void pause(int index = -1);
    void stop(int index = -1);
    void stopAll();

    //Csound Language
    bool opcodeExists(QString opcodeName);

    // Editor
    void setDocument(int index);
    void insertText(QString text, int index = -1, int section = -1);
    void setCsd(QString text, int index = -1);
    void setFullText(QString text, int index = -1);
    void setOrc(QString text, int index = -1);
    void setSco(QString text, int index = -1);
    void setWidgetsText(QString text, int index = -1); //FIXME how to handle parsing errors?
    void setPresetsText(QString text, int index = -1); //FIXME how to handle parsing errors?
    void setOptionsText(QString text, int index = -1);

    int getDocument(QString name = ""); // Returns document index. -1 if not current open

    QString getSelectedText(int index = -1, int section = -1);
    QString getCsd(int index = -1);  // -1 uses current tab
    QString getFullText(int index = -1);
    QString getOrc(int index = -1);
    QString getSco(int index = -1);
    QString getWidgetsText(int index = -1);
    QString getPresetsText(int index = -1);
    QString getOptionsText(int index = -1);

    //Widgets
    void setChannelValue(QString channel, double value, int index = -1);
    double getChannelValue(QString channel, int index = -1);
    void setChannelString(QString channel, QString value, int index = -1);
    QString getChannelString(QString channel, int index = -1);

    void createNewLabel(int x = -1, int y = -1, int index = -1);
    void createNewDisplay(int x = -1, int y = -1, int index = -1);
    void createNewScrollNumber(int x = -1, int y = -1, int index = -1);
    void createNewLineEdit(int x = -1, int y = -1, int index = -1);
    void createNewSpinBox(int x = -1, int y = -1, int index = -1);
    void createNewSlider(int x = -1, int y = -1, int index = -1);
    void createNewButton(int x = -1, int y = -1, int index = -1);
    void createNewKnob(int x = -1, int y = -1, int index = -1);
    void createNewCheckBox(int x = -1, int y = -1, int index = -1);
    void createNewMenu(int x = -1, int y = -1, int index = -1);
    void createNewMeter(int x = -1, int y = -1, int index = -1);
    void createNewConsole(int x = -1, int y = -1, int index = -1);
    void createNewGraph(int x = -1, int y = -1, int index = -1);
    void createNewScope(int x = -1, int y = -1, int index = -1);

    // Live Events
    QuteSheet* getSheet(int index = -1, int sheetIndex = -1);
    QuteSheet* getSheet(int index, QString sheetName);

    //Scheduler
    void schedule(QVariant time, QVariant event);
    void sendEvent(int index, QString events);
    void sendEvent(QString events);

    // To/From Csound Engine
//    void writeListToTable(int ftable, QVariantList values, int offset = 0, int count = -1);
//    QVariantList readTableToList(int ftable, int offset = 0, int count = -1);
//    void writeArrayToTable(int ftable, QVariantList values, int offset = 0, int count = -1); // Numpy arrays
//    QVariantList readArrayToList(int ftable, int offset = 0, int count = -1); // Numpy arrays

    // Register callback
    void registerProcessCallback(QString func, int skipPeriods = 0);

  private:
    qutecsound *m_qcs;
};

#endif // PYQCSOBJECT_H
