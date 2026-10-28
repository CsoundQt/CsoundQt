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

#ifndef CONFIGDIALOG_H
#define CONFIGDIALOG_H

#include "ui_configdialog.h"

class CsoundQt;
class Options;
class ConfigLists;
class QAction;
class KeyboardShortcutsWidget;

constexpr int ORCHESTRA = 0; // instead of macros
constexpr int SYSTEM = 1;  // and lazy for using enum...

class ConfigDialog : public QDialog, public Ui::ConfigDialog
{
	Q_OBJECT
public:
	ConfigDialog(CsoundQt *parent, Options *options, ConfigLists *configlists,
				 const QVector<QAction *> &keyActions,
				 const QHash<QAction *, QKeySequence> &defaultShortcuts);

	~ConfigDialog();
	int currentTab();
	void setCurrentTab(int index);
	// Whether a shortcut was assigned while the dialog was open. Those changes
	// are immediate: they are kept whatever button closes the dialog.
	bool shortcutsModified() const;




public slots:
	void warnOpcodeDir(bool on);

private:
	CsoundQt* m_parent;
	Options *m_options;
	ConfigLists *m_configlists;
	KeyboardShortcutsWidget *m_shortcutsWidget = nullptr;
	void browseFile(QString &destination);
	void browseSaveFile(QString &destination);
	void browseDir(QString &destination);
	void populateEditorThemes();
    int m_selectedOutputDeviceIndex;

private slots:
	virtual void accept();
	void apply(); // copy the widget values into m_options (OK and Apply)
	void duplicateEditorTheme();
	void openThemesFolder();
	void browseInputFilename();
	void browseOutputFilename();
	void browseCsdocdir();
    void browseOpcode7dir64();
	void browseSadir();
	void browseSsdir();
	void browseSfdir();
	void browseIncdir();
	void browseRawWaveDir();
	//    void browseDefaultCsd();
	void browseFavorite();
    void browseExamplePath();
	void browseCsoundExecutable();
	void browseTemplateDir();
	void openDebugLog();
	void updateLogPathLabel();
	void browseTerminal();
	void browseBrowser();
	void browseWaveEditor();
	void browseWavePlayer();
	void browsePdfViewer();
	void selectAudioInput();
	void selectAudioOutput();
	void selectMidiInput();
	void selectMidiOutput();
	void selectTextColor();
	void selectBgColor();
	void selectEditorBgColor();
	void selectWidgetFrameColorUnselected();
	void selectWidgetFrameColorSelected();
	void clearTemplate();
	void defaultTemplate();

	void on_csoundMidiCheckBox_toggled(bool checked);
	void checkRtMidiModule(QString module);
    void testAudioSetup();
    void recommendEnvironmentSettings();

    void onRtModuleComboBoxChanged(int index);



signals:
	void disableInternalRtMidi();
	// Restore Defaults pressed in the Shortcuts tab; the application owns the
	// default assignments.
	void restoreDefaultShortcuts();
	//    void changeFont();

};

#endif
