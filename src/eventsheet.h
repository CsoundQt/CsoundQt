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
#include <QTimer>

class EventSheet : public QTableWidget
{
  Q_OBJECT
  public:
    EventSheet(QWidget *parent);
    ~EventSheet();

    QString getPlainText(bool scaleTempo = false);
    QString getLine(int number, bool scaleTempo = false, bool storeNumber = false);
//    double getTempo();
//    QString getName();
    void setFromText(QString text, int rowOffset = 0, int columnOffset = 0, int numRows = 0, int numColumns = 0);

  public slots:
    void setTempo(double value);
    void setLoopLength(double value);
    void sendEvents();
    void loopEvents();
    void stopAllEvents();
    void del();
    void cut();
    void copy(bool cut = false);
    void paste();
    void undo();
    void redo();
    void markHistory(QTableWidgetItem *item = 0);
    void clearHistory();

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

  protected:
    void contextMenuEvent(QContextMenuEvent * event);
    virtual void keyPressEvent(QKeyEvent * event);

  private:
    void createActions();
    QList<QPair<QString, QString> > parseLine(QString line);

    // Operations
    void add(double value);
    void multiply(double value);
    void divide(double value);
    void randomize(double min, double max, int mode);
    void shuffle(int iterations);
    void rotate(int amount);
    void fill(double start, double end, double slope);

//    void rename(QString name);

    // Attributes to be saved
    double m_tempo;
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
    bool m_looping; // Whether currently looping
    double m_loopLength;

    //Undo / Redo
    int historyIndex;
    QVector<QString> history;

    // Looping
    QTimer loopTimer;
    QModelIndexList  loopList;

  private slots:
    void selectionChanged();
    void cellDoubleClickedSlot(int row, int column);

  signals:
    void sendEvent(QString event);
    void cellDoubleClicked();
};

#endif // EVENTSHEET_H
