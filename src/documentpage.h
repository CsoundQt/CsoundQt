/*
	Copyright (C) 2008-2010 Andres Cabrera
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

#ifndef DOCUMENTPAGE_H
#define DOCUMENTPAGE_H

#include <QtPrintSupport/QPrinter>
#include <QtPrintSupport/QPrintDialog>
#include <QRegularExpression>
#include <QSet>
#include <QTextEdit>
#include <QDomElement>
#include <QStack>
#include <QDockWidget>
#include <vector>
#include "basedocument.h"
#include "channelhighlightmode.h"
#include "codescan.h"
#include "widgetpropertyinfo.h"

class OpEntryParser;
class ScanService;
class DocumentView;
class LiveEventFrame;
class EventSheet;
class LiveEventControl;
class SndfileHandle;
class MidiLearnDialog;
class QuteWidget;

class DocumentPage : public BaseDocument, public CodeScan::Source
{
	Q_OBJECT
public:
	DocumentPage(QWidget *parent, OpEntryParser *opcodeTree, ConfigLists *configlists,
				 MidiLearnDialog *midiLearn);
	~DocumentPage();
	void setCompanionFileName(QString name);
	void setEditorFocus();
	void showLineNumbers(bool show);
	void setLineNumberContrast(int contrast);
	void setEditorPadding(int padding);
	void insertText(QString text, int section = -1);
	// Drag & drop helpers (see BaseView).
	void insertPathAtCursor(const QString &path);
	void insertOrchestraGlobal(QString text);
	void insertAtScoreStart(QString text);
	void setFullText(QString text);
	void setBasicText(QString text);
	void setOrc(QString text);
	void setSco(QString text);
	void setWidgetsText(QString text);
	void setPresetsText(QString text);
	void setOptionsText(QString text);
	void loadTextString(QString &text); // sets the text string and resets the undo history
	int setTextString(QString &text);
	void toggleLineArea();
	void toggleParameterMode();
	void showParametersInEditor();
    void setHighlightingTheme(QString theme);
    void setGlobalVariables(const QStringList &variables);
    void setGlobalStringVariables(const QStringList &variables);
    void setInstrumentNames(const QStringList &names);
    // The document is scanned by the ScanService, which owns the scheduling
    // and hands the results back through these three methods.
    void setScanService(ScanService *service) { m_scanService = service; }
    // The text to scan, as Csound sees it.
    QString scanText() override;
    // How this document is scanned: a .csd between its tags, an orchestra-only
    // document (.orc, .udo, .inc) from its first line, and nothing at all for
    // documents that are not Csound source.
    CodeScan::Mode scanMode() const override;
    // The file on disk, so that relative #include directives can be resolved.
    QString scanFilePath() const override;
    // The configured include path plus the document's own --env:INCDIR
    // options, used for scanning, completion and "Go to Source".
    QStringList includeSearchPaths() override;
    // The configured include path from CsoundQt's settings. The document's
    // own options are added on top by includeSearchPaths().
    void setIncludeSearchPaths(const QStringList &paths) { m_includeSearchPaths = paths; }
    // Apply the result of a scan: highlighting, completion and "Go to Source"
    // all read the same parse of the same text.
    void applyScan(const CodeScan::ResultPtr &scan) override;
    // The call signature and docstring of a user-defined opcode defined here
    // or in one of the included files. Returns false when name is not a UDO;
    // either output pointer may be null.
    bool udoInfo(const QString &name, QString *signature, QString *docstring);
    // The signature and docstring of an instrument defined here or in one of
    // the included files. The signature is the name and the p-fields assigned
    // in the body, and is empty when the instrument has no such assignments.
    // Returns false when name is not an instrument; either output pointer may
    // be null.
    bool instrInfo(const QString &name, QString *signature, QString *docstring);
    // Show an already rendered ad-hoc help page in the floating card. Reserved
    // for Quick Reference; Opcode Entry uses the help panel.
    void showQuickHelp(const QString &title, const QString &html);
    // The same card anchored at a global point, for the ctrl+hover lookup,
    // which shows it next to the mouse instead of the text cursor.
    void showQuickHelpAt(const QString &title, const QString &html,
                         const QPoint &globalAnchor, bool passive = false);
    QStringList getWidgetChannels();
    // Type of a local variable at the given 1-based editor line, from the last
    // scan. Empty when the name is not a variable in that instrument/opcode.
    QString variableTypeAt(int line, const QString &name) const;
    // Local variable types of the instrument/opcode containing line.
    QHash<QString, QString> localVariableTypesAt(int line) const;
    QList<WidgetPropertyInfo> getWidgetProperties(const QString &channelOrName);
    void updateWidgetChannels();
    void enableScoreSyntaxHighlighting(bool status);
    virtual QString getFullText();
	QString getSelectedText(int section = -1);
	QString getSelectedWidgetsText();
	QString getHtmlText();
	QString wordUnderCursor();
    QString lineUnderCursor();
	QRect getWidgetLayoutOuterGeometry();
	void setWidgetLayoutOuterGeometry(QRect r);
	void setChannelValue(QString channel, double value);
	double getChannelValue(QString channel);
	void setChannelString(QString channel, QString value);
	QString getChannelString(QString channel);
	void setWidgetProperty(QString widgetid, QString property, QVariant value);
	QVariant getWidgetProperty(QString widgetid, QString property);
	QStringList getWidgetUuids();
	QStringList listWidgetProperties(QString widgetid); // widgetid can be eihter uuid (prefered) or channel
	bool destroyWidget(QString widgetid);
	void loadPreset(int preSetIndex);
	QString createNewLabel(int x = -1, int y = -1, QString channel = QString());
	QString createNewDisplay(int x = -1, int y = -1, QString channel = QString());
	QString createNewScrollNumber(int x = -1, int y = -1, QString channel = QString());
	QString createNewLineEdit(int x = -1, int y = -1, QString channel = QString());
	QString createNewSpinBox(int x = -1, int y = -1, QString channel = QString());
	QString createNewSlider(int x = -1, int y = -1, QString channel = QString());
	QString createNewButton(int x = -1, int y = -1, QString channel = QString());
	QString createNewKnob(int x = -1, int y = -1, QString channel = QString());
	QString createNewCheckBox(int x = -1, int y = -1, QString channel = QString());
	QString createNewMenu(int x = -1, int y = -1, QString channel = QString());
	QString createNewMeter(int x = -1, int y = -1, QString channel = QString());
	QString createNewConsole(int x = -1, int y = -1, QString channel = QString());
	QString createNewGraph(int x = -1, int y = -1, QString channel = QString());
	QString createNewScope(int x = -1, int y = -1, QString channel = QString());
	int lineCount(bool countExtras = false);
	int characterCount(bool countExtras = false);
	int instrumentCount();
	int udoCount();
	int widgetCount();
	QString embeddedFiles();
	QString getFilePath();
    bool isModified();
	bool isRunning();
	bool isRecording();
	bool usesFltk();
	void focusWidgets();
	QString getFileName();
	QString getCompanionFileName();
	// The file name decides both the highlighting mode and the directory
	// relative #include directives resolve against; changing it invalidates
	// the scan.
	void setFileName(QString name) override;
	// Edition- are routed to section with focus
	void copy();
	void cut();
	void paste();
	void undo();
	void redo();
	void gotoNextRow();
	// Get internal components
	DocumentView *getView();  // Needed to pass view for placing it as tab widget in main application
	//    void *getCsound();
	// Document view properties and actions
	void setTextFont(QFont font);
	void setTabSize(int tabSize);
	void setTabUseSpaces(bool useSpaces);
	void setTabSpaces(int spaces);
	void setLineWrapMode(QTextEdit::LineWrapMode wrapLines);
	void setScrollBarVisible(bool visible);
	void setColorVariables(bool colorVariables);
	//    void setOpcodeNameList(QStringList opcodeNameList);
    void setAutoComplete(bool autoComplete, int delay = 0);
    void setAutoCompleteMenuWidth(int width);
    void setAutoCompleteMenuMaxLines(int lines);
	void setAutoParameterMode(bool autoParameterMode);
	QString getActiveSection();
	QString getActiveText();
	void print(QPrinter *printer);
	void findReplace();
	void findString();  // For find again
	void findPrevious();
	void getToIn();
	void inToGet();
	// Widget Layout properties
	void showWidgetTooltips(bool visible);
	void setKeyRepeatMode(bool keyRepeat);  // Also for console widget
	void setOpenProperties(bool open);
    void setGraphUpdateRate(int rate);
	//    void passWidgetClipboard(QString text);
	// Console properties
	void setConsoleFont(QFont font);
	void setConsoleColors(QColor fontColor, QColor bgColor);
    void setEditorColors(QColor text, QColor background);

	// Internal Options setters
	void setConsoleBufferSize(int size);
	void setWidgetEnabled(bool enabled);
	void setChannelHighlightMode(ChannelHighlightMode mode);
	void setChannelReferenceHighlightMode(ChannelReferenceHighlightMode mode);
	// Show the quick reference card when the pointer rests on an opcode, UDO or
	// instrument; Ctrl+hover works regardless.
	void setQuickHelpOnHover(bool enabled);
	// How long, in milliseconds, the pointer must rest before that card shows.
	void setQuickHelpHoverDelay(int milliseconds);
	// Highlight all occurrences of the selected variable in the current
	// instrument/opcode.
	void setShowVariableOccurrences(bool enabled);
	// Experimental: mark editor lines that reference the selected widget.
	void highlightSelectedWidgetChannels();
	void updateWidgetChannelLineHighlights();
	void togglePinnedWidgetChannelHighlights(const QStringList &channels);
	void clearWidgetChannelHighlights();
	virtual void registerButton(QuteButton *button);
	void queueMidiIn(std::vector<unsigned char> *message);
    void queueVirtualMidiIn(std::vector<unsigned char> &message);
	// Member public variables
	bool askForFile;
	bool readOnly; // Used for manual files and internal examples
	QVector<QString> widgetHistory;  // Undo/ Redo history
    int widgetHistoryIndex; // Current point in history
    QString getQml();
	QString getMidiControllerInstrument();
	// Display name for a document without a file on disk (e.g. one recovered
	// from a previous session). Saving still asks for a real file name.
	QString getTemporaryName() const { return m_temporaryName; }
	void setTemporaryName(const QString &name) { m_temporaryName = name; }
    void gotoLine(int line);
    void gotoLineDialog();
    void goBackToPreviousPosition();
    void autocomplete();
    void insertOpcode();
    // Experimental: outline widgets using the channel at the cursor.
    void highlightWidgetChannel();
    // Jump to the definition of the name at the cursor (a user-defined
    // opcode, a scheduled instrument, a macro or a struct type).
    void goToSourceAtCursor();
    // Resolve an include path against the document and its include search
    // paths, then ask the application to open the file.
    void openIncludedFile(const QString &includePath);

public slots:
	virtual int play(CsoundOptions *options);
	// Jump to the definition of the given name. isScheduleArgument tells
	// whether the name is the first argument of a schedule() or schedulek()
	// call, which is how an instrument is reached. line is the 1-based line of
	// the reference and selects the instrument/opcode block for local variables.
	void goToSource(const QString &name, bool isScheduleArgument, int line = -1);
	void stop();
	int record(int format);
	void perfEnded();
	void sampleRateMismatch(int orchestraSr, int backendSr, const QString &backendName);
	void setHelp();
	void showWidgets(bool show = true);
	void hideWidgets();
	void passSelectedWidget(QuteWidget* widget);
	void passUnselectedWidget(QuteWidget* widget);
	void showMidiLearn(QuteWidget *widget);
    void setModified(bool mod = true);
	// For Csound Engine
	void sendCodeToEngine(QString code);
	//Passed directly to widget layout
	void setWidgetEditMode(bool active);
	// Offline render: stop drawing widgets while keeping their values flowing.
	void setWidgetDrawingEnabled(bool enabled);
	void setWidgetFrameColors(const QColor &unselected, const QColor &selected);
	void duplicateWidgets();
	// Passed directly to document view
	void jumpToLine(int line);
	void jumpToLineWithoutFocus(int line);
	// Jump to a definition: the line of the definition and the column of the
	// name, as reported by the scanner (also used to reach included files).
	void jumpToDefinition(int line, int column);
	void comment();
	void uncomment();
	void tabsToSpaces();
	// Highlight all occurrences of the word at the cursor/selection in the
	// current instrument or opcode (Edit -> Show all occurrences of word).
	void showWordOccurrences();
	void killLine();
	void killToEnd();
	void duplicateLine();
	void moveLineUp();
	void moveLineDown();
	// Register the actions on this page's editor, so their shortcuts only fire
	// while the editor has focus.
	void applyEditorActions(const QList<QAction *> &actions);


private:
	virtual void init(QWidget *parent,OpEntryParser *opcodeTree);
	CsoundOptions getParentOptions();
	virtual WidgetLayout* newWidgetLayout();
	QString companionFile;
	QString m_temporaryName;
	MidiLearnDialog *m_midiLearn;
	//    DocumentView *m_view;
	// Options
	bool saveLiveEvents;
    QString m_colorTheme;
    // Names of the user-defined opcodes in the last scan, so that the
    // highlighter is only re-run when that set actually changed.
    QSet<QString> m_parsedUdos;
    // Local variable types from the last scan, used to decide whether the
    // highlighter needs to run again.
    QString m_localVariableSignature;
    // The last scan of this document, as applied by the ScanService.
    CodeScan::ResultPtr m_scan = CodeScan::empty();
    ScanService *m_scanService = nullptr;
    // The include path from CsoundQt's settings (not the document's own).
    QStringList m_includeSearchPaths;
	ChannelReferenceHighlightMode m_channelReferenceHighlightMode = ChannelReferenceHighlightMode::Always;
	bool m_widgetChannelHighlightPinned = false;
	QStringList m_pinnedWidgetChannels;

private slots:
	void textChanged();

signals:
	void setCurrentAudioFile(QString name);
    //void liveEventsVisible(bool);  // To change the action in the main window
	void modified();  // Triggered whenever the children change
    void unmodified();
    void stopSignal(); // To tell main application that running has stopped
	void setHelpSignal(); // Propagated from view
    // The definition at line/column is in an included file: the application
    // has to open that file and jump there.
    void goToSourceFileRequested(const QString &file, int line, int column);
	void setWidgetClipboardSignal(QString text);
};

#endif
