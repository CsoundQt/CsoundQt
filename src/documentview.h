/*
	Copyright (C) 2010 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
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

#ifdef USE_QT5
#include <QtWidgets>
#include <QtPrintSupport/QPrinter>
#include <QtPrintSupport/QPrintDialog>
#else
#include <QtGui>
#endif

#include "baseview.h"

#include <QKeyEvent> // For syntax menu class

class MySyntaxMenu: public QMenu
{
	Q_OBJECT
public:
	MySyntaxMenu(QWidget * parent);
	~MySyntaxMenu();

	bool insertComplete; // Whether to insert full text or only opcode name

protected:
	virtual void keyPressEvent(QKeyEvent * event);
signals:
	void keyPressed(QString text); // Used to send both pressed keys and full opcode text to be pasted
};

class DocumentView : public BaseView
{
	Q_OBJECT
public:
	DocumentView(QWidget * parent, OpEntryParser *opcodeTree = 0);
	~DocumentView();

	void insertText(QString text, int section = -1);
	void setAutoComplete(bool autoComplete);
	void setAutoParameterMode(bool autoParameterMode);
	void setViewMode(int mode);

	// TODO add all text inputs here as below

	QString getSelectedText(int section = -1);

	// These two should be used with care as they are only here in case
	// Widgets are being edited in text format. In most cases, you want to
	// get the widgets Text from the widget layout object
	QString getMacWidgetsText(); // With tags including presets
	QString getWidgetsText(); // With tags including presets, in new xml format
	int getViewMode();

	QString wordUnderCursor();
	QString getActiveSection();
	QString getActiveText();
	int currentLine();
	bool isModified();
	bool childHasFocus();
	void print(QPrinter *printer);

public slots:
	void setModified(bool mod = true);
	//    void updateDocumentModel();
	//    void updateFromDocumentModel();
	void syntaxCheck();
	void textChanged();
	void escapePressed();
	void indentNewLine();
	void findReplace();
	void getToIn(); // chnget/chnset to invalue/outvalue
	void inToGet(); // invalue/outvalue to chnget/chnset
	void insertAutoCompleteText();
	void insertParameterText();
	void findString(QString query = QString());
	void evaluate();
	void updateContext();
	void updateOrcContext(QString orc);
	void nextParameter();
	void prevParameter();
	void openParameterSelection();
	void parameterShowShortcutPressed();
	void createContextMenu(QPoint pos);

	void showOrc(bool);
	void showScore(bool);
	void showOptions(bool);
	void showFileB(bool);
	void showOther(bool);
	void showOtherCsd(bool);
	void showWidgetEdit(bool);
	void showAppEdit(bool);

	void cut();
	void copy();
	void paste();
	void undo();
	void redo();
	void comment();
	void uncomment();
	void indent();
	void unindent();
	void killLine();
	void killToEnd();

	void markErrorLines(QList<QPair<int, QString> > lines);
	void unmarkErrorLines();
	void jumpToLine(int line);
	void gotoNextLine();
	void opcodeFromMenu();

protected:
	virtual void contextMenuEvent(QContextMenuEvent *event);

private:
	QString changeToChnget(QString text);
	QString changeToInvalue(QString text);
	//    void createSyntaxMenu();

	MySyntaxMenu *syntaxMenu;
	MySyntaxMenu *parameterMenu;
	QPushButton *parameterButton;
	bool m_isModified;
	bool m_autoComplete;
	bool m_autoParameterMode;
	bool errorMarked;
	bool internalChange;  // to let popoup opcode completion know if text change was internal

	bool lastCaseSensitive; // These last three are for search and replace
	QString lastSearch;
	QString lastReplace;
	QStringList m_localVariables;
	QStringList m_globalVariables;

private slots:
	void destroySyntaxMenu();
	void opcodeHelp();

signals:
	void opcodeSyntaxSignal(QString syntax);  // Report an opcode syntax under cursor
	void lineNumberSignal(int number); // Sends current line number when cursor is moved
	void setHelp(); // Request execute open opcode help action
	void contentsChanged();
	void closeExtraPanels();
	void evaluate(QString code);
};

#endif // DOCUMENTVIEW_H
