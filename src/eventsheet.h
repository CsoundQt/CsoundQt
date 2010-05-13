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
    QString getLine(int number, bool scaleTempo = false,
                    bool storeNumber = false, bool preprocess = false,
                    double startOffset = 0.0);
//    double getTempo();
//    QString getName();
    void setFromText(QString text, int rowOffset = 0, int columnOffset = 0,
                     int numRows = 0, int numColumns = 0, bool noHistoryMark = false);
    void setDebug(bool debug);
    QPair<int, int> getSelectedRowsRange();

  public slots:
    void setTempo(double value);
    void setLoopLength(double value);
    void sendEvents();
    void sendAllEvents();
    void sendEventsOffset();
    void loopEvents();
    void setLoopActive(bool loop);
    void markLoop(double start = -1, double end = -1); // This does the actual marking and setting.
    void setLoopRange(); // This is called internally, and it calls the mark loop function in event sheet panel
    void stopAllEvents();
    void del();
    void cut();
    void copy(bool cut = false);
    void paste();
    void undo();
    void redo();
    void markHistory();
    void clearHistory();
    void setScriptDirectory(QString dir);

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
    void appendColumns();
    void appendRows();
    void deleteColumn();
    void deleteRows();

  protected:
    void contextMenuEvent(QContextMenuEvent * event);
    virtual void keyPressEvent(QKeyEvent * event);

  private:
    void createActions();
    QList<QPair<QString, QString> > parseLine(QString line);
    bool m_stopScript;  // Order stopping python script

    // Operations
    void add(double value);
    void multiply(double value);
    void divide(double value);
    void randomize(double min, double max, int mode);
    void shuffle(int iterations);
    void rotate(int amount);
    void fill(double start, double end, double slope);

    void runScript(QString script);
    QString generateDataText(QString outFileName);
    void addDirectoryToMenu(QMenu *m, QString dir, int depth = 0);
//    void rename(QString name);

    // Attributes to be saved
    double m_tempo;
    QString m_name;

    // Actions
//    QAction *copyAct;
//    QAction *pasteAct;
//    QAction *cutAct;
    QAction *sendEventsAct;
    QAction *sendEventsOffsetAct;
    QAction *loopSelectionAct;
    QAction *enableLoopAct;
    QAction *markLoopAct;
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
    QAction *stopScriptAct;

    QAction *insertColumnHereAct;
    QAction *insertRowHereAct;
    QAction *appendColumnAct;
    QAction *appendRowAct;
    QAction *appendColumnsAct;
    QAction *appendRowsAct;
    QAction *deleteColumnAct;
    QAction *deleteRowAct;

    QStringList columnNames;

    QList<double> activeInstruments;
    bool m_looping; // Whether currently looping
    bool m_debug; // Debug mode
    double m_loopLength;
    int noHistoryChange; // Last change in cells was made by undo

    //Undo / Redo
    int historyIndex;
    QVector<QString> history;

    // Looping
    QTimer loopTimer;
    int m_loopStart, m_loopEnd; // Start and end rows for looping (both inclusive)
//    QModelIndexList  loopList;

    // Python scripts
    QString scriptDir;
    QStringList builtinScripts;
    QStringList converterScripts;
    QStringList testScripts;

  private slots:
    void selectionChanged();
    void cellDoubleClickedSlot(int row, int column);
    void cellChangedSlot(int row, int column);
    void stopScript();

    void runScript();

  signals:
    void sendEvent(QString event);
    void setLoopRangeFromSheet(double start, double end);
//    void cellDoubleClicked();
    void modified();
};

#endif // EVENTSHEET_H
