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

class DocumentView : public QWidget
{
  public:
    DocumentView(QWidget * parent, OpEntryParser *opcodeTree = 0);
    void setViewMode(int mode);
    void setFont(QFont font);
    void setFontPointSize(float size);
    void setTabWidth(int width);
    void setTabStopWidth(int width);
    void setLineWrapMode(bool mode);
    void setColorVariables(bool color);
    void setOpcodeNameList(QStringList list);
    void setOpcodeTree(OpEntryParser *opcodeTree);
    QString wordUnderCursor();
    bool isModified();
    void print(QPrinter *printer);


  public slots:
    void updateDocumentModel();
    void updateFromDocumentModel();
    void syntaxCheck();
    void findReplace();
    void getToIn(); // chnget/chnset to invalue/outvalue
    void inToGet(); // invalue/outvalue to chnget/chnset

    void comment();
    void uncomment();
    void indent();
    void unindent();

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
    QSplitter *splitter;
    QTextEdit *mainEditor;
    QTextEdit *scoreEditor;
    QTextEdit *optionsEditor;
    QTextEdit *filebEditor;
    QTextEdit *versionEditor;
    QTextEdit *licenceEditor;
    QTextEdit *otherEditor;
    QTextEdit *widgetEditor;
    QVector<QTextEdit *> editors; // A vector to hold pointers for the above for easy processing

    OpEntryParser *m_opcodeTree;
    bool m_isModified;

    bool lastCaseSensitive; // These last three are for search and replace
    QString lastSearch;
    QString lastReplace;


  private slots:

  signals:
    void opcodeSyntaxSignal(QString);  // Report an opcode syntax under cursor
};

#endif // DOCUMENTVIEW_H
