/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.             *
 ***************************************************************************/
#ifndef DOCUMENTPAGE_H
#define DOCUMENTPAGE_H

#include <QWidget>
#include <QTextEdit>
#include <QDomElement>

class OpEntryParser;

class DocumentPage : public QTextEdit
{
  Q_OBJECT
  public:
    DocumentPage(QWidget *parent, OpEntryParser *opcodeTree);

    ~DocumentPage();

    int setTextString(QString text);
    QString getFullText();
    QString getMacWidgetsText();
    QString getMacOptionsText();
    QString getMacOption(QString option);
    QRect getWidgetPanelGeometry();

//     QTextDocument *textDocument;
    QString fileName;
    QString companionFile;
    bool askForFile;
    bool readOnly; // Used for manual files and internal examples

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event);

  private:
    QStringList macOptions;
    QString macPresets;
    QString macGUI;
    QDomElement widgets;

    bool widgetsDocked;
	OpEntryParser *m_opcodeTree;

  public slots:
    void setMacWidgetsText(QString text);
    void setMacOptionsText(QString text);
    void setMacOption(QString option, QString newValue);
    void setWidgetPanelPosition(QPoint position);
    void setWidgetPanelSize(QSize size);

    void comment();
    void uncomment();
    void indent();
    void unindent();
	
	void opcodeFromMenu();
	
};

#endif
