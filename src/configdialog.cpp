
/*
	Copyright (C) 2008, 2009 Andres Cabrera
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

#include <QDir>
#include <algorithm>
//#include <QOperatingSystemVersion> // not present before Qt 5.9
#include <QDesktopServices>
#include <QFile>
#include <QMessageBox>
#include <QSysInfo>
#include <QStandardItemModel>
#include <QUrl>

#include "csoundqt.h"
#include "configdialog.h"
#include "options.h"
#include "widgetstyle.h"
#include "types.h"
#include "configlists.h"
#include "debuglog.h"
#include "editorthemes.h"
#include "externallauncher.h"
#include "keyboardshortcuts.h"
using namespace Qt::StringLiterals;


typedef QPair<QString, QString> QStringPair;

// PortAudio does not expose the device channel count reliably enough for the
// "Device" setup method, so that method is disabled for these modules.
static bool isPortAudioModule(const QString &module)
{
    return module == "pa_cb"_L1 || module == "pa_bl"_L1
            || module == "portaudio"_L1;
}

#ifdef CSQT_RTMIDI
#include "RtMidi.h"
#endif

static int channelHighlightIndex(ChannelHighlightMode mode)
{
	switch (mode) {
	case ChannelHighlightMode::Never: return 0;
	case ChannelHighlightMode::CursorOnly: return 1;
	case ChannelHighlightMode::MouseOnly: return 2;
	case ChannelHighlightMode::Full: return 3;
	}
	return 3;
}

static ChannelHighlightMode channelHighlightModeFromIndex(int index)
{
	switch (index) {
	case 0: return ChannelHighlightMode::Never;
	case 1: return ChannelHighlightMode::CursorOnly;
	case 2: return ChannelHighlightMode::MouseOnly;
	case 3: return ChannelHighlightMode::Full;
	}
	return ChannelHighlightMode::CursorOnly;
}

static int channelReferenceHighlightIndex(ChannelReferenceHighlightMode mode)
{
	switch (mode) {
	case ChannelReferenceHighlightMode::Never: return 0;
	case ChannelReferenceHighlightMode::EditMode: return 1;
	case ChannelReferenceHighlightMode::NotPerforming: return 2;
	case ChannelReferenceHighlightMode::Always: return 3;
	}
	return 2;
}

static ChannelReferenceHighlightMode channelReferenceHighlightModeFromIndex(int index)
{
	switch (index) {
	case 0: return ChannelReferenceHighlightMode::Never;
	case 1: return ChannelReferenceHighlightMode::EditMode;
	case 2: return ChannelReferenceHighlightMode::NotPerforming;
	case 3: return ChannelReferenceHighlightMode::Always;
	}
	return ChannelReferenceHighlightMode::NotPerforming;
}

ConfigDialog::ConfigDialog(CsoundQt *parent, Options *options, ConfigLists *configlists,
						   const QVector<QAction *> &keyActions,
						   const QHash<QAction *, QKeySequence> &defaultShortcuts)
	: QDialog(parent), m_parent(parent), m_options(options), m_configlists(configlists)
{
	setupUi(this);
    // don't expand over screen, leave some room for panels
    setMaximumSize(  QGuiApplication::primaryScreen()->geometry().width()  * 0.9,
                   QGuiApplication::primaryScreen()->geometry().height() * 0.9);

    m_shortcutsWidget = new KeyboardShortcutsWidget(this, keyActions, defaultShortcuts);
    shortcutsTabLayout->addWidget(m_shortcutsWidget);
    connect(m_shortcutsWidget, &KeyboardShortcutsWidget::restoreDefaultShortcuts,
            this, &ConfigDialog::restoreDefaultShortcuts);

    // "Tab Size" applies in both modes: it is the width of a tab character and,
    // when spaces are inserted, the number of spaces a Tab press inserts.

    // "Apply" must copy the widget values before the main window applies them.
    // (The main window connects its applySettings() slot to the same signal.)
    connect(applyButton, &QPushButton::released, this, &ConfigDialog::apply);

	if(m_configlists->rtAudioNames.size() == 1) {
		QMessageBox::warning(this, tr("No Audio Modules"),
                             tr("No real-time audio modules were found.\n"
                                "Make sure OPCODE7DIR64 is set properly in your system"
                                "or the configuration dialog."));
	}
    const bool jackNotRunning = m_configlists->rtAudioNames.contains("jack"_L1)
            && !m_configlists->isJackRunning();

    if(m_configlists->rtAudioNames.contains("jack")) {
        if(jackNotRunning)
            JackNameLineEdit->setEnabled(false);
    } else {
        JackNameLineEdit->setEnabled(false);
    }
	foreach (QString item, m_configlists->renderFileTypeLongNames) {
		FileTypeComboBox->addItem(item);
	}
	foreach (QString item, m_configlists->rtAudioNames) {
		QString display = ConfigLists::audioModuleDisplayName(item);
		if (item == "jack"_L1 && jackNotRunning)
			display += tr(" (not running)");
		RtModuleComboBox->addItem(display, item);
	}
	foreach (QString item, m_configlists->rtMidiNames) {
		if (item == "virtual"_L1)
			continue;
		// Do not probe every MIDI backend while constructing the dialog. Device
		// enumeration can block (and creates a temporary Csound instance); the
		// selected backend's devices are queried when its lists are populated.
		RtMidiModuleComboBox->addItem(item, item);
	}
	for (int i = 0; i < m_configlists->languages.size(); i++) {
        languageComboBox->addItem(m_configlists->languages[i],
                                  QVariant(m_configlists->languageCodes[i]));
	}
	fontComboBox->setCurrentIndex(fontComboBox->findText(m_options->font) );
	fontSizeSpinBox->setValue(m_options->fontPointSize);
	codePadFontSizeSpinBox->setValue(m_options->codePadFontPointSize);
	lineNumbersCheckBox->setChecked(m_options->showLineNumberArea);
	lineNumberContrastSpinBox->setValue(m_options->lineNumberContrast);

	consoleFontComboBox->setCurrentIndex(consoleFontComboBox->findText(m_options->consoleFont) );
	consoleFontSizeSpinBox->setValue(m_options->consoleFontPointSize);
	QPixmap pixmap(64,64);
	pixmap.fill(m_options->consoleFontColor);
	consoleFontColorPushButton->setIcon(pixmap);
	QPalette palette(m_options->consoleFontColor);
	consoleFontColorPushButton->setPalette(palette);

	pixmap.fill(m_options->consoleBgColor);
	consoleBgColorPushButton->setIcon(pixmap);
	palette = QPalette(m_options->consoleBgColor);
	consoleBgColorPushButton->setPalette(palette);

	pixmap.fill(m_options->editorBgColor);
    // editorBgColorButton->setIcon(pixmap);
	palette = QPalette(m_options->editorBgColor);
    // editorBgColorButton->setPalette(palette);

	// Edit-mode widget frame colours (the unselected one carries an alpha).
	QPixmap framePixmap(64, 64);
	framePixmap.fill(m_options->widgetFrameColorUnselected);
	frameColorUnselectedButton->setIcon(framePixmap);
	framePixmap.fill(m_options->widgetFrameColorSelected);
	frameColorSelectedButton->setIcon(framePixmap);

	tabUseSpacesCheckBox->setChecked(m_options->tabUseSpaces);
	tabSizeSpinBox->setValue(m_options->tabSpaces);
	editorPaddingSpinBox->setValue(m_options->editorPadding);

    // allow translations for highlightingThemeComboBox and themeCombobox
    // NB! make sure that the strings are the same as in configdialog.ui
    // highlightingThemeComboBox->setItemData(0, "light");
    // highlightingThemeComboBox->setItemData(1, "dark");
    // highlightingThemeComboBox->setItemData(2, "classic");
    // highlightingThemeComboBox->setItemData(3, "none");
    // highlightingThemeComboBox->setCurrentIndex(highlightingThemeComboBox->findData(m_options->highlightingTheme));


    themeComboBox->setItemData(0, "auto");
    themeComboBox->setItemData(1, "dark");
    themeComboBox->setItemData(2, "light");
    themeComboBox->setCurrentIndex(themeComboBox->findData(m_options->themeMode));

    // The user may have edited or added theme JSON files while the dialog was
    // closed. Rescan the theme folder so the editor theme list is current.
    EditorThemes::refresh();
    populateEditorThemes();
    connect(duplicateThemeButton, &QPushButton::clicked,
            this, &ConfigDialog::duplicateEditorTheme);
    connect(openThemesFolderButton, &QPushButton::clicked,
            this, &ConfigDialog::openThemesFolder);
    lineNumberContrastSpinBox->setEnabled(lineNumbersCheckBox->isChecked());
    connect(lineNumbersCheckBox, &QCheckBox::toggled,
            lineNumberContrastSpinBox, &QWidget::setEnabled);
    // The hover delay only means something while the card appears on hover.
    quickHelpOnHoverDelaySpinBox->setEnabled(quickHelpOnHoverCheckBox->isChecked());
    connect(quickHelpOnHoverCheckBox, &QCheckBox::toggled,
            quickHelpOnHoverDelaySpinBox, &QWidget::setEnabled);
    connect(editorThemeComboBox, &QComboBox::currentIndexChanged,
            this, [this](int) {
        duplicateThemeButton->setEnabled(
                    editorThemeComboBox->currentData().toString() != "auto");
    });

    // Qt widget styles available on this platform, minus the hidden legacy
    // styles (see widgetstyle.h). Fusion is offered first as the recommended,
    // fully palette-driven style; the remaining styles keep Qt's own order.
    QStringList styleKeys = availableWidgetStyleNames();
    for (int i = 0; i < styleKeys.size(); ++i) {
        if (styleKeys.at(i).compare(u"Fusion"_s, Qt::CaseInsensitive) == 0) {
            styleKeys.move(i, 0);
            break;
        }
    }
    for (const QString &key : styleKeys)
        widgetStyleComboBox->addItem(key, key);
    bool haveFusion = false;
    for (int i = 0; i < widgetStyleComboBox->count(); ++i) {
        if (widgetStyleComboBox->itemData(i).toString()
                .compare(u"Fusion"_s, Qt::CaseInsensitive) == 0) {
            haveFusion = true;
            break;
        }
    }
    if (!haveFusion)
        widgetStyleComboBox->addItem(u"Fusion"_s, u"Fusion"_s);

    // Select the configured style. When none is configured yet (or the
    // configured one is hidden), show the style that is actually in use (the
    // platform default).
    QString wanted = m_options->widgetStyle;
    if (wanted.isEmpty() || isHiddenWidgetStyle(wanted))
        wanted = currentWidgetStyleName();
    if (isHiddenWidgetStyle(wanted))
        wanted.clear();
    int styleIndex = -1;
    for (int i = 0; i < widgetStyleComboBox->count(); ++i) {
        if (widgetStyleComboBox->itemData(i).toString()
                .compare(wanted, Qt::CaseInsensitive) == 0) {
            styleIndex = i;
            break;
        }
    }
    // Keep a configured style that is no longer available selectable, so saving
    // the dialog does not silently change it.
    if (styleIndex < 0 && !wanted.isEmpty()) {
        widgetStyleComboBox->addItem(wanted, wanted);
        styleIndex = widgetStyleComboBox->count() - 1;
    }
    if (styleIndex < 0)
        styleIndex = 0;
    widgetStyleComboBox->setCurrentIndex(styleIndex);
    tabFontSizeSpinBox->setValue(m_options->tabFontSizeOffset);



	autoJoinCheckBox->setChecked(m_options->autoJoin);
	menusDepthSpinBox->setValue(m_options->menuDepth);
	saveChangesCheckBox->setChecked(m_options->saveChanges);
	rememberFileCheckBox->setChecked(m_options->rememberFile);
	widgetsIndependentCheckBox->setChecked(m_options->widgetsIndependent);
	channelHighlightModeComboBox->setCurrentIndex(
				channelHighlightIndex(m_options->channelHighlightMode));
	channelReferenceHighlightModeComboBox->setCurrentIndex(
				channelReferenceHighlightIndex(m_options->channelReferenceHighlightMode));
	iconTextCheckBox->setChecked(m_options->iconText);
	toolbarCheckBox->setChecked(m_options->showToolbar);
    lockToolbarCheckBox->setChecked(m_options->lockToolbar);
    toolbarIconSizeSpinBox->setValue(m_options->toolbarIconSize);
	wrapLinesCheckBox->setChecked(m_options->wrapLines);
	autoCompleteCheckBox->setChecked(m_options->autoComplete);
    quickHelpOnHoverCheckBox->setChecked(m_options->quickHelpOnHover);
    quickHelpOnHoverDelaySpinBox->setValue(m_options->quickHelpHoverDelay);
    showVariableOccurrencesCheckBox->setChecked(m_options->showVariableOccurrences);
    autoCompleteDelaySpinBox->setValue(m_options->autoCompleteDelay);
    autocompleteMenuWidthSpinBox->setValue(m_options->autocompleteMenuWidth);
    autocompleteMenuMaxLinesSpinBox->setValue(m_options->autocompleteMenuMaxLines);

	autoParameterModeCheckBox->setChecked(m_options->autoParameterMode);
	widgetsCheckBox->setChecked(m_options->enableWidgets);
	midiCcToCurrentPageOnlyCheckBox->setChecked(m_options->midiCcToCurrentPageOnly);
	showWidgetsOnRunCheckBox->setChecked(m_options->showWidgetsOnRun);
	showTooltipsCheckBox->setChecked(m_options->showTooltips);
    graphUpdateRateSpinBox->setValue(m_options->graphUpdateRate);
	openPropertiesCheckBox->setChecked(m_options->openProperties);
    tabShortcutActiveCheckBox->setChecked(m_options->tabShortcutActive);
    tabCloseButtonCheckBox->setChecked(m_options->tabShowCloseButton);
    highlightScoreCheckBox->setChecked(m_options->highlightScore);

	noMessagesCheckBox->setChecked(m_options->noMessages);
	noBufferCheckBox->setChecked(m_options->noBuffer);
	noEventsCheckBox->setChecked(m_options->noEvents);

	//  threadCheckBox->setChecked(m_options->thread);
	keyRepeatCheckBox->setChecked(m_options->keyRepeat);
	debugLiveEventsCheckBox->setChecked(m_options->debugLiveEvents);
	int bufferIndex = consoleBufferComboBox->findText(QString::number(m_options->consoleBufferSize));
	if (bufferIndex < 0) {
		bufferIndex = consoleBufferComboBox->count() - 1;
	}
	consoleBufferComboBox->setCurrentIndex(bufferIndex);

    checkSyntaxBeforeRunCheckBox->setChecked(m_options->checkSyntaxBeforeRun);

	BufferSizeLineEdit->setText(QString::number(m_options->bufferSize));
	BufferSizeCheckBox->setChecked(m_options->bufferSizeActive);
	BufferSizeLineEdit->setEnabled(m_options->bufferSizeActive);
	HwBufferSizeLineEdit->setText(QString::number(m_options->HwBufferSize));
	HwBufferSizeCheckBox->setChecked(m_options->HwBufferSizeActive);
	HwBufferSizeLineEdit->setEnabled(m_options->HwBufferSizeActive);
	fallbackDbfsCheckBox->setChecked(m_options->fallbackDbfs);
    // DitherCheckBox->setChecked(m_options->dither);
    // newParserCheckBox->setChecked(m_options->newParser);
	multicoreCheckBox->setChecked(m_options->multicore);
	numThreadsSpinBox->setValue(m_options->numThreads);
	AdditionalFlagsCheckBox->setChecked(m_options->additionalFlagsActive);
	AdditionalFlagsLineEdit->setText(m_options->additionalFlags);
	AdditionalFlagsLineEdit->setEnabled(m_options->additionalFlagsActive);
	FileUseOptionsCheckBox->setChecked(m_options->fileUseOptions);
	FileOverrideCheckBox->setChecked(m_options->fileOverrideOptions);
	AskFilenameCheckBox->setChecked(m_options->fileAskFilename);
	const int fileTypeIndex = qBound(0, m_options->fileFileType,
	                                 FileTypeComboBox->count() - 1);
	FileTypeComboBox->setCurrentIndex(fileTypeIndex);
	populateSampleFormats(m_options->fileSampleFormat);
	connect(FileTypeComboBox, &QComboBox::currentIndexChanged,
	        this, [this](int) { populateSampleFormats(); });
	// Keep the Recording group's sample-format combo in the same visual
	// column as the Offline Rendering sample-format combo. The latter's
	// label column is as wide as its widest widget, so use that width as a
	// minimum for the Recording label.
	int offlineLabelColumnWidth = 0;
	const auto considerLabelWidth = [&offlineLabelColumnWidth](QWidget *widget) {
		offlineLabelColumnWidth = qMax(offlineLabelColumnWidth,
		                               widget->sizeHint().width());
	};
	considerLabelWidth(FileUseOptionsCheckBox);
	considerLabelWidth(FileOverrideCheckBox);
	considerLabelWidth(label_9);
	considerLabelWidth(label_10);
	considerLabelWidth(AskFilenameCheckBox);
	considerLabelWidth(DisableDisplaysCheckBox);
	recordingSampleFormatLabel->setMinimumWidth(offlineLabelColumnWidth);
	DisableDisplaysCheckBox->setChecked(m_options->disableDisplaysOnRender);
	RtOverrideCheckBox->setChecked(m_options->rtOverrideOptions);
	int index = RtModuleComboBox->findData(m_options->rtAudioModule);
	if (index < 0 || index >= RtModuleComboBox->count()) {
		index = 0;
	}
    RtModuleComboBox->setCurrentIndex(index);
    connect(RtModuleComboBox, SIGNAL(currentIndexChanged(int)),
            this, SLOT(onRtModuleComboBoxChanged(int)) );

    const QString module = RtModuleComboBox->currentData().toString();
	RtInputLineEdit->setText(
	            m_configlists->audioDeviceDisplayName(module, false, m_options->rtInputDevice));
	RtOutputLineEdit->setText(
	            m_configlists->audioDeviceDisplayName(module, true, m_options->rtOutputDevice));
	selectDefaultAudioDeviceIfNeeded(false);
	selectDefaultAudioDeviceIfNeeded(true);
	updateAudioDeviceControls();
	updateSamplerateComboBox();

    channelsSetupMethod->clear();
    channelsSetupMethod->addItem(tr("Device"), int(ChannelsSetupMethod::Device));
    channelsSetupMethod->addItem(tr("Override"), int(ChannelsSetupMethod::Override));
    channelsSetupMethod->addItem(tr("Orchestra"), int(ChannelsSetupMethod::Orchestra));
    int channelsMethodIndex = channelsSetupMethod->findData(int(m_options->channelsSetupMethod));
    if (channelsMethodIndex < 0)
        channelsMethodIndex = channelsSetupMethod->findData(int(ChannelsSetupMethod::Device));
    channelsSetupMethod->setCurrentIndex(channelsMethodIndex);
    connect(channelsSetupMethod, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, [this](int) { updateChannelControls(); });
    resetChannelsMethodForBackend();

    numChannelsSpinBox->setMinimum(0);
    numChannelsSpinBox->setMaximum(64);
    m_overrideOutputChannels = m_options->numChannels;
    numChannelsSpinBox->setValue(m_overrideOutputChannels);

    numInputChannelsSpinBox->setMinimum(0);
    numInputChannelsSpinBox->setMaximum(64);
    m_overrideInputChannels = m_options->numInputChannels;
    numInputChannelsSpinBox->setValue(m_overrideInputChannels);
    connect(numChannelsSpinBox, QOverload<int>::of(&QSpinBox::valueChanged),
            this, [this](int value) {
        if (static_cast<ChannelsSetupMethod>(channelsSetupMethod->currentData().toInt())
                == ChannelsSetupMethod::Override) {
            m_overrideOutputChannels = value;
        }
    });
    connect(numInputChannelsSpinBox, QOverload<int>::of(&QSpinBox::valueChanged),
            this, [this](int value) {
        if (static_cast<ChannelsSetupMethod>(channelsSetupMethod->currentData().toInt())
                == ChannelsSetupMethod::Override) {
            m_overrideInputChannels = value;
        }
    });
    updateChannelControls();

    ksmpsComboBox->clear();
    for (int value : {16, 32, 64, 128, 256, 512})
        ksmpsComboBox->addItem(QString::number(value), value);
    int ksmpsIndex = ksmpsComboBox->findData(m_options->ksmps);
    if (ksmpsIndex < 0)
        ksmpsIndex = ksmpsComboBox->findData(64);
    ksmpsComboBox->setCurrentIndex(ksmpsIndex);
    ksmpsSpinBox->setValue(m_options->ksmps);
    ksmpsOrchestraCheckBox->setChecked(m_options->ksmpsUseOrchestra);
    connect(ksmpsOrchestraCheckBox, &QCheckBox::toggled,
            this, [this](bool) { updateKsmpsControls(); });
    updateKsmpsControls();

    realtimeCheckBox->setChecked(m_options->realtimeFlag);
    sampleAccurateCheckBox->setChecked(m_options->sampleAccurateFlag);

    //limiter
    bool limiterAvailable = csoundGetVersion()>=6160;
    limiterCheckBox->setEnabled(limiterAvailable);
    limiterSpinBox->setEnabled(limiterAvailable);
    if (limiterAvailable) {
        limiterCheckBox->setChecked(m_options->useLimiter);
        limiterSpinBox->setValue(m_options->limitValue);
    }

	JackNameLineEdit->setText(m_options->rtJackName);
	int midiModuleIndex = RtMidiModuleComboBox->findData(m_options->rtMidiModule);
	if (midiModuleIndex < 0)
		midiModuleIndex = RtMidiModuleComboBox->findText("none"_L1);
	if (midiModuleIndex < 0)
		midiModuleIndex = 0;
	RtMidiModuleComboBox->setCurrentIndex(midiModuleIndex);
	connect(RtMidiModuleComboBox, &QComboBox::currentIndexChanged,
	        this, [this](int) {
		if (!internalMidiCheckBox->isChecked())
			updateMidiDeviceLists();
	});
	{
		// This is the initial state, not a user toggle: do not let the
		// auto-connected toggled() slot query the devices and then query them
		// again below.
		const QSignalBlocker blocker(internalMidiCheckBox);
		internalMidiCheckBox->setChecked(!m_options->useCsoundMidi);
	}
	updateMidiDeviceLists();
	simultaneousCheckBox->setChecked(m_options->simultaneousRun);
	quitOnLastTabClosedCheckBox->setChecked(m_options->quitOnLastTabClosed);
	includeActiveFileInTitleCheckBox->setChecked(m_options->includeActiveFileInTitle);
	focusToggledPanelCheckBox->setChecked(m_options->focusToggledPanel);

	sampleFormatComboBox->setCurrentIndex(m_options->sampleFormat);
	debugPortSpinBox->setValue(m_options->debugPort);

	CsdocdirLineEdit->setText(m_options->csdocdir);
    Opcode7dir64LineEdit->setText(m_options->opcode7dir64);
    Opcode7dir64CheckBox->setChecked(m_options->opcode7dir64Active);
	SadirCheckBox->setChecked(m_options->sadirActive);
	SadirLineEdit->setText(m_options->sadir);
	SsdirCheckBox->setChecked(m_options->ssdirActive);
	SsdirLineEdit->setText(m_options->ssdir);
	IncdirCheckBox->setChecked(m_options->incdirActive);
	IncdirLineEdit->setText(m_options->incdir);
	//  defaultCsdCheckBox->setChecked(m_options->defaultCsdActive);
	//  defaultCsdLineEdit->setText(m_options->defaultCsd);
	//  defaultCsdLineEdit->setEnabled(m_options->defaultCsdActive);
    examplePathlineEdit->setText(m_options->examplePath);
	csoundExecutableLineEdit->setText(m_options->csoundExecutable);
	RenderFolderLineEdit->setText(m_options->renderFolder);
	logDebugCheckBox->setChecked(m_options->logDebug);

	TerminalLineEdit->setText(m_options->terminal);
#if defined(FLATPAK_BUILD)
    // Inside a flatpak the terminal set here is not accessible; the bundled
    // terminal is always used. Disable the widgets to make it obvious
    // that this setting has no effect within a flatpak.
    TerminalLineEdit->setText(QStringLiteral(FLATPAK_TERM_EXECUTABLE));
    TerminalLineEdit->setEnabled(false);
    terminalToolButton->setEnabled(false);
    terminalLabel->setEnabled(false);
#endif
	browserLineEdit->setText(m_options->browser);
#if defined(FLATPAK_BUILD)
    // Inside a flatpak URLs are always opened through the freedesktop portal;
    // a browser configured here cannot be launched from the sandbox. Disable
    // the widgets to make it obvious that this setting has no effect.
    browserLineEdit->setText(QString());
    browserLineEdit->setEnabled(false);
    browserToolButton->setEnabled(false);
    label_20->setEnabled(false);
#endif
	WaveEditorLineEdit->setText(m_options->waveeditor);
	WavePlayerLineEdit->setText(m_options->waveplayer);
	languageComboBox->setCurrentIndex(m_options->language);

	templateTextEdit->setPlainText(m_options->csdTemplate);

    connect(csdocdirToolButton, SIGNAL(clicked()), this, SLOT(browseCsdocdir()));
    connect(opcode7dir64ToolButton, SIGNAL(clicked()), this, SLOT(browseOpcode7dir64())); // was commented out - why?
	connect(sadirToolButton, SIGNAL(clicked()), this, SLOT(browseSadir()));
	connect(ssdirToolButton, SIGNAL(clicked()), this, SLOT(browseSsdir()));
	connect(incdirToolButton, SIGNAL(clicked()), this, SLOT(browseIncdir()));
	connect(renderFolderToolButton, SIGNAL(clicked()), this, SLOT(browseRenderFolder()));
	//  connect(defaultCsdToolButton, SIGNAL(clicked()), this, SLOT(browseDefaultCsd()));
    connect(examplePathToolButton, SIGNAL(clicked()), this, SLOT(browseExamplePath()) );
    connect(terminalToolButton, SIGNAL(clicked()), this, SLOT(browseTerminal()));
	connect(browserToolButton, SIGNAL(clicked()), this, SLOT(browseBrowser()));
	connect(waveEditorToolButton, SIGNAL(clicked()), this, SLOT(browseWaveEditor()));
	connect(wavePlayerToolButton, SIGNAL(clicked()), this, SLOT(browseWavePlayer()));
	connect(logDebugCheckBox, &QCheckBox::toggled, this, &ConfigDialog::updateLogPathLabel);
	connect(openLogToolButton, &QToolButton::clicked, this, &ConfigDialog::openDebugLog);
	updateLogPathLabel();

	//  connect(this, SIGNAL(changeFont()), parent, SLOT(changeFont()));
	connect(audioInputToolButton, SIGNAL(released()), this, SLOT(selectAudioInput()));
	connect(audioOutputToolButton, SIGNAL(released()), this, SLOT(selectAudioOutput()));
	connect(RtOutputLineEdit, &QLineEdit::editingFinished,
	        this, &ConfigDialog::updateSamplerateComboBox);
	connect(RtOutputLineEdit, &QLineEdit::editingFinished,
	        this, &ConfigDialog::updateChannelControls);
	connect(RtInputLineEdit, &QLineEdit::editingFinished,
	        this, &ConfigDialog::updateChannelControls);
	connect(consoleFontColorPushButton, SIGNAL(released()), this, SLOT(selectTextColor()));
	connect(consoleBgColorPushButton, SIGNAL(released()), this, SLOT(selectBgColor()));
    // connect(editorBgColorButton, SIGNAL(released()), this, SLOT(selectEditorBgColor()));
	connect(frameColorUnselectedButton, SIGNAL(released()), this, SLOT(selectWidgetFrameColorUnselected()));
	connect(frameColorSelectedButton, SIGNAL(released()), this, SLOT(selectWidgetFrameColorSelected()));

	connect(clearTemplatePushButton,SIGNAL(released()), this, SLOT(clearTemplate()));
	connect(defaultTemplatePushButton,SIGNAL(released()), this, SLOT(defaultTemplate()));

    // connect(OpcodedirCheckBox, SIGNAL(toggled(bool)), this, SLOT(warnOpcodeDir(bool)));
    // connect(Opcodedir64CheckBox, SIGNAL(toggled(bool)), this, SLOT(warnOpcodeDir(bool)));
    // connect(Opcode6dir64CheckBox, SIGNAL(toggled(bool)), this, SLOT(uDir(bool)));

	connect(csoundExecutableToolButton,SIGNAL(clicked()),this, SLOT(browseCsoundExecutable()));

    connect(testAudioSetupButton, SIGNAL(released()), this, SLOT(testAudioSetup()));
    // connect(envirRecommendButton, SIGNAL(clicked()), this, SLOT(recommendEnvironmentSettings()));


    m_selectedOutputDeviceIndex = -1;
}

ConfigDialog::~ConfigDialog()
{
}

void ConfigDialog::populateSampleFormats(const QString &preferredFlag)
{
    const QString previous = preferredFlag.isEmpty()
            ? FileFormatComboBox->currentData().toString()
            : preferredFlag;
    FileFormatComboBox->clear();
    const QString fileType = m_configlists->renderFileTypeNames.value(
                FileTypeComboBox->currentIndex());
    const QStringList flags = m_configlists->sampleFormatFlagsForFileType(fileType);
    for (const QString &flag : flags) {
        const int nameIndex = m_configlists->fileFormatFlags.indexOf(flag);
        const QString name = nameIndex >= 0
                ? m_configlists->fileFormatNames.value(nameIndex)
                : flag;
        FileFormatComboBox->addItem(name, flag);
    }
    int index = FileFormatComboBox->findData(previous);
    if (index < 0)
        index = 0;
    FileFormatComboBox->setCurrentIndex(index);
}

void ConfigDialog::populateEditorThemes()
{
    const QString wanted = editorThemeComboBox->currentData().toString().isEmpty()
            ? m_options->editorTheme
            : editorThemeComboBox->currentData().toString();

    editorThemeComboBox->clear();
    editorThemeComboBox->addItem(tr("auto"), "auto");
    for (const QString &name : EditorThemes::builtInNames())
        editorThemeComboBox->addItem(name, name);
    for (const QString &name : EditorThemes::jsonThemeNames())
        editorThemeComboBox->addItem(name, name);

    int index = editorThemeComboBox->findData(wanted);
    if (index < 0)
        index = editorThemeComboBox->findData(m_options->editorTheme);
    editorThemeComboBox->setCurrentIndex(index < 0 ? 0 : index);
    duplicateThemeButton->setEnabled(
                editorThemeComboBox->currentData().toString() != "auto");
}

void ConfigDialog::duplicateEditorTheme()
{
    const QString name = editorThemeComboBox->currentData().toString();
    if (name.isEmpty() || name == "auto"_L1)
        return;

    QString error;
    const QString newName = EditorThemes::duplicateTheme(name, &error);
    if (newName.isEmpty()) {
        QMessageBox::warning(this, tr("Duplicate theme"),
                             error.isEmpty()
                             ? tr("Could not duplicate the theme.")
                             : error);
        return;
    }

    populateEditorThemes();
    const int index = editorThemeComboBox->findData(newName);
    if (index >= 0)
        editorThemeComboBox->setCurrentIndex(index);

    const QString dirPath = EditorThemes::userThemeDir();
    QMessageBox box(this);
    box.setIcon(QMessageBox::Information);
    box.setWindowTitle(tr("Theme duplicated"));
    box.setText(tr("A copy of the theme \"%1\" was created as \"%2\" in:\n%3")
                .arg(name, newName, QDir::toNativeSeparators(dirPath)));
    box.setInformativeText(tr("You can edit the JSON file in that folder."));
    QPushButton *openButton = box.addButton(tr("Open Theme Folder"),
                                            QMessageBox::ActionRole);
    QPushButton *okButton = box.addButton(QMessageBox::Ok);
    // Esc dismisses the dialog without opening the folder, just like Ok.
    box.setEscapeButton(okButton);
    box.exec();
    if (box.clickedButton() == openButton)
        openThemesFolder();
}

void ConfigDialog::openThemesFolder()
{
    const QString dirPath = EditorThemes::userThemeDir();
    QDir().mkpath(dirPath);
    QString error;
    if (!ExternalLauncher::openFolder(dirPath, &error,
                                      u"themes-folder"_s)) {
        QMessageBox::warning(this, tr("Open Themes Folder"),
                             error.isEmpty()
                             ? tr("Could not open the themes folder:\n%1").arg(dirPath)
                             : error);
    }
}

void ConfigDialog::onRtModuleComboBoxChanged(int index) {
    Q_UNUSED(index);
    // Todo: remember the settings for each backend in a hash table, and set it to the last
    // known value when changed back. Otherwise set it to the default adc/dac
    const QString module = RtModuleComboBox->currentData().toString();
    if(module == "null") {
        RtInputLineEdit->setText("");
        RtOutputLineEdit->setText("");
    } else if (module == "jack") {
        RtInputLineEdit->setText("adc");
        RtOutputLineEdit->setText("dac");
    } else if ((module == "pa_cb" || module == "pa_bl") && QSysInfo::productType()=="osx" ) { // on newer Mac's the internal microphone has 1 channel and that causes problems for portaudio. Disable input by default
			qDebug() << "Set audio input to none for portaudio on MacOS";
			RtInputLineEdit->setText("");
			RtOutputLineEdit->setText("dac");
	} else {
        RtInputLineEdit->setText("adc");
        RtOutputLineEdit->setText("dac");
    }
    selectDefaultAudioDeviceIfNeeded(false);
    selectDefaultAudioDeviceIfNeeded(true);
    resetChannelsMethodForBackend();
    updateSamplerateComboBox();
    updateAudioDeviceControls();
    updateChannelControls();
    updateKsmpsControls();
}

void ConfigDialog::updateSamplerateComboBox()
{
    const QString module = RtModuleComboBox->currentData().toString();
    const QSignalBlocker blocker(samplerateComboBox);
    samplerateComboBox->clear();

    if (m_configlists->isFixedSamplerateBackend(module)) {
        int sampleRate = -1;
        if (ConfigLists::isPerDeviceSamplerateBackend(module)) {
            const QString device = m_configlists->audioDeviceIdForDisplay(
                        module, true, RtOutputLineEdit->text());
            if (!device.isEmpty())
                sampleRate = m_configlists->deviceSamplerate(module, device, true);
        }
        if (sampleRate <= 0)
            sampleRate = m_configlists->backendSamplerate(module);
        if (sampleRate > 0)
            samplerateComboBox->addItem(QString::number(sampleRate), sampleRate);
        else
            samplerateComboBox->addItem(tr("Fixed by system"), 0);
        samplerateComboBox->setCurrentIndex(0);
        samplerateComboBox->setEnabled(false);
        // Show fixed rates as a non-editable value, visually distinct from the
        // surrounding static text.
        QFont fixedFont = samplerateValueLineEdit->font();
        fixedFont.setBold(true);
        samplerateValueLineEdit->setFont(fixedFont);
        samplerateValueLineEdit->setText(samplerateComboBox->itemText(0));
        samplerateValueLineEdit->setToolTip(samplerateComboBox->toolTip());
        samplerateValueLineEdit->setMinimumHeight(samplerateComboBox->sizeHint().height());
        samplerateComboBox->hide();
        samplerateValueLineEdit->show();
    } else {
        const bool isAlsa = module == "alsa"_L1;
        const bool isPortAudio = module == "pa_cb"_L1
                || module == "pa_bl"_L1
                || module == "portaudio"_L1;
        QList<int> rates = {44100, 48000, 88200, 96000};
        int nativeRate = -1;
        if ((isAlsa || isPortAudio) && m_configlists->isPipeWireRunning()) {
            nativeRate = m_configlists->pipeWireSamplerate();
            if (nativeRate > 0 && !rates.contains(nativeRate)) {
                rates.append(nativeRate);
                std::sort(rates.begin(), rates.end());
            }
        }
        if (!isAlsa)
            samplerateComboBox->addItem(tr("Orchestra"), 0);
        for (int sampleRate : rates) {
            const QString text = sampleRate == nativeRate
                    ? tr("%1 (native)").arg(sampleRate)
                    : QString::number(sampleRate);
            samplerateComboBox->addItem(text, sampleRate);
        }
        int index = -1;
        if (isAlsa) {
            int preferred = m_options->samplerate;
            if (preferred <= 0)
                preferred = nativeRate;
            if (preferred > 0)
                index = samplerateComboBox->findData(preferred);
            if (index < 0 && nativeRate > 0)
                index = samplerateComboBox->findData(nativeRate);
            if (index < 0)
                index = 0;
        } else {
            index = samplerateComboBox->findData(m_options->samplerate);
            if (index < 0)
                index = 0;
        }
        samplerateComboBox->setCurrentIndex(index);
        samplerateComboBox->setEnabled(true);
        samplerateValueLineEdit->hide();
        samplerateComboBox->show();
    }
}

int ConfigDialog::currentTab()
{
	return editorTabWidget->currentIndex();
}

void ConfigDialog::warnOpcodeDir(bool on)
{
	if (on) {
		QMessageBox::warning(this, "CsoundQt",
							 tr("Please note that OPCODEDIR and OPCODEDIR64 will overwrite current settings so you will need to restart CsoundQt to return to default.")
							 );
	}
}

void ConfigDialog::setCurrentTab(int index)
{
	if (index >= 0 && index < editorTabWidget->count()) {
		editorTabWidget->setCurrentIndex(index);
	}
}

bool ConfigDialog::shortcutsModified() const
{
	return m_shortcutsWidget != nullptr && m_shortcutsWidget->needsSave();
}

void ConfigDialog::accept()
{
	apply();
	QDialog::accept();
}

void ConfigDialog::apply()
{
	m_options->font = fontComboBox->currentText();
	m_options->fontPointSize = qBound(MIN_EDITOR_FONT_POINT_SIZE,
	                                  fontSizeSpinBox->value(),
	                                  MAX_EDITOR_FONT_POINT_SIZE);
	m_options->codePadFontPointSize = qBound(MIN_EDITOR_FONT_POINT_SIZE,
	                                         codePadFontSizeSpinBox->value(),
	                                         MAX_EDITOR_FONT_POINT_SIZE);
	m_options->showLineNumberArea = lineNumbersCheckBox->isChecked();
	m_options->lineNumberContrast = lineNumberContrastSpinBox->value();
	m_options->consoleFont = consoleFontComboBox->currentText();
	m_options->consoleFontPointSize = consoleFontSizeSpinBox->value();
	m_options->tabUseSpaces = tabUseSpacesCheckBox->isChecked();
	m_options->tabSpaces = tabSizeSpinBox->value();
	m_options->editorPadding = editorPaddingSpinBox->value();

    // deal with localized themes:
    m_options->themeMode = themeComboBox->currentData().toString();    // to allow to be translated
    m_options->editorTheme = editorThemeComboBox->currentData().toString();
    m_options->widgetStyle = widgetStyleComboBox->currentData().toString();
    m_options->tabFontSizeOffset = tabFontSizeSpinBox->value();

	m_options->autoJoin = autoJoinCheckBox->isChecked();
	m_options->menuDepth = menusDepthSpinBox->value();
	m_options->saveChanges = saveChangesCheckBox->isChecked();
	m_options->widgetsIndependent = widgetsIndependentCheckBox->isChecked();
	m_options->channelHighlightMode =
			channelHighlightModeFromIndex(channelHighlightModeComboBox->currentIndex());
	m_options->channelReferenceHighlightMode =
			channelReferenceHighlightModeFromIndex(
				channelReferenceHighlightModeComboBox->currentIndex());
	m_options->rememberFile = rememberFileCheckBox->isChecked();
	m_options->iconText = iconTextCheckBox->isChecked();
	m_options->showToolbar = toolbarCheckBox->isChecked();
    m_options->lockToolbar = lockToolbarCheckBox->isChecked();
    m_options->toolbarIconSize = toolbarIconSizeSpinBox->value();
	m_options->wrapLines = wrapLinesCheckBox->isChecked();
	m_options->autoComplete = autoCompleteCheckBox->isChecked();
	m_options->quickHelpOnHover = quickHelpOnHoverCheckBox->isChecked();
	// Keep the delay on the spin box grid even when a value was typed in.
	m_options->quickHelpHoverDelay =
			(quickHelpOnHoverDelaySpinBox->value() / 10) * 10;
	m_options->showVariableOccurrences = showVariableOccurrencesCheckBox->isChecked();
    m_options->autoCompleteDelay = autoCompleteDelaySpinBox->value();
    m_options->autocompleteMenuWidth = autocompleteMenuWidthSpinBox->value();
    m_options->autocompleteMenuMaxLines = autocompleteMenuMaxLinesSpinBox->value();
	m_options->autoParameterMode = autoParameterModeCheckBox->isChecked();
	m_options->enableWidgets = widgetsCheckBox->isChecked();
	m_options->midiCcToCurrentPageOnly = midiCcToCurrentPageOnlyCheckBox->isChecked();
	m_options->showWidgetsOnRun = showWidgetsOnRunCheckBox->isChecked();
	m_options->showTooltips = showTooltipsCheckBox->isChecked();
	m_options->openProperties = openPropertiesCheckBox->isChecked();
    m_options->graphUpdateRate = graphUpdateRateSpinBox->value();
	m_options->debugPort = debugPortSpinBox->value();
    m_options->tabShortcutActive = tabShortcutActiveCheckBox->isChecked();
    m_options->tabShowCloseButton = tabCloseButtonCheckBox->isChecked();
	//  m_options->thread = threadCheckBox->isChecked();
	m_options->keyRepeat = keyRepeatCheckBox->isChecked();
	m_options->debugLiveEvents = debugLiveEventsCheckBox->isChecked();
	m_options->consoleBufferSize = consoleBufferComboBox->itemText(consoleBufferComboBox->currentIndex()).toInt();
	const bool internalMidi = internalMidiCheckBox->isChecked();
	m_options->useCsoundMidi = !internalMidi;
	m_options->rtMidiModule = RtMidiModuleComboBox->currentData().toString();
	if (internalMidi) {
		m_options->midiInterface = midiInterfaceComboBox->currentData().toInt();
		m_options->midiInterfaceName = midiInterfaceComboBox->currentText();
		m_options->midiOutInterface = midiOutInterfaceComboBox->currentData().toInt();
		m_options->midiOutInterfaceName = midiOutInterfaceComboBox->currentText();
	} else {
		m_options->rtMidiInputDevice = midiInterfaceComboBox->currentData().toString();
		m_options->rtMidiOutputDevice = midiOutInterfaceComboBox->currentData().toString();
	}
	m_options->noMessages = noMessagesCheckBox->isChecked();
	m_options->noBuffer = noBufferCheckBox->isChecked();
	m_options->noEvents = noEventsCheckBox->isChecked();
	if (m_options->consoleBufferSize < 0)
		m_options->consoleBufferSize = 0;
	m_options->bufferSize = BufferSizeLineEdit->text().toInt();
	m_options->bufferSizeActive = BufferSizeCheckBox->isChecked();
	m_options->HwBufferSize = HwBufferSizeLineEdit->text().toInt();
	m_options->HwBufferSizeActive = HwBufferSizeCheckBox->isChecked();
	m_options->fallbackDbfs = fallbackDbfsCheckBox->isChecked();
    // m_options->dither = DitherCheckBox->isChecked();
    m_options->realtimeFlag = realtimeCheckBox->isChecked(); // this was empty after = ?
    // m_options->newParser = newParserCheckBox->isChecked() ? 1 : 0;
    m_options->useLimiter = limiterCheckBox->isEnabled() && limiterCheckBox->isChecked();
    m_options->limitValue = limiterSpinBox->value();
	m_options->multicore = multicoreCheckBox->isChecked();
	m_options->numThreads = numThreadsSpinBox->value();
	m_options->additionalFlags = AdditionalFlagsLineEdit->text();
	m_options->additionalFlagsActive = AdditionalFlagsCheckBox->isChecked();
	m_options->fileUseOptions = FileUseOptionsCheckBox->isChecked();
	m_options->fileOverrideOptions = FileOverrideCheckBox->isChecked();
	m_options->fileAskFilename = AskFilenameCheckBox->isChecked();
	m_options->fileFileType = FileTypeComboBox->currentIndex();
	m_options->fileSampleFormat = FileFormatComboBox->currentData().toString();
	m_options->disableDisplaysOnRender = DisableDisplaysCheckBox->isChecked();
	m_options->rtOverrideOptions = RtOverrideCheckBox->isChecked();
    m_options->rtAudioModule = RtModuleComboBox->itemData(
                RtModuleComboBox->currentIndex()).toString();
	m_options->rtInputDevice = m_configlists->audioDeviceIdForDisplay(
	            m_options->rtAudioModule, false, RtInputLineEdit->text());
	m_options->rtOutputDevice = m_configlists->audioDeviceIdForDisplay(
	            m_options->rtAudioModule, true, RtOutputLineEdit->text());
	m_options->rtJackName = JackNameLineEdit->text();
    m_options->samplerate = samplerateComboBox->currentData().toInt();
    m_options->channelsSetupMethod = static_cast<ChannelsSetupMethod>(
                channelsSetupMethod->currentData().toInt());
    const int selectedOutputChannels = selectedDeviceChannels(true);
    const int selectedInputChannels = selectedDeviceChannels(false);
    m_options->deviceNumChannels = selectedOutputChannels >= 0 ? selectedOutputChannels : 2;
    m_options->deviceNumInputChannels = selectedInputChannels >= 0 ? selectedInputChannels : 2;
    if (m_options->channelsSetupMethod == ChannelsSetupMethod::Override) {
        m_overrideOutputChannels = numChannelsSpinBox->value();
        m_overrideInputChannels = numInputChannelsSpinBox->value();
        m_options->numChannels = m_overrideOutputChannels;
        m_options->numInputChannels = m_overrideInputChannels;
    }
    if (ConfigLists::isFixedKsmpsModule(m_options->rtAudioModule)) {
        m_options->ksmps = ksmpsComboBox->currentData().toInt();
        m_options->ksmpsUseOrchestra = false;
    } else if (ConfigLists::isSelectableKsmpsModule(m_options->rtAudioModule)) {
        m_options->ksmps = ksmpsSpinBox->value();
        m_options->ksmpsUseOrchestra = ksmpsOrchestraCheckBox->isChecked();
    }
    m_options->realtimeFlag = realtimeCheckBox->isChecked();
    m_options->sampleAccurateFlag = sampleAccurateCheckBox->isChecked();

	m_options->simultaneousRun = simultaneousCheckBox->isChecked();
	m_options->quitOnLastTabClosed = quitOnLastTabClosedCheckBox->isChecked();
	m_options->includeActiveFileInTitle = includeActiveFileInTitleCheckBox->isChecked();
	m_options->focusToggledPanel = focusToggledPanelCheckBox->isChecked();

	m_options->sampleFormat = sampleFormatComboBox->currentIndex();

	m_options->csdocdir = CsdocdirLineEdit->text();
    m_options->opcode7dir64Active = Opcode7dir64CheckBox->isChecked();
    m_options->opcode7dir64 = Opcode7dir64LineEdit->text();
	m_options->sadirActive = SadirCheckBox->isChecked();
	m_options->sadir = SadirLineEdit->text();
	m_options->ssdirActive = SsdirCheckBox->isChecked();
	m_options->ssdir = SsdirLineEdit->text();
	m_options->incdirActive = IncdirCheckBox->isChecked();
	m_options->incdir = IncdirLineEdit->text();
	//  m_options->defaultCsdActive = defaultCsdCheckBox->isChecked();
	//  m_options->defaultCsd = defaultCsdLineEdit->text();
    m_options->examplePath = examplePathlineEdit->text();
	m_options->csoundExecutable = csoundExecutableLineEdit->text();
	m_options->renderFolder = RenderFolderLineEdit->text();
	m_options->logDebug = logDebugCheckBox->isChecked();

	m_options->terminal = TerminalLineEdit->text();
	m_options->browser = browserLineEdit->text();
	m_options->waveeditor = WaveEditorLineEdit->text();
	m_options->waveplayer = WavePlayerLineEdit->text();
	m_options->language = languageComboBox->currentIndex();

	m_options->csdTemplate = templateTextEdit->toPlainText();
    m_options->checkSyntaxBeforeRun = checkSyntaxBeforeRunCheckBox->isChecked();
    m_options->highlightScore = highlightScoreCheckBox->isChecked();

	//  emit(changeFont());
}

void ConfigDialog::browseRenderFolder()
{
	browseDir(m_options->renderFolder);
	RenderFolderLineEdit->setText(m_options->renderFolder);
}

void ConfigDialog::browseCsdocdir()
{
	browseDir(m_options->csdocdir);
	CsdocdirLineEdit->setText(m_options->csdocdir);
}


void ConfigDialog::browseOpcode7dir64()
{
	browseDir(m_options->opcode7dir64);
    Opcode7dir64LineEdit->setText(m_options->opcode7dir64);
}

void ConfigDialog::browseSadir()
{
	browseDir(m_options->sadir);
	SadirLineEdit->setText(m_options->sadir);
}

void ConfigDialog::browseSsdir()
{
	browseDir(m_options->ssdir);
	SsdirLineEdit->setText(m_options->ssdir);
}

void ConfigDialog::browseIncdir()
{
	browseDir(m_options->incdir);
	IncdirLineEdit->setText(m_options->incdir);
}

void ConfigDialog::browseCsoundExecutable()
{
	browseFile(m_options->csoundExecutable);
	csoundExecutableLineEdit->setText(m_options->csoundExecutable);
}

//void ConfigDialog::browseDefaultCsd()
//{
//  browseFile(m_options->defaultCsd);
//  if (!m_options->defaultCsd.endsWith(".csd")) {
//    QMessageBox::warning(this, tr("CsoundQt"),
//                         tr("Only files with extension .csd are accepted"));
//    return;
//  }
//  defaultCsdLineEdit->setText(m_options->defaultCsd);
//}

void ConfigDialog::browseExamplePath()
{
    browseDir(m_options->examplePath);
    examplePathlineEdit->setText(m_options->examplePath);
}

void ConfigDialog::browseTerminal()
{
	browseFile(m_options->terminal);
	TerminalLineEdit->setText(m_options->terminal);
}

void ConfigDialog::browseBrowser()
{
	browseFile(m_options->browser);
	browserLineEdit->setText(m_options->browser);
}

void ConfigDialog::browseWaveEditor()
{
	browseFile(m_options->waveeditor);
	WaveEditorLineEdit->setText(m_options->waveeditor);
}

void ConfigDialog::browseWavePlayer()
{
	browseFile(m_options->waveplayer);
	WavePlayerLineEdit->setText(m_options->waveplayer);
}

void ConfigDialog::openDebugLog()
{
	const QString path = DebugLog::filePath();
	if (!QFile::exists(path)) {
		QMessageBox::information(this, tr("CsoundQt"),
								 tr("No log file exists yet.\n\n"
									"The log file is created when \"Log debug info\" "
									"is enabled:\n%1").arg(path));
		return;
	}
	if (!QDesktopServices::openUrl(QUrl::fromLocalFile(path))) {
		QMessageBox::warning(this, tr("CsoundQt"),
							 tr("Could not open the log file:\n%1").arg(path));
	}
}

void ConfigDialog::updateLogPathLabel()
{
	const bool enabled = logDebugCheckBox->isChecked();
	logPathLabel->setVisible(enabled);
	logPathLabel->setText(enabled ? DebugLog::filePath() : QString());
	logPathLabel->setToolTip(enabled ? DebugLog::filePath() : QString());
}

QList<AudioDeviceInfo> ConfigDialog::cachedAudioDeviceGroups(bool isOutput)
{
	const QString module = RtModuleComboBox->currentData().toString();
	const QString inKey = module + u"|in"_s;
	const QString outKey = module + u"|out"_s;
	if (!m_audioDeviceCache.contains(inKey)
	        || !m_audioDeviceCache.contains(outKey)) {
		const QPair<QList<AudioDeviceInfo>, QList<AudioDeviceInfo>> both =
		        m_configlists->audioDeviceGroups(module);
		m_audioDeviceCache.insert(inKey, both.first);
		m_audioDeviceCache.insert(outKey, both.second);
	}
	return m_audioDeviceCache.value(isOutput ? outKey : inKey);
}

void ConfigDialog::selectAudioInput()
{
    const QString module = RtModuleComboBox->currentData().toString();
    QVector<QStringPair> entries;

    const QList<AudioDeviceInfo> devices = cachedAudioDeviceGroups(false);
    for (const AudioDeviceInfo &device : devices) {
        QStringList details;
        if (module != "jack"_L1 && !device.id.isEmpty())
            details.append(device.id);
        if (device.channels > 0)
            details.append(tr("%1 ch").arg(device.channels));
        QString text = device.name;
        if (!details.isEmpty())
            text += QStringLiteral("  (") + details.join(QStringLiteral(", "))
                    + QLatin1Char(')');
        entries.append(QStringPair(text, device.id));
    }

    if (module == "jack"_L1) {
        entries.prepend(QStringPair("Do Not Autoconnect", "adc:null"));
        if (m_configlists->isPipeWireRunning())
            entries.prepend(QStringPair("All Hardware Inputs", "adc:.*:capture_.*"));
        else
            entries.prepend(QStringPair("System Inputs", "adc:system:capture_"));
    }
    entries.prepend(QStringPair("Disabled", ""));

    QMenu menu(audioInputToolButton);
    QVector<QAction*> actions;
    const QString currentText = RtInputLineEdit->text();
    QString currentSelection;
    for (const AudioDeviceInfo &device : devices) {
        if (device.name == currentText) {
            currentSelection = device.id;
            break;
        }
    }
    if (currentSelection.isEmpty())
        currentSelection = currentText;
    for (const QStringPair &entry : entries) {
        QString option = entry.first;
        if (currentSelection == entry.second)
            option.prepend("> ");
        actions.append(menu.addAction(option));
    }

    const QPoint pos = audioInputToolButton->mapToGlobal(
                QPoint(0, audioInputToolButton->height()));
    const int index = actions.indexOf(menu.exec(pos));
    if (index >= 0) {
        const QString id = entries[index].second;
        QString display = id;
        for (const AudioDeviceInfo &device : devices) {
            if (device.id == id) {
                display = device.name;
                break;
            }
        }
        RtInputLineEdit->setText(display);
        updateChannelControls();
    }
}

void ConfigDialog::selectAudioOutput()
{
    const QString module = RtModuleComboBox->currentData().toString();
    QVector<QStringPair> entries;

    const QList<AudioDeviceInfo> devices = cachedAudioDeviceGroups(true);
    for (const AudioDeviceInfo &device : devices) {
        QStringList details;
        if (module != "jack"_L1 && !device.id.isEmpty())
            details.append(device.id);
        if (device.channels > 0)
            details.append(tr("%1 ch").arg(device.channels));
        QString text = device.name;
        if (!details.isEmpty())
            text += QStringLiteral("  (") + details.join(QStringLiteral(", "))
                    + QLatin1Char(')');
        entries.append(QStringPair(text, device.id));
    }

    if (module == "jack"_L1) {
        entries.prepend(QStringPair("Do Not Autoconnect", "dac:null"));
        if (m_configlists->isPipeWireRunning())
            entries.prepend(QStringPair("All Hardware Outputs", "dac:.*:playback_.*"));
        else
            entries.prepend(QStringPair("System Outputs", "dac:system:playback_"));
    }
    entries.append(QStringPair("Disabled", ""));

    QMenu menu(this);
    QVector<QAction*> actions;
    const QString currentText = RtOutputLineEdit->text();
    QString currentSelection;
    for (const AudioDeviceInfo &device : devices) {
        if (device.name == currentText) {
            currentSelection = device.id;
            break;
        }
    }
    if (currentSelection.isEmpty())
        currentSelection = currentText;
    for (const QStringPair &entry : entries) {
        QString option = entry.first;
        if (currentSelection == entry.second)
            option.prepend("> ");
        actions.append(menu.addAction(option));
    }

    const QPoint pos = audioOutputToolButton->mapToGlobal(
                QPoint(0, audioOutputToolButton->height()));
    const int index = actions.indexOf(menu.exec(pos));
    if (index >= 0) {
        const QString id = entries[index].second;
        QString display = id;
        for (const AudioDeviceInfo &device : devices) {
            if (device.id == id) {
                display = device.name;
                break;
            }
        }
        RtOutputLineEdit->setText(display);
        updateSamplerateComboBox();
        updateChannelControls();
    }
}

void ConfigDialog::browseFile(QString &destination)
{
    QString file =  QFileDialog::getOpenFileName(this,tr("Select File"),destination);
	if (file!="")
		destination = file;
}

void ConfigDialog::browseSaveFile(QString &destination)
{
    QString file =  QFileDialog::getSaveFileName(this,tr("Select File"),destination);
	if (file!="")
		destination = file;
}

void ConfigDialog::browseDir(QString &destination)
{
    QString dir =  QFileDialog::getExistingDirectory(this,tr("Select Directory"),destination);
	if (dir!="")
		destination = dir;
}


void ConfigDialog::selectTextColor()
{
	QColor color = QColorDialog::getColor(m_options->consoleFontColor, this);
	if (color.isValid()) {
		m_options->consoleFontColor = color;
		QPixmap pixmap (64,64);
		pixmap.fill(m_options->consoleFontColor);
		consoleFontColorPushButton->setIcon(pixmap);
		QPalette palette(m_options->consoleFontColor);
		consoleFontColorPushButton->setPalette(palette);
	}
}

void ConfigDialog::selectBgColor()
{
	QColor color = QColorDialog::getColor(m_options->consoleBgColor, this);
	if (color.isValid()) {
		m_options->consoleBgColor = color;
		QPixmap pixmap (64,64);
		pixmap.fill(m_options->consoleBgColor);
		consoleBgColorPushButton->setIcon(pixmap);
		QPalette palette(m_options->consoleBgColor);
		consoleBgColorPushButton->setPalette(palette);
	}
}


void ConfigDialog::selectEditorBgColor()
{
	QColor color = QColorDialog::getColor(m_options->editorBgColor, this);
	if (color.isValid()) {
		m_options->editorBgColor = color;
		QPixmap pixmap (64,64);
		pixmap.fill(m_options->editorBgColor);
        // editorBgColorButton->setIcon(pixmap);
		QPalette palette(m_options->editorBgColor);
        // editorBgColorButton->setPalette(palette);
	}
}


void ConfigDialog::selectWidgetFrameColorUnselected()
{
	// Opacity is part of the colour (ShowAlphaChannel).
	QColor color = QColorDialog::getColor(m_options->widgetFrameColorUnselected, this,
	                                      tr("Widget frame colour (unselected)"),
	                                      QColorDialog::ShowAlphaChannel);
	if (color.isValid()) {
		m_options->widgetFrameColorUnselected = color;
		QPixmap pixmap(64, 64);
		pixmap.fill(color);
		frameColorUnselectedButton->setIcon(pixmap);
	}
}

void ConfigDialog::selectWidgetFrameColorSelected()
{
	QColor color = QColorDialog::getColor(m_options->widgetFrameColorSelected, this,
	                                      tr("Widget frame colour (selected)"));
	if (color.isValid()) {
		m_options->widgetFrameColorSelected = color;
		QPixmap pixmap(64, 64);
		pixmap.fill(color);
		frameColorSelectedButton->setIcon(pixmap);
	}
}

void ConfigDialog::clearTemplate()
{
	templateTextEdit->clear();
}

void ConfigDialog::defaultTemplate()
{
	QString defaultText = CSQT_DEFAULT_TEMPLATE;
	templateTextEdit->setPlainText(defaultText );
}

int ConfigDialog::selectedDeviceChannels(bool isOutput)
{
	const QString module = RtModuleComboBox->currentData().toString();
	if (module == "null"_L1)
		return -1;
	const QList<AudioDeviceInfo> devices = cachedAudioDeviceGroups(isOutput);
	const QString text = isOutput ? RtOutputLineEdit->text() : RtInputLineEdit->text();
	QString id = text;
	for (const AudioDeviceInfo &device : devices) {
		if (device.name == text || device.id == text) {
			id = device.id;
			break;
		}
	}
	return m_configlists->audioDeviceChannels(module, id, isOutput, &devices);
}

void ConfigDialog::selectDefaultAudioDeviceIfNeeded(bool isOutput)
{
	const QString module = RtModuleComboBox->currentData().toString();
	QLineEdit *edit = isOutput ? RtOutputLineEdit : RtInputLineEdit;
	if (module == "null"_L1) {
		edit->clear();
		return;
	}
	const QString text = edit->text();
	if (text.isEmpty())
		return; // explicit No Input / No Output
	if (text.contains(QLatin1Char('*')))
		return; // expert regex

	static const QStringList inputSpecial = {
		u"adc:null"_s, u"adc:system:capture_"_s, u"adc:.*:capture_.*"_s
	};
	static const QStringList outputSpecial = {
		u"dac:null"_s, u"dac:system:playback_"_s, u"dac:.*:playback_.*"_s
	};
	if ((isOutput ? outputSpecial : inputSpecial).contains(text))
		return;

	const QList<AudioDeviceInfo> devices = cachedAudioDeviceGroups(isOutput);
	for (const AudioDeviceInfo &device : devices) {
		if (device.id == text || device.name == text)
			return;
	}

	const QString defaultId = ConfigLists::defaultAudioDeviceId(module, isOutput, devices);
	if (defaultId.isEmpty()) {
		edit->clear();
		return;
	}
	QString display = defaultId;
	for (const AudioDeviceInfo &device : devices) {
		if (device.id == defaultId) {
			display = device.name;
			break;
		}
	}
	edit->setText(display);
}

void ConfigDialog::resetChannelsMethodForBackend()
{
	const QString module = RtModuleComboBox->currentData().toString();
	// Fixed-KSMPS backends take their channel counts from the device;
	// PortAudio cannot do that reliably, so it defaults to the override values.
	int target = -1;
	if (ConfigLists::isFixedKsmpsModule(module))
		target = int(ChannelsSetupMethod::Device);
	else if (isPortAudioModule(module))
		target = int(ChannelsSetupMethod::Override);
	if (target < 0)
		return;
	const int targetIndex = channelsSetupMethod->findData(target);
	if (targetIndex < 0)
		return;
	const QSignalBlocker blocker(channelsSetupMethod);
	channelsSetupMethod->setCurrentIndex(targetIndex);
}

void ConfigDialog::updateChannelControls()
{
	const QString module = RtModuleComboBox->currentData().toString();
	const int inputChannels = selectedDeviceChannels(false);
	const int outputChannels = selectedDeviceChannels(true);
	const int effectiveInput = inputChannels >= 0 ? inputChannels : 2;
	const int effectiveOutput = outputChannels >= 0 ? outputChannels : 2;

	ChannelsSetupMethod method = static_cast<ChannelsSetupMethod>(
	            channelsSetupMethod->currentData().toInt());
	const bool driverDisabled = module == "null"_L1;
	const bool portAudio = isPortAudioModule(module);
	const int deviceIndex = channelsSetupMethod->findData(
	            int(ChannelsSetupMethod::Device));
	if (deviceIndex >= 0) {
		if (auto *model = qobject_cast<QStandardItemModel *>(channelsSetupMethod->model())) {
			if (QStandardItem *item = model->item(deviceIndex))
				item->setEnabled(!driverDisabled && !portAudio);
		}
	}
	if (method == ChannelsSetupMethod::Device && (driverDisabled || portAudio)) {
		const ChannelsSetupMethod fallback = driverDisabled
		        ? ChannelsSetupMethod::Orchestra
		        : ChannelsSetupMethod::Override;
		const int fallbackIndex = channelsSetupMethod->findData(int(fallback));
		if (fallbackIndex >= 0) {
			const QSignalBlocker blocker(channelsSetupMethod);
			channelsSetupMethod->setCurrentIndex(fallbackIndex);
			method = fallback;
		}
	}

	const QSignalBlocker outputBlocker(numChannelsSpinBox);
	const QSignalBlocker inputBlocker(numInputChannelsSpinBox);
	numChannelsSpinBox->setSpecialValueText(QString());
	numInputChannelsSpinBox->setSpecialValueText(QString());
	numChannelsSpinBox->setVisible(true);
	numInputChannelsSpinBox->setVisible(true);
	if (method == ChannelsSetupMethod::Override) {
		numChannelsSpinBox->setValue(m_overrideOutputChannels);
		numInputChannelsSpinBox->setValue(m_overrideInputChannels);
		numChannelsSpinBox->setReadOnly(false);
		numInputChannelsSpinBox->setReadOnly(false);
		numChannelsSpinBox->setEnabled(true);
		numInputChannelsSpinBox->setEnabled(true);
	} else if (method == ChannelsSetupMethod::Device) {
		// Looks like a normal value field but cannot be changed by the user.
		numChannelsSpinBox->setValue(effectiveOutput);
		numInputChannelsSpinBox->setValue(effectiveInput);
		numChannelsSpinBox->setReadOnly(true);
		numInputChannelsSpinBox->setReadOnly(true);
		numChannelsSpinBox->setEnabled(true);
		numInputChannelsSpinBox->setEnabled(true);
	} else {
		// Orchestra: display the device-declared counts, but inactive.
		numChannelsSpinBox->setValue(effectiveOutput);
		numInputChannelsSpinBox->setValue(effectiveInput);
		numChannelsSpinBox->setReadOnly(true);
		numInputChannelsSpinBox->setReadOnly(true);
		numChannelsSpinBox->setEnabled(false);
		numInputChannelsSpinBox->setEnabled(false);
	}
}

void ConfigDialog::updateKsmpsControls()
{
	const QString module = RtModuleComboBox->currentData().toString();
	const bool fixed = ConfigLists::isFixedKsmpsModule(module);
	const bool selectable = ConfigLists::isSelectableKsmpsModule(module);

	ksmpsLabel->setVisible(fixed || selectable);
	ksmpsComboBox->setVisible(fixed);
	ksmpsSpinBox->setVisible(selectable);
	ksmpsOrchestraCheckBox->setVisible(selectable);
	ksmpsComboBox->setEnabled(fixed);
	ksmpsSpinBox->setEnabled(selectable && !ksmpsOrchestraCheckBox->isChecked());
}

void ConfigDialog::updateAudioDeviceControls()
{
	const bool enabled = RtModuleComboBox->currentData().toString() != "null"_L1;
	inputDeviceLabel->setEnabled(enabled);
	RtInputLineEdit->setEnabled(enabled);
	audioInputToolButton->setEnabled(enabled);
	outputDeviceLabel->setEnabled(enabled);
	RtOutputLineEdit->setEnabled(enabled);
	audioOutputToolButton->setEnabled(enabled);
}

void ConfigDialog::updateMidiControls(bool internalMidi)
{
	// The Input/Output menus are shared by both modes, so they stay enabled.
	midiInterfaceComboBox->setEnabled(true);
	midiOutInterfaceComboBox->setEnabled(true);
	label_37->setEnabled(true);
	label_38->setEnabled(true);

	// The Csound MIDI backend only applies when internal MIDI is off.
	RtMidiModuleComboBox->setEnabled(!internalMidi);
	label_14->setEnabled(!internalMidi);
}

void ConfigDialog::populateInternalMidiInterfaces()
{
	const QSignalBlocker inBlocker(midiInterfaceComboBox);
	const QSignalBlocker outBlocker(midiOutInterfaceComboBox);
	midiInterfaceComboBox->clear();
	midiOutInterfaceComboBox->clear();

#ifdef CSQT_RTMIDI
	try {
		RtMidiIn midiin((RtMidi::Api) m_options->rtMidiApi);
		for (int i = 0; i < (int) midiin.getPortCount(); i++)
			midiInterfaceComboBox->addItem(QString::fromStdString(midiin.getPortName(i)),
			                               QVariant(i));
	}
	catch (RtMidiError &error) {
		error.printMessage();
	}
	try {
		RtMidiOut midiout((RtMidi::Api) m_options->rtMidiApi);
		for (int i = 0; i < (int) midiout.getPortCount(); i++)
			midiOutInterfaceComboBox->addItem(QString::fromStdString(midiout.getPortName(i)),
			                                  QVariant(i));
	}
	catch (RtMidiError &error) {
		error.printMessage();
	}
#else
	midiInterfaceComboBox->addItem(tr("No RtMidi support"), QVariant(9999));
#endif

	midiInterfaceComboBox->addItem(tr("None", "No MIDI In interface"), QVariant(9999));
	midiOutInterfaceComboBox->addItem(tr("None", "No MIDI Out interface"), QVariant(9999));

	int index = midiInterfaceComboBox->findText(m_options->midiInterfaceName);
	if (index < 0)
		index = midiInterfaceComboBox->findData(9999);
	midiInterfaceComboBox->setCurrentIndex(index);

	index = midiOutInterfaceComboBox->findText(m_options->midiOutInterfaceName);
	if (index < 0)
		index = midiOutInterfaceComboBox->findData(9999);
	midiOutInterfaceComboBox->setCurrentIndex(index);
}

void ConfigDialog::populateCsoundMidiDevices()
{
	const QString module = RtMidiModuleComboBox->currentData().toString();
	const QSignalBlocker inBlocker(midiInterfaceComboBox);
	const QSignalBlocker outBlocker(midiOutInterfaceComboBox);
	midiInterfaceComboBox->clear();
	midiOutInterfaceComboBox->clear();

	QHash<QString, QString> inputs = m_configlists->getMidiInputDevices(module);
	if (module == "jack"_L1)
		inputs.insert("jack", "jack");
	inputs.insert(tr("Disabled"), QString());
	if (module == "portmidi"_L1)
		inputs.insert("all", "a");
	QStringList inputNames = inputs.keys();
	inputNames.sort(Qt::CaseInsensitive);
	for (const QString &name : inputNames)
		midiInterfaceComboBox->addItem(name, inputs.value(name));

	QList<QStringPair> outputs = m_configlists->getMidiOutputDevices(module);
	if (module == "jack"_L1)
		outputs.prepend(QStringPair("jack", "jack"));
	outputs.append(QStringPair(tr("Disabled"), QString()));
	for (const QStringPair &entry : outputs)
		midiOutInterfaceComboBox->addItem(entry.first, entry.second);

	int index = midiInterfaceComboBox->findData(m_options->rtMidiInputDevice);
	if (index < 0)
		index = midiInterfaceComboBox->findText(tr("Disabled"));
	midiInterfaceComboBox->setCurrentIndex(index);

	index = midiOutInterfaceComboBox->findData(m_options->rtMidiOutputDevice);
	if (index < 0)
		index = midiOutInterfaceComboBox->findText(tr("Disabled"));
	midiOutInterfaceComboBox->setCurrentIndex(index);
}

void ConfigDialog::updateMidiDeviceLists()
{
	const bool internalMidi = internalMidiCheckBox->isChecked();
	if (internalMidi)
		populateInternalMidiInterfaces();
	else
		populateCsoundMidiDevices();
	updateMidiControls(internalMidi);
}

void ConfigDialog::on_internalMidiCheckBox_toggled(bool checked)
{
	updateMidiDeviceLists();
	if (!checked) { // switch to Csound's MIDI, close internal rtmidi
		qDebug()<<Q_FUNC_INFO<<" closing internal rtmidi now.";
		emit disableInternalRtMidi();
	}
}

bool backendSupportsSystemSamplerate(QString module) {
    if(module == "jack"  ||
       module == "auhal")
        return true;
    return false;
}

void ConfigDialog::testAudioSetup() {
    // here we only accept to close the dialog. The actual functionality
    // is called from CsoundQt::configure, where the testAudioSetupButton
    // is connected to CsoundQt::testAudioSetup
    // This is done like this because CsoundQt creates this dialog
    // each time and holds no reference to it.
    this->accept();
}

void ConfigDialog::recommendEnvironmentSettings() {
#ifdef Q_OS_UNIX
    QString default_opcodes64 = "/usr/local/lib/csound/plugins64-6.0:";
#endif
#ifdef Q_OS_WIN
    // What's the default plugin folder in win?
    QString default_opcodes64 = "";
#endif
    auto home = qgetenv("HOME");
    auto dataLocationApp = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation)[0];
    auto dataLocation = QDir(dataLocationApp);
    dataLocation.cdUp();
    if(this->Opcode7dir64LineEdit->text().isEmpty()) {
        auto opcdirenv = qgetenv("OPCODE7DIR64");
        if(!opcdirenv.isEmpty()) {
            // if the user already set OPCODE7DIR64 then leave it as is. This is probably
            // an expert user
            QDEBUG << "$OPCODE7DIR64 is already set to " << opcdirenv;
            this->Opcode7dir64LineEdit->setText(opcdirenv);
            this->Opcode7dir64CheckBox->setChecked(false);
        } else {
            // We set OPCODE7DIR64 to the default + a user writable location
            auto opcdirstr = dataLocation.path() + "/csound6/plugins64";
            auto opcdir = QDir(opcdirstr);
            if(!opcdir.exists()) {
                opcdir.mkpath(".");
            }
            if(!default_opcodes64.isEmpty())
                opcdirstr = default_opcodes64 + opcdirstr;
            this->Opcode7dir64LineEdit->setText(opcdirstr);
            this->Opcode7dir64CheckBox->setChecked(true);
        }
    }
    if(this->IncdirLineEdit->text().isEmpty()) {
        auto incdirenv = qgetenv("INCDIR");
        if(!incdirenv.isEmpty()) {
            // if the user already set it, then leave it as is. This is probably
            // an expert user
            QDEBUG << "$INCDIR is already set to " << incdirenv;
            this->IncdirLineEdit->setText(incdirenv);
            this->IncdirCheckBox->setChecked(false);
        } else {
            // propose an include folder parallel to the plugins folder
            auto incdirstr = dataLocation.path() + "/csound6/udos";
            auto incdir = QDir(incdirstr);
            if(!incdir.exists()) {
                incdir.mkpath(".");
            }
            this->IncdirLineEdit->setText(incdirstr);
            this->IncdirCheckBox->setChecked(true);
        }
    }
}
