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

#include <QtGui>
#include "configdialog.h"
#include "configlists.h"
#include "options.h"
#include "types.h"

ConfigDialog::ConfigDialog(QWidget *parent, Options *options, ConfigLists *m_configlist)
  : QDialog(parent), m_options(options)
{
  setupUi(this);

  foreach (QString item, m_configlist->fileTypeLongNames) {
    FileTypeComboBox->addItem(item);
  }
  foreach (QString item, m_configlist->fileFormatNames) {
    FileFormatComboBox->addItem(item);
  }
  foreach (QString item, m_configlist->rtAudioNames) {
    RtModuleComboBox->addItem(item);
  }
  foreach (QString item, m_configlist->rtMidiNames) {
    RtMidiModuleComboBox->addItem(item);
  }

  fontComboBox->setCurrentIndex(fontComboBox->findText(m_options->font) );
  fontSizeComboBox->setCurrentIndex(fontSizeComboBox->findText(QString::number((int) m_options->fontPointSize)));
  consoleFontComboBox->setCurrentIndex(consoleFontComboBox->findText(m_options->consoleFont) );
  consoleFontSizeComboBox->setCurrentIndex(consoleFontSizeComboBox->findText(QString::number((int) m_options->consoleFontPointSize)));
  tabWidthSpinBox->setValue(m_options->tabWidth);
  colorVariablesCheckBox->setChecked(m_options->colorVariables);
  autoplayCheckBox->setChecked(m_options->autoPlay);
  saveChangesCheckBox->setChecked(m_options->saveChanges);
  rememberFileCheckBox->setChecked(m_options->rememberFile);
  saveWidgetsCheckBox->setChecked(m_options->saveWidgets);
  iconTextCheckBox->setChecked(m_options->iconText);
  widgetsCheckBox->setChecked(m_options->enableWidgets);
  invalueCheckBox->setChecked(m_options->invalueEnabled);
  chngetCheckBox->setChecked(m_options->chngetEnabled);

  if (m_options->useAPI)
    ApiRadioButton->setChecked(true);
  else
    ExternalRadioButton->setChecked(true);

  threadCheckBox->setChecked(m_options->thread);

  BufferSizeLineEdit->setText(QString::number(m_options->bufferSize));
  BufferSizeCheckBox->setChecked(m_options->bufferSizeActive);
  BufferSizeLineEdit->setEnabled(m_options->bufferSizeActive);
  HwBufferSizeLineEdit->setText(QString::number(m_options->HwBufferSize));
  HwBufferSizeCheckBox->setChecked(m_options->HwBufferSizeActive);
  HwBufferSizeLineEdit->setEnabled(m_options->HwBufferSizeActive);
  DitherCheckBox->setChecked(m_options->dither);
  AdditionalFlagsCheckBox->setChecked(m_options->additionalFlagsActive);
  AdditionalFlagsLineEdit->setText(m_options->additionalFlags);
  AdditionalFlagsLineEdit->setEnabled(m_options->additionalFlagsActive);
  FileOverrideCheckBox->setChecked(m_options->fileOverrideOptions);
  AskFilenameCheckBox->setChecked(m_options->fileAskFilename);
  FilePlayFinishedCheckBox->setChecked(m_options->filePlayFinished);
  FileTypeComboBox->setCurrentIndex(m_options->fileFileType);
  FileFormatComboBox->setCurrentIndex(m_options->fileSampleFormat);
  InputFilenameCheckBox->setChecked(m_options->fileInputFilenameActive);
  InputFilenameLineEdit->setText(m_options->fileInputFilename);
  InputFilenameLineEdit->setEnabled(m_options->fileInputFilenameActive);
  OutputFilenameCheckBox->setChecked(m_options->fileOutputFilenameActive);
  OutputFilenameLineEdit->setText(m_options->fileOutputFilename);
  OutputFilenameLineEdit->setEnabled(m_options->fileOutputFilenameActive);
  RtOverrideCheckBox->setChecked(m_options->rtOverrideOptions);
  RtModuleComboBox->setCurrentIndex(m_options->rtAudioModule);
  RtInputLineEdit->setText(m_options->rtInputDevice);
  RtOutputLineEdit->setText(m_options->rtOutputDevice);
  JackNameLineEdit->setText(m_options->rtJackName);
  RtMidiModuleComboBox->setCurrentIndex(m_options->rtMidiModule);
  RtMidiInputLineEdit->setText(m_options->rtMidiInputDevice);
  RtMidiOutputLineEdit->setText(m_options->rtMidiOutputDevice);

  CsdocdirLineEdit->setText(m_options->csdocdir);
  OpcodedirCheckBox->setChecked(m_options->opcodedirActive);
  OpcodedirLineEdit->setText(m_options->opcodedir);
  OpcodedirLineEdit->setEnabled(m_options->opcodedirActive);
  SadirCheckBox->setChecked(m_options->sadirActive);
  SadirLineEdit->setText(m_options->sadir);
  SadirLineEdit->setEnabled(m_options->sadirActive);
  SsdirCheckBox->setChecked(m_options->ssdirActive);
  SsdirLineEdit->setText(m_options->ssdir);
  SsdirLineEdit->setEnabled(m_options->ssdirActive);
  SfdirCheckBox->setChecked(m_options->sfdirActive);
  SfdirLineEdit->setText(m_options->sfdir);
  SfdirLineEdit->setEnabled(m_options->sfdirActive);
  IncdirCheckBox->setChecked(m_options->incdirActive);
  IncdirLineEdit->setText(m_options->incdir);
  IncdirLineEdit->setEnabled(m_options->incdirActive);
//   opcodeXmlDirCheckBox->setChecked(m_options->opcodexmldirActive);
//   opcodeXmlDirLineEdit->setText(m_options->opcodexmldir);
//   opcodeXmlDirLineEdit->setEnabled(m_options->opcodexmldirActive);

  TerminalLineEdit->setText(m_options->terminal);
//   BrowserLineEdit->setText(m_options->browser);
  WaveEditorLineEdit->setText(m_options->waveeditor);
  WavePlayerLineEdit->setText(m_options->waveplayer);

  connect(inputFilenameToolButton, SIGNAL(clicked()), this, SLOT(browseInputFilename()));
  connect(outputFilenameToolButton, SIGNAL(clicked()), this, SLOT(browseOutputFilename()));
  connect(csdocdirToolButton, SIGNAL(clicked()), this, SLOT(browseCsdocdir()));
  connect(opcodedirToolButton, SIGNAL(clicked()), this, SLOT(browseOpcodedir()));
  connect(sadirToolButton, SIGNAL(clicked()), this, SLOT(browseSadir()));
  connect(ssdirToolButton, SIGNAL(clicked()), this, SLOT(browseSsdir()));
  connect(sfdirToolButton, SIGNAL(clicked()), this, SLOT(browseSfdir()));
  connect(incdirToolButton, SIGNAL(clicked()), this, SLOT(browseIncdir()));
//   connect(opcodeXmlDirToolButton, SIGNAL(clicked()), this, SLOT(browseOpcodeXmlDir()));
  connect(terminalToolButton, SIGNAL(clicked()), this, SLOT(browseTerminal()));
//   connect(browserToolButton, SIGNAL(clicked()), this, SLOT(browseBrowser()));
  connect(waveEditorToolButton, SIGNAL(clicked()), this, SLOT(browseWaveEditor()));
  connect(wavePlayerToolButton, SIGNAL(clicked()), this, SLOT(browseWavePlayer()));
  connect(this, SIGNAL(changeFont()), parent, SLOT(changeFont()));
}


ConfigDialog::~ConfigDialog()
{
}

void ConfigDialog::accept()
{
  m_options->font = fontComboBox->currentText();
  m_options->fontPointSize = fontSizeComboBox->currentText().toDouble();
  m_options->consoleFont = consoleFontComboBox->currentText();
  m_options->consoleFontPointSize = consoleFontSizeComboBox->currentText().toDouble();
  m_options->tabWidth = tabWidthSpinBox->value();
  m_options->colorVariables = colorVariablesCheckBox->isChecked();
  m_options->autoPlay = autoplayCheckBox->isChecked();
  m_options->saveChanges = saveChangesCheckBox->isChecked();
  m_options->rememberFile = rememberFileCheckBox->isChecked();
  m_options->saveWidgets = saveWidgetsCheckBox->isChecked();
  m_options->iconText = iconTextCheckBox->isChecked();
  m_options->enableWidgets = widgetsCheckBox->isChecked();
  m_options->invalueEnabled = invalueCheckBox->isChecked();
  m_options->chngetEnabled = chngetCheckBox->isChecked();

  m_options->useAPI = ApiRadioButton->isChecked();
  m_options->thread = threadCheckBox->isChecked();
  m_options->bufferSize = BufferSizeLineEdit->text().toInt();
  m_options->bufferSizeActive = BufferSizeCheckBox->isChecked();
  m_options->HwBufferSize = HwBufferSizeLineEdit->text().toInt();
  m_options->HwBufferSizeActive = HwBufferSizeCheckBox->isChecked();
  m_options->dither = DitherCheckBox->isChecked();
  m_options->additionalFlags = AdditionalFlagsLineEdit->text();
  m_options->additionalFlagsActive = AdditionalFlagsCheckBox->isChecked();
  m_options->fileOverrideOptions = FileOverrideCheckBox->isChecked();
  m_options->fileAskFilename = AskFilenameCheckBox->isChecked();
  m_options->filePlayFinished = FilePlayFinishedCheckBox->isChecked();
  m_options->fileFileType = FileTypeComboBox->currentIndex();
  m_options->fileSampleFormat = FileFormatComboBox->currentIndex();
  m_options->fileInputFilenameActive = InputFilenameCheckBox->isChecked();
  m_options->fileInputFilename = InputFilenameLineEdit->text();
  m_options->fileOutputFilenameActive = OutputFilenameCheckBox->isChecked();
  m_options->fileOutputFilename = OutputFilenameLineEdit->text();
  m_options->rtOverrideOptions = RtOverrideCheckBox->isChecked();
  m_options->rtAudioModule = RtModuleComboBox->currentIndex();
  m_options->rtInputDevice = RtInputLineEdit->text();
  m_options->rtOutputDevice = RtOutputLineEdit->text();
  m_options->rtJackName = JackNameLineEdit->text();
  m_options->rtMidiModule = RtMidiModuleComboBox->currentIndex();
  m_options->rtMidiInputDevice = RtMidiInputLineEdit->text();
  m_options->rtMidiOutputDevice = RtMidiOutputLineEdit->text();

  m_options->csdocdir = CsdocdirLineEdit->text();
  m_options->opcodedirActive = OpcodedirCheckBox->isChecked();
  m_options->opcodedir = OpcodedirLineEdit->text();
  m_options->sadirActive = SadirCheckBox->isChecked();
  m_options->sadir = SadirLineEdit->text();
  m_options->ssdirActive = SsdirCheckBox->isChecked();
  m_options->ssdir = SsdirLineEdit->text();
  m_options->sfdirActive = SfdirCheckBox->isChecked();
  m_options->sfdir = SfdirLineEdit->text();
  m_options->incdirActive = IncdirCheckBox->isChecked();
  m_options->incdir = IncdirLineEdit->text();
//   m_options->opcodexmldirActive = opcodeXmlDirCheckBox->isChecked();
//   m_options->opcodexmldir = opcodeXmlDirLineEdit->text();

  m_options->terminal = TerminalLineEdit->text();
//   m_options->browser = BrowserLineEdit->text();
  m_options->waveeditor = WaveEditorLineEdit->text();
  m_options->waveplayer = WavePlayerLineEdit->text();
  emit(changeFont());
  QDialog::accept();
}

void ConfigDialog::browseInputFilename()
{
  browseFile(m_options->fileInputFilename);
  InputFilenameLineEdit->setText(m_options->fileInputFilename);
}

void ConfigDialog::browseOutputFilename()
{
  browseFile(m_options->fileOutputFilename);
  OutputFilenameLineEdit->setText(m_options->fileOutputFilename);
}

void ConfigDialog::browseCsdocdir()
{
  browseDir(m_options->csdocdir);
  CsdocdirLineEdit->setText(m_options->csdocdir);
}

void ConfigDialog::browseOpcodedir()
{
  browseDir(m_options->opcodedir);
  OpcodedirLineEdit->setText(m_options->opcodedir);
}

void ConfigDialog::browseSadir()
{
  browseDir(m_options->sadir);
  SadirLineEdit->setText(m_options->sadir);
}

void ConfigDialog::browseSsdir()
{
  browseDir(m_options->ssdir);
  SsdirLineEdit->setText(m_options->sadir);
}

void ConfigDialog::browseSfdir()
{
  browseDir(m_options->sfdir);
  SfdirLineEdit->setText(m_options->sfdir);
}

void ConfigDialog::browseIncdir()
{
  browseDir(m_options->incdir);
  IncdirLineEdit->setText(m_options->incdir);
}

// void ConfigDialog::browseOpcodeXmlDir()
// {
//   browseDir(m_options->opcodexmldir);
//   opcodeXmlDirLineEdit->setText(m_options->opcodexmldir);
// }

void ConfigDialog::browseTerminal()
{
  browseFile(m_options->terminal);
  TerminalLineEdit->setText(m_options->terminal);
}

// void ConfigDialog::browseBrowser()
// {
//   browseFile(m_options->browser);
//   BrowserLineEdit->setText(m_options->browser);
// }

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

void ConfigDialog::browseFile(QString &destination)
{
  QString file =  QFileDialog::QFileDialog::getOpenFileName(this,tr("Select File"),destination);
  if (file!="")
    destination = file;
}

void ConfigDialog::browseDir(QString &destination)
{
  QString dir =  QFileDialog::QFileDialog::getExistingDirectory(this,tr("Select Directory"),destination);
  if (dir!="")
    destination = dir;
}
