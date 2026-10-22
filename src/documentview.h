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

#include <QtWidgets>
#include <QtPrintSupport/QPrinter>
#include <QtPrintSupport/QPrintDialog>

#include "baseview.h"
#include "bracketmatcher.h"
#include "widgetpropertyinfo.h"

#include <QKeyEvent> // For syntax menu class
#include <QPair>
#include <functional>

class QListWidget;
class QListWidgetItem;

class MySyntaxMenu: public QFrame
{
	Q_OBJECT
public:
	MySyntaxMenu(QWidget * parent);
	~MySyntaxMenu();

	bool insertComplete = false; // Whether to insert the full syntax or only the opcode name
	QAction *addCompletion(const QString &text, const QVariant &data,
	                       const QString &toolTip, int priority,
	                       QObject *receiver, const char *slot);
	void clearCompletions();
	void refreshCompletions(int maxVisibleLines, int widthCharacters);
	void setAvailableHeight(int height);
	bool hasCompletions() const;

	// (Re)apply the popup's style for the current application palette. Called
	// by DocumentView::setTheme() so a theme switch does not leave the popup
	// with the colours of the previous one; does nothing when the light/dark
	// state has not changed.
	void applyStyle();

protected:
    void keyPressEvent(QKeyEvent *event) override;
    void showEvent(QShowEvent *event) override;
    void paintEvent(QPaintEvent *event) override;
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
	void activateCurrent(bool complete);
	void activateItem(QListWidgetItem *item, bool complete);
	QListWidget *m_completionList = nullptr;
	QList<QAction *> m_completionActions;
	QHash<QListWidgetItem *, QAction *> m_itemActions;
	int m_preferredListHeight = 0;
	int m_minimumRowHeight = 1;
	bool m_styleApplied = false; // whether the sheet below was built at all
	bool m_darkStyle = false;    // and for which palette it was built
    QColor m_backgroundColor;
    QColor m_borderColor;
};

class HoverWidget :
		public QWidget
{
	Q_OBJECT
public:
	HoverWidget(QWidget *parent);
	~HoverWidget() {}

protected:
	void mousePressEvent(QMouseEvent *ev);

};

class FindBar;
class OpcodeInsertBar;

class DocumentView : public BaseView
{
	Q_OBJECT
public:
	DocumentView(QWidget * parent, OpEntryParser *opcodeTree = 0);
	~DocumentView();

	void insertText(QString text, int section = -1);
    void setAutoComplete(bool autoComplete, int delay = 0);
    void setAutoCompleteMenuWidth(int width);
    void setAutoCompleteMenuMaxLines(int lines);
	void setAutoParameterMode(bool autoParameterMode);
	void setViewMode(int mode);

	// TODO add all text inputs here as below

	QString getSelectedText(int section = -1);

	// These two should be used with care as they are only here in case
	// Widgets are being edited in text format. In most cases, you want to
	// get the widgets Text from the widget layout object
	QString getWidgetsText(); // With tags including presets, in new xml format
	int getViewMode();

	QString wordUnderCursor();
    QString lineUnderCursor();
	QString getActiveSection();
	// Word for "Opcode Entry" lookup: explicit selection wins, otherwise the
	// word at the cursor if it names a known opcode, otherwise the nearest
	// known opcode before the cursor on the same line (the leniency the
	// status bar signature matching has).
	QString helpWordUnderCursor();
	QString getActiveText();
    int currentLineNumber();
	bool isModified();
	bool childHasFocus();
	void print(QPrinter *printer);


    void setParsedUDOs(QStringList udos);
    // Global variables scanned by the Inspector (g-prefixed or Csound 7
    // name@global:type); visible from every block.
    void setGlobalVariables(const QStringList &variables);
    void setGlobalStringVariables(const QStringList &variables);
    // Named instruments and widget channels for the context-aware completions.
    void setInstrumentNames(const QStringList &names);
    void setWidgetChannels(const QStringList &channels);
    // Read the current channel names directly from the widget layout. This
    // keeps completion up to date when a widget is renamed, without having to
    // mirror every widget change into this view.
    void setWidgetChannelsProvider(const std::function<QStringList()> &provider);
    QStringList widgetChannels() const;
    // Properties addressable as "<channel>/<property>" for a widget.
    void setWidgetPropertiesProvider(
            const std::function<QList<WidgetPropertyInfo>(const QString &)> &provider);
    QList<WidgetPropertyInfo> widgetProperties(const QString &channelOrName) const;
    // Directory used to resolve relative paths in completion popups.
    void setDocumentDirectoryProvider(const std::function<QString()> &provider);
    QString documentDirectory() const;
    Highlighter* getHighlighter() { return &m_highlighter; }
    void gotoLineDialog();
    void markCurrentPosition();
    // Variables visible in the instrument/opcode block that contains the
    // cursor. Used by the autocomplete popup instead of all words in the
    // document, which would suggest variables from unrelated blocks.
    QStringList getCurrentScopeWords() const;
    // String variables in the current block, for schedule() completion.
    QStringList getCurrentScopeStringVariables() const;
    // Literal channel of the chnget/chnset/invalue/outvalue nearest to the
    // cursor, or empty when it is a variable or expression.
    QString channelAtCursor() const;

	// The Csound name at the cursor in the editor the user is working in, for
	// the "Go to Source" action.
	QString identifierAtCursor() const;
	// True when the cursor is on the first argument of a schedule() or
	// schedulek() call.
	bool isScheduleArgumentAtCursor() const;
	// Jumps to the definition of a name and leaves the cursor on the name.
	void jumpToDefinition(int line, int column);
	// BaseView::setTheme() switches the syntax highlighting; the completion
	// popup is a separate top-level window with colours of its own, so it has
	// to be restyled here too.
	void setTheme(const QString &theme) override;


public slots:
    void setModified(bool mod = true);
    void syntaxCheck();
	void textChanged();
	void escapePressed();
	void finishParameterMode();
	void exitParameterMode();
	void indentNewLine();
	void findReplace();
	// Experimental: outline the widgets that use the channel at the cursor.
	void highlightWidgetChannel();
	// Update the transient outline when the text cursor moves onto/off a
	// channel literal.
	void updateChannelHighlightFromCursor();
	void getToIn(); // chnget/chnset to invalue/outvalue
	void inToGet(); // invalue/outvalue to chnget/chnset
	void insertAutoCompleteText();
    void findString(QString query = QString());
	void findQueryChanged(const QString &query);
	void findNext();
	void findPrevious();
	void replaceCurrent();
	void replaceAll();
	void closeFindBar();
	void showOpcodeInsertBar();
	void evaluate();
	void updateContext();
	void updateOrcContext(QString orc);
	void nextParameter();
	void prevParameter();
	void showHoverText();
	void hideHoverText();
	void updateHoverText(int x, int y, QString text);
	void createContextMenu(QPoint pos);
    void autoCompleteAtCursor();

	void showOrc(bool);
	void showScore(bool);
	void showOptions(bool);
	void showFileB(bool);
	void showOther(bool);
	void showOtherCsd(bool);
	void showWidgetEdit(bool);

	void cut();
	void copy();
	void paste();
	void undo();
	void redo();
	void comment();
	void uncomment();
	void indent();
	void unindent();
	void tabsToSpaces();
	void killLine();
	void killToEnd();

	void markErrorLines(QList<QPair<int, QString> > lines);
	void unmarkErrorLines();
    void jumpToLine(int line, bool mark=true);
    void jumpToLineWithoutFocus(int line);
    void goBackToPreviousPosition();
	void gotoNextLine();
	void opcodeFromMenu();


protected:
	virtual void contextMenuEvent(QContextMenuEvent *event);
	virtual bool eventFilter(QObject *watched, QEvent *event) override;

private:
	QString changeToChnget(QString text);
	QString changeToInvalue(QString text);
	// Channel literal containing the active text cursor, if any.
	QString channelAtTextCursor() const;
	// Reconcile hover/cursor sources and ask the page to update the outline.
	void updateChannelHighlight();
    // Text of the instrument/opcode block containing the cursor, or empty.
    QString currentScopeText() const;

	void ensureFindBar();
	void ensureOpcodeInsertBar();
	void collectFindMatches();
	void updateFindHighlights(bool moveCursor);
	void updateFindStatus();
	void refreshFindAfterEdit();
	void jumpToLineInternal(int line, bool mark, bool focus);
	// The editor the line numbers of the document refer to (the whole
	// document in the unified view, the orchestra in the split view).
	TextEditor *currentLineEditor() const;
	// The editor the user is working in.
	TextEditor *activeEditor() const;
	// The cursor at the given position of the main editor, which is given in
	// the coordinates of that editor.
	QTextCursor cursorAt(const QPoint &pos) const;

	// The string used for one indentation step in the current mode: a tab
	// character, or the configured number of spaces when "use spaces" is on.
	QString indentString() const;

	MySyntaxMenu *syntaxMenu = nullptr;

	HoverWidget *m_hoverWidget;
	QLabel *m_hoverText;
	QString m_currentOpcodeText;
	//QPair<int, int> m_parenspos;

	bool m_isModified;
	bool m_autoComplete;
    int m_autoCompleteDelay = 150;
    // Width of the autocomplete menu, in characters of its entries.
    int m_autoCompleteMenuWidth = 42;
    int m_autoCompleteMenuMaxLines = 20;
    QTimer* m_autoCompleteTimer = nullptr;
    bool m_autoParameterMode;
	bool errorMarked;
	bool internalChange;  // to let popoup opcode completion know if text change was internal
	QTextEdit * m_currentEditor;

	bool lastCaseSensitive; // These last three are for search and replace
	QString lastSearch;
	QString lastReplace;

	// Marks the parenthesis pair next to the cursor; owns the pair state and the
	// document it belongs to.
	BracketMatcher m_bracketMatcher;

	FindBar *m_findBar = nullptr;
	OpcodeInsertBar *m_opcodeInsertBar = nullptr;
	QList<QTextEdit::ExtraSelection> m_findSelections;
	QVector<QPair<int, int>> m_findMatches;
	int m_findCurrent = -1;
	QString m_findQuery;

	QStringList m_localVariables;
	// Global variables collected by the Inspector from the whole document.
	QStringList m_globalVariables;
	QStringList m_globalStringVariables;
	QStringList m_instrumentNames;
	QStringList m_widgetChannels;
	QString m_hoverChannel;
	QString m_activeChannelHighlight;
	std::function<QStringList()> m_widgetChannelsProvider;
	std::function<QList<WidgetPropertyInfo>(const QString &)> m_widgetPropertiesProvider;
	std::function<QString()> m_documentDirectoryProvider;
    int m_lastCursorPosition;
    QStringList m_longOptions = {
        "syntax-check-only", "control-rate=", "messagelevel=",
        "env:", "dither", "sched", "omacro:", "smacro:",
        "verbose", "sample-accurate", "realtime",
        "nchnls=", "nchnls_i=", "sinesize", "daemon",
        "port=", "use-system-sr", "ksmps=",
        "limiter", "udp-echo", "opcode-dir="
    };
    QStringList m_longOptions2 = {"rtmidi", "rtaudio"};

    QStringList delimiters = {")", ",", "\"", "'", "]", "}"};

    // QTime m_lastContextUpdate;

    QList<int> cursorPositions;

	enum {
		ORC_CONTEXT = 0,
		SCO_CONTEXT,
		OPTIONS_CONTEXT,
		PYTHON_CONTEXT,
		NO_CONTEXT
	};
	int m_currentContext;
	int m_oldCursorPosition; // if necessary to move back, like after evaluateSection

private slots:
	void destroySyntaxMenu();
	void opcodeHelp();
	void restoreCursorPosition();

signals:
    void opcodeSyntaxSignal(QString syntax);  // Report syntax of opcode under cursor
	void setHelp(); // Request execute open opcode help action
	void contentsChanged();
	void closeExtraPanels();
	void evaluate(QString code);
    void newLineAndColumn(int line, int column);
    // Request a jump to the definition of a name. The flag tells whether the
    // name is the first argument of a schedule() or schedulek() call.
    void goToSourceRequested(const QString &name, bool isScheduleArgument);
    // Ask the page to outline widgets using this channel. Empty clears any
    // existing outline.
    void channelHighlightRequested(const QString &channel);

};

#endif // DOCUMENTVIEW_H
