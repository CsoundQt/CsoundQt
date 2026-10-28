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
#include "channelhighlightmode.h"

#include <QKeyEvent> // For syntax menu class
#include <QPair>
#include <QSet>
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
	// The editor that receives keys typed while the popup has the focus.
	void setKeyTarget(QWidget *target) { m_keyTarget = target; }

	// (Re)apply the popup's style for the current application palette. Called
	// by DocumentView::setTheme() so a theme switch does not leave the popup
	// with the colours of the previous one; does nothing when the light/dark
	// state has not changed.
	void applyStyle();

signals:
	// A key that continues the completion was forwarded to the editor while
	// the popup stayed open. The view uses this to debounce a list update.
	void completionKeyForwarded();

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
	QWidget *m_keyTarget = nullptr; // editor that receives forwarded keys
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

	// TODO add all text inputs here as below

	QString getSelectedText(int section = -1);

	// These two should be used with care as they are only here in case
	// Widgets are being edited in text format. In most cases, you want to
	// get the widgets Text from the widget layout object
	QString getWidgetsText(); // With tags including presets, in new xml format

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
	// Re-runs the syntax highlighter. Applying formats makes the editors emit
	// textChanged(), which is not an edit: it is swallowed here.
	void rehighlightSyntax();

    // Global variables scanned by the Inspector (g-prefixed or Csound 7
    // name@global:type); visible from every block.
    void setGlobalVariables(const QStringList &variables);
    void setGlobalStringVariables(const QStringList &variables);
    // Named instruments and widget channels for the context-aware completions.
    void setInstrumentNames(const QStringList &names);
    // Names of the user-defined opcodes in the current scan. Help and the
    // "nearest opcode before the cursor" lookup treat them like built-ins.
    void setUdoNames(const QStringList &names);
    void setWidgetChannels(const QStringList &channels);
    // Show an ad-hoc help page (a docstring, an instrument's fields or an
    // opcode reference) in the floating card near the cursor. Used by the
    // Quick Reference action; Opcode Entry uses the help panel.
    void showQuickHelp(const QString &title, const QString &html);
    // The same card, anchored at a point given in global coordinates: the
    // ctrl+hover lookup shows it next to the mouse rather than the cursor, and
    // passive so that it does not take the focus away from the editor.
    void showQuickHelpAt(const QString &title, const QString &html,
                         const QPoint &globalAnchor, bool passive = false);
    // How channel literals in the editor outline their widgets.
    void setChannelHighlightMode(ChannelHighlightMode mode);
    // Show the quick reference card when the pointer rests on a help name.
    // Ctrl+hover shows it in either state; this switch only decides whether the
    // modifier is needed.
    void setQuickHelpOnHover(bool enabled) { m_quickHelpOnHover = enabled; }
    // How long the pointer must rest on a help name before the card appears
    // without Ctrl. Ctrl+hover ignores this and shows it at once.
    void setQuickHelpHoverDelay(int milliseconds)
    { m_quickHelpHoverDelay = qMax(0, milliseconds); }
    // Experimental: mark all lines that reference any of these widget channels.
    void highlightWidgetChannels(const QStringList &channels,
                                 bool jumpToFirstReference = false);
    void clearWidgetChannelHighlights();
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
    // Directories searched for #include names (the configured INCDIR plus
    // the document's --env:INCDIR options).
    void setIncludeSearchPathsProvider(const std::function<QStringList()> &provider);
    QStringList includeSearchPaths() const;
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
	// The file name of an #include directive when the cursor is inside its
	// delimiters, or empty.
	QString includePathAtCursor() const;
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
    // (Re)start the debounce timer that runs autoCompleteAtCursor. While the
    // popup is visible it is called with COMPLETION_UPDATE_DELAY_MS so fast
    // typing only filters the list after the user pauses.
    void scheduleAutoComplete(int delay);

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
	void duplicateLine();
	void moveLineUp();
	void moveLineDown();
	// Swap the current line with its neighbour: offset -1 is the line above,
	// +1 the line below.
	void moveLine(int offset);
	// Associate these actions with this view's editor. Their shortcuts are
	// widget-scoped, so they only fire while the editor has focus.
	void applyEditorActions(const QList<QAction *> &actions);

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
	QString channelAtTextCursor();
	// Same for an arbitrary cursor, with a last-span cache to avoid
	// re-tokenizing the line on every mouse move inside one channel name.
	QString channelAtCursorPosition(const QTextCursor &cursor);
	// Reconcile hover/cursor sources and ask the page to update the outline.
	void updateChannelHighlight();
	// Extra editor selections shared by syntaxCheck() and the find bar.
	QList<QTextEdit::ExtraSelection> extraSelectionsFor(
			TextEditor *editor) const;
    // Ctrl+hover: the help name under a viewport position, or empty when there
    // is none or it is quoted.
    QString hoverHelpWordAt(TextEditor *editor, const QPoint &viewportPos) const;
    // Whether help exists for this name (opcode, UDO or instrument).
    bool isHelpName(const QString &name) const;
    // Ask for the quick reference of the name under the pointer, the first
    // time the pointer enters it. Ctrl+hover (immediate) shows the card at
    // once; a plain hover waits for the configured delay instead.
    void requestHoverHelp(TextEditor *editor, const QPoint &viewportPos,
                          bool immediate);
    // Show the card for a name, and start tracking the pointer while it stays
    // on that name.
    void showHoverHelp(TextEditor *editor, const QString &word,
                       const QPoint &viewportPos);
    // The hover delay elapsed: show the card if the pointer is still there.
    void showPendingHoverHelp();
    // Drop a waiting hover card; the name itself is not remembered.
    void cancelPendingHoverHelp();
    // While the ctrl+hover card is up: close it once the pointer leaves the
    // name. Escape closes it too, and it is not reopened for that name.
    void checkHoverHelp();
    void stopHoverHelpTracking();
    // Text of the instrument/opcode block containing the cursor, or empty.
    QString currentScopeText() const;

	void ensureFindBar();
	void ensureOpcodeInsertBar();
	void cancelAutoCompleteOnCursorMove();
	void collectFindMatches();
	void updateFindHighlights(bool moveCursor);
	void updateFindStatus();
	void refreshFindAfterEdit();
	void jumpToLineInternal(int line, bool mark, bool focus);
	// The editor the line numbers of the document refer to.
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
    int m_autoCompleteCursorPosition = -1;
    int m_autoCompleteCursorAnchor = -1;
    // The editor the popup was opened for: accepting an item has to insert
    // into that editor, not into whichever widget has focus by then (the
    // popup itself takes the focus).
    TextEditor *m_autocompleteEditor = nullptr;
    // The token start and editor of the popup currently on screen. While the
    // user keeps typing the same token the popup stays where it is; it is only
    // moved when a new completion session starts.
    int m_autocompleteAnchor = -1;
    TextEditor *m_autocompleteAnchorEditor = nullptr;
    bool m_autoParameterMode;
	bool errorMarked;
	bool internalChange;  // to let popoup opcode completion know if text change was internal
	// True while the highlighter applies formats, whose textChanged()
	// notifications must not be mistaken for edits.
	bool m_highlightUpdate = false;

	bool lastCaseSensitive; // These last three are for search and replace
	QString lastSearch;
	QString lastReplace;

	// Marks the parenthesis pair next to the cursor; owns the pair state and the
	// document it belongs to.
	BracketMatcher m_bracketMatcher;

	FindBar *m_findBar = nullptr;
	OpcodeInsertBar *m_opcodeInsertBar = nullptr;
	class DocstringPopup *m_docstringPopup = nullptr;
	// Ctrl+hover quick reference: the card follows the pointer while it stays
	// on one name, so the name and its editor are remembered while it is up.
	// A name dismissed with Escape is not reopened until the pointer moves on.
	QTimer *m_hoverHelpTimer = nullptr;
	QString m_hoverHelpWord;
	QString m_hoverHelpDismissedWord;
	QPointer<TextEditor> m_hoverHelpEditor;
	// The name of the last card actually shown: a lookup can find no page for
	// a name, and then there is nothing to track.
	QString m_quickHelpShownWord;
	// Whether the card also appears without Ctrl (Settings/Editor/Behavior).
	bool m_quickHelpOnHover = true;
	// Delay, in milliseconds, before a plain hover shows the card.
	int m_quickHelpHoverDelay = 500;
	// A plain hover that is waiting out the delay: the name and editor it was
	// asked for. The timer is single-shot and restarted when the name changes.
	QTimer *m_hoverHelpDelayTimer = nullptr;
	QString m_hoverHelpPendingWord;
	QPointer<TextEditor> m_hoverHelpPendingEditor;
	QList<QTextEdit::ExtraSelection> m_findSelections;
	QList<QTextEdit::ExtraSelection> m_widgetChannelSelections;
	TextEditor *m_widgetChannelEditor = nullptr;
	QVector<QPair<int, int>> m_findMatches;
	int m_findCurrent = -1;
	QString m_findQuery;

	QStringList m_localVariables;
	// Global variables collected by the Inspector from the whole document.
	QStringList m_globalVariables;
	QStringList m_globalStringVariables;
	QStringList m_instrumentNames;
	QSet<QString> m_udoNames;
	QStringList m_widgetChannels;
	ChannelHighlightMode m_channelHighlightMode = ChannelHighlightMode::CursorOnly;
	enum class ChannelHighlightSource { None, Cursor, Mouse };
	ChannelHighlightSource m_channelHighlightSource = ChannelHighlightSource::None;
	QString m_hoverChannel;
	QString m_activeChannelHighlight;
	QString m_cachedChannel;
	QTextBlock m_cachedChannelBlock;
	int m_cachedBlockRevision = -1;
	int m_cachedChannelStart = -1;
	int m_cachedChannelEnd = -1;
	// Per-document cache of "line contains a channel opcode", keyed by block
	// number. Cleared whenever the document revision changes.
	QHash<int, bool> m_channelLineCache;
	QTextDocument *m_channelLineCacheDocument = nullptr;
	int m_channelLineCacheRevision = -1;
	std::function<QStringList()> m_widgetChannelsProvider;
	std::function<QList<WidgetPropertyInfo>(const QString &)> m_widgetPropertiesProvider;
	std::function<QString()> m_documentDirectoryProvider;
	std::function<QStringList()> m_includeSearchPathsProvider;
    int m_lastCursorPosition;

    QStringList delimiters = {")", ",", "\"", "'", "]", "}"};

    // QTime m_lastContextUpdate;

    QList<int> cursorPositions;

	enum {
		ORC_CONTEXT = 0,
		SCO_CONTEXT,
		OPTIONS_CONTEXT,
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
    // The cursor is inside an #include path: resolve the included file.
    void goToSourceIncludeRequested(const QString &path);
    // Ask the page to outline widgets using this channel. Empty clears any
    // existing outline.
    void channelHighlightRequested(const QString &channel);
    // The user pressed Escape in the editor; pages use this to clear their
    // pinned widget-channel highlight state as well as the extra selections.
    void editorEscapePressed();
    // Ctrl+hover over an opcode, UDO or instrument: ask for its quick
    // reference, anchored at the mouse. The card stays while the pointer is on
    // the name, and until Escape.
    void quickReferenceRequested(const QString &word, const QPoint &globalAnchor);

};

#endif // DOCUMENTVIEW_H
