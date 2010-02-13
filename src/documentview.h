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

#ifndef DOCUMENTVIEW_H
#define DOCUMENTVIEW_H

#include <QtGui>
#include "highlighter.h"

class OpEntryParser;

#include <QKeyEvent> // For syntax menu class

class MySyntaxMenu: public QMenu
{
  Q_OBJECT
  public:
    MySyntaxMenu(QWidget * parent);
    ~MySyntaxMenu();
  protected:
    virtual void keyPressEvent(QKeyEvent * event);
  signals:
    void keyPressed(QString text);
};

class DocumentView : public QScrollArea
{
  Q_OBJECT
  public:
    DocumentView(QWidget * parent, OpEntryParser *opcodeTree = 0);
    ~DocumentView();
    void setViewMode(int mode);
    void setFont(QFont font);
    void setFontPointSize(float size);
    void setTabWidth(int width);
    void setTabStopWidth(int width);
    void setLineWrapMode(QTextEdit::LineWrapMode mode);
    void setColorVariables(bool color);
    void setOpcodeNameList(QStringList list);
    void setOpcodeTree(OpEntryParser *opcodeTree);

    void setFullText(QString text);
    void setLadspaText(QString text);

    // TODO add all text inputs here as below

    QString getFullText();
    QString getBasicText();  // What Csound needs (no widgets, misc text, etc.)
    QString getOrcText();  // Without tags
    QString getScoText();  // Without tags
    QString getOptionsText();  // Without tags
    QString getMiscText();  // All other tags like version and licence with tags
    QString getExtraText(); // Text outside any known tags
    // These two should be used with care as they are only here in case
    // Widgets are being edited in text format. In most cases, you want to
    // get the widgets Text from the widget layout object
    QString getMacWidgetsText(); // With tags including presets
    QString getWidgetsText(); // With tags including presets, in new xml format

    QString wordUnderCursor();
    int currentLine();
    bool isModified();
    void print(QPrinter *printer);

  public slots:
    void setModified(bool mod = true);
//    void updateDocumentModel();
//    void updateFromDocumentModel();
    void syntaxCheck();
    void textChanged();
    void findReplace();
    void getToIn(); // chnget/chnset to invalue/outvalue
    void inToGet(); // invalue/outvalue to chnget/chnset
    void autoComplete();
    void insertTextFromAction();
    void findString(QString query = QString());

    void comment();
    void uncomment();
    void indent();
    void unindent();

    void markErrorLines(QList<int> lines);
    void unmarkErrorLines();
    void jumpToLine(int line);
    // FIXME connect these to the engine (or where appropriate)
    void opcodeFromMenu();
    void updateCsladspaText(QString text);

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event);

//    void setModified(bool mod = true);

  private:
    QString changeToChnget(QString text);
    QString changeToInvalue(QString text);

    void hideAllEditors();
    int m_viewMode; // 0 = csd without widget + preset section
                    // 1 = full plain text
                    // From here on, you can have an or'd combination
                    // 2 = show CsInstruments Section
                    // 4 = show CsScore Section
                    // 8 = show CsOptions Section
                    // 16 = show <CsFileB> Section(s)
                    // 32 = show <CsVersion> Section(s)
                    // 64 = show <CsLicence>/<CsLicense> Section(s)
                    //128 = show Text outside any tag
                    //256 = show Widget, Preset and Extra Options sections
                    //512 = show <CsLadspa> text with tags
    QSplitter *splitter;
    QTextEdit *mainEditor;
    QTextEdit *scoreEditor;
    QTextEdit *optionsEditor;
    QTextEdit *filebEditor;
    QTextEdit *versionEditor;
    QTextEdit *licenceEditor;
    QTextEdit *otherEditor;
    QTextEdit *widgetEditor;
    QTextEdit *ladspaEditor;
    QVector<QTextEdit *> editors; // A vector to hold pointers for the above for easy processing

    OpEntryParser *m_opcodeTree;
    MySyntaxMenu *syntaxMenu;
    Highlighter m_highlighter;
    bool m_isModified;
    bool errorMarked;

    bool lastCaseSensitive; // These last three are for search and replace
    QString lastSearch;
    QString lastReplace;

  signals:
    void opcodeSyntaxSignal(QString syntax);  // Report an opcode syntax under cursor
    void lineNumberSignal(int number); // Sends current line number when cursor is moved
    void contentsChanged();
};

#endif // DOCUMENTVIEW_H
