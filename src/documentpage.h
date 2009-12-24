/*
    Copyright (C) 2008, 2009 Andres Cabrera
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

#ifndef DOCUMENTPAGE_H
#define DOCUMENTPAGE_H

#include <QWidget>
#include <QTextEdit>
#include <QDomElement>

class OpEntryParser;
class Highlighter;
class LiveEventFrame;

class DocumentPage : public QTextEdit
{
  Q_OBJECT
  public:
    DocumentPage(QWidget *parent, OpEntryParser *opcodeTree);
    ~DocumentPage();

    int setTextString(QString text, bool autoCreateMacCsoundSections = true);
    void setColorVariables(bool color);
    void setOpcodeNameList(QStringList list);
    QString getFullText();
//     QString getXmlWidgetsText();
    QString getOptionsText();
    QString getDotText();
    QString getMacWidgetsText();
    QString getMacOptionsText();
    QString getMacOptions(QString option);
    QRect getWidgetPanelGeometry();
    void getToIn();
    void inToGet();
    static QString changeToChnget(QString text);
    static QString changeToInvalue(QString text);
    void markErrorLines(QList<int> lines);
    void unmarkErrorLines();
    void updateCsladspaText(QString text);
    QString getFilePath();
    int currentLine();
    void showLiveEvents();
    void hideLiveEvents();

//     QTextDocument *textDocument;
    QString fileName;
    QString companionFile;
    bool askForFile;
    bool readOnly; // Used for manual files and internal examples

  protected:
    virtual void keyPressEvent(QKeyEvent *event);
    virtual void contextMenuEvent(QContextMenuEvent *event);

  private:
    QStringList macOptions;
    QString macPresets;
    QString macGUI;
    QDomElement widgets;

    QVector<LiveEventFrame *> liveEvents;

    bool widgetsDocked;
    Highlighter *m_highlighter;
    OpEntryParser *m_opcodeTree;
    bool errorMarked;
    bool saveLiveEvents;

//     QString connectedNodeText(QString nodeName, QString label, QString dest);
//     QString dotTextForExpression(QString expression, QString &outNode);
    
  public slots:
    void setMacWidgetsText(QString widgetText);
    void setMacOptionsText(QString text);
    void setMacOption(QString option, QString newValue);
    void setWidgetPanelPosition(QPoint position);
    void setWidgetPanelSize(QSize size);
    void jumpToLine(int line);

    void comment();
    void uncomment();
    void indent();
    void unindent();

    void opcodeFromMenu();
    void newLiveEventFrame();

  private slots:
    void changed();
//     void moved();

  signals:
    void currentLineChanged(int);
    void currentTextUpdated();
    void doCopy();
    void doCut();
    void doPaste();
    void registerLiveEvent(QWidget *e);
};

#endif
