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

#ifndef EVENTSHEET_H
#define EVENTSHEET_H

#include <QTableWidget>
#include <QStandardItemModel>
#include <QAction>

class EventSheet : public QTableWidget
{
  Q_OBJECT
  public:
    EventSheet(QWidget *parent);
    ~EventSheet();

    QString getPlainText(bool scaleTempo = false);
    QString getLine(int number, bool scaleTempo = false, bool storeNumber = false);
    double getTempo();
    QString getName();
    void setFromText(QString text);

  public slots:
    void setTempo(double value);
    void sendEvents();
    void loopEvents();
    void stopAllEvents();
    void del();
    void cut();
    void copy(bool cut = false);
    void paste();

    void subtract();
    void add();
    void multiply();
    void divide();

    void randomize();
    void reverse();  // Reverse columns
    void shuffle();
//    void mirror();
    void rotate();
    void fill();

    void insertColumnHere();
    void insertRowHere();
    void appendColumn();
    void appendRow();
    void deleteColumn();
    void deleteRow();

    void rename();

  protected:
    void contextMenuEvent(QContextMenuEvent * event);
    virtual void keyPressEvent(QKeyEvent * event);

  private:
    void createActions();

    // Operations
    void add(double value);
    void multiply(double value);
    void divide(double value);
    void randomize(double min, double max, int mode);
    void shuffle(int iterations);
    void rotate(int amount);
    void fill(double start, double end, double slope);

    void rename(QString name);

    // Attributes to be saved
    double tempo;
    QString m_name;

    // Actions
    QAction *sendEventsAct;
    QAction *loopEventsAct;
    QAction *stopAllEventsAct;
    QAction *subtractAct;
    QAction *addAct;
    QAction *multiplyAct;
    QAction *divideAct;
    QAction *randomizeAct;
    QAction *reverseAct;
    QAction *shuffleAct;
//    QAction *mirrorAct;
    QAction *rotateAct;
    QAction *fillAct;
    QAction *renameAct;

    QAction *insertColumnHereAct;
    QAction *insertRowHereAct;
    QAction *appendColumnAct;
    QAction *appendRowAct;
    QAction *deleteColumnAct;
    QAction *deleteRowAct;

    QStringList columnNames;

    QList<double> activeInstruments;

  private slots:
    void selectionChanged();

  signals:
    void sendEvent(QString event);
};

#endif // EVENTSHEET_H
