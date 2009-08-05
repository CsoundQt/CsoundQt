/*
    Copyright (C) 2008, 2009 Andres Cabrera
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

#include <QtGui>
#include "qutecsound.h"
#include "configdialog.h"
#include "options.h"
#include "types.h"

ConfigDialog::ConfigDialog(qutecsound *parent, Options *options)
  : QDialog(parent), m_parent(parent), m_options(options)
{
  setupUi(this);

  foreach (QString item, _configlists.fileTypeLongNames) {
    FileTypeComboBox->addItem(item);
  }
  foreach (QString item, _configlists.fileFormatNames) {
    FileFormatComboBox->addItem(item);
  }
  foreach (QString item, _configlists.rtAudioNames) {
    RtModuleComboBox->addItem(item);
  }
  foreach (QString item, _configlists.rtMidiNames) {
    RtMidiModuleComboBox->addItem(item);
  }
  for (int i = 0; i < _configlists.languages.size(); i++) {
    languageComboBox->addItem(_configlists.languages[i], QVariant(_configlists.languageCodes[i]));
  }

  fontComboBox->setCurrentIndex(fontComboBox->findText(m_options->font) );
  fontSizeComboBox->setCurrentIndex(fontSizeComboBox->findText(QString::number((int) m_options->fontPointSize)));
  consoleFontComboBox->setCurrentIndex(consoleFontComboBox->findText(m_options->consoleFont) );
  consoleFontSizeComboBox->setCurrentIndex(consoleFontSizeComboBox->findText(QString::number((int) m_options->consoleFontPointSize)));
  QPixmap pixmap(64,64);
  pixmap.fill(m_options->consoleFontColor);
  consoleFontColorPushButton->setIcon(pixmap);
  QPalette palette(m_options->consoleFontColor);
  consoleFontColorPushButton->setPalette(palette);

  pixmap.fill(m_options->consoleBgColor);
  consoleBgColorPushButton->setIcon(pixmap);
  palette = QPalette(m_options->consoleBgColor);
  consoleBgColorPushButton->setPalette(palette);

  tabWidthSpinBox->setValue(m_options->tabWidth);
  colorVariablesCheckBox->setChecked(m_options->colorVariables);
  autoplayCheckBox->setChecked(m_options->autoPlay);
  saveChangesCheckBox->setChecked(m_options->saveChanges);
  rememberFileCheckBox->setChecked(m_options->rememberFile);
  saveWidgetsCheckBox->setChecked(m_options->saveWidgets);
  iconTextCheckBox->setChecked(m_options->iconText);
  wrapLinesCheckBox->setChecked(m_options->wrapLines);
  widgetsCheckBox->setChecked(m_options->enableWidgets);
  channelComboBox->setCurrentIndex(m_options->useInvalue ? 0: 1);
  showWidgetsOnRunCheckBox->setChecked(m_options->showWidgetsOnRun);
  showTooltipsCheckBox->setChecked(m_options->showTooltips);
  enableFLTKCheckBox->setChecked(m_options->enableFLTK);

  if (m_options->useAPI)
    ApiRadioButton->setChecked(true);
  else
    ExternalRadioButton->setChecked(true);

  threadCheckBox->setChecked(m_options->thread);
  threadCheckBox->setEnabled(ApiRadioButton->isChecked());

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
  FileUseOptionsCheckBox->setChecked(m_options->fileUseOptions);
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
  RtUseOptionsCheckBox->setChecked(m_options->rtUseOptions);
  RtOverrideCheckBox->setChecked(m_options->rtOverrideOptions);
  RtModuleComboBox->setCurrentIndex(m_options->rtAudioModule);
  RtInputLineEdit->setText(m_options->rtInputDevice);
  RtOutputLineEdit->setText(m_options->rtOutputDevice);
  JackNameLineEdit->setText(m_options->rtJackName);
  RtMidiModuleComboBox->setCurrentIndex(m_options->rtMidiModule);
  RtMidiInputLineEdit->setText(m_options->rtMidiInputDevice);
  RtMidiOutputLineEdit->setText(m_options->rtMidiOutputDevice);

  sampleFormatComboBox->setCurrentIndex(m_options->sampleFormat);

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
  defaultCsdCheckBox->setChecked(m_options->incdirActive);
  defaultCsdLineEdit->setText(m_options->incdir);
  defaultCsdLineEdit->setEnabled(m_options->incdirActive);

  TerminalLineEdit->setText(m_options->terminal);
  browserLineEdit->setText(m_options->browser);
  dotLineEdit->setText(m_options->dot);
  WaveEditorLineEdit->setText(m_options->waveeditor);
  WavePlayerLineEdit->setText(m_options->waveplayer);
  languageComboBox->setCurrentIndex(m_options->language);

  connect(inputFilenameToolButton, SIGNAL(clicked()), this, SLOT(browseInputFilename()));
  connect(outputFilenameToolButton, SIGNAL(clicked()), this, SLOT(browseOutputFilename()));
  connect(csdocdirToolButton, SIGNAL(clicked()), this, SLOT(browseCsdocdir()));
  connect(opcodedirToolButton, SIGNAL(clicked()), this, SLOT(browseOpcodedir()));
  connect(sadirToolButton, SIGNAL(clicked()), this, SLOT(browseSadir()));
  connect(ssdirToolButton, SIGNAL(clicked()), this, SLOT(browseSsdir()));
  connect(sfdirToolButton, SIGNAL(clicked()), this, SLOT(browseSfdir()));
  connect(incdirToolButton, SIGNAL(clicked()), this, SLOT(browseIncdir()));
  connect(defaultCsdToolButton, SIGNAL(clicked()), this, SLOT(browseDefaultCsd()));
  connect(terminalToolButton, SIGNAL(clicked()), this, SLOT(browseTerminal()));
  connect(browserToolButton, SIGNAL(clicked()), this, SLOT(browseBrowser()));
  connect(dotToolButton, SIGNAL(clicked()), this, SLOT(browseDot()));
  connect(waveEditorToolButton, SIGNAL(clicked()), this, SLOT(browseWaveEditor()));
  connect(wavePlayerToolButton, SIGNAL(clicked()), this, SLOT(browseWavePlayer()));
  connect(this, SIGNAL(changeFont()), parent, SLOT(changeFont()));
  connect(audioInputToolButton, SIGNAL(released()), this, SLOT(selectAudioInput()));
  connect(audioOutputToolButton, SIGNAL(released()), this, SLOT(selectAudioOutput()));
  connect(midiInputToolButton, SIGNAL(released()), this, SLOT(selectMidiInput()));
  connect(midiOutputToolButton, SIGNAL(released()), this, SLOT(selectMidiOutput()));
  connect(consoleFontColorPushButton, SIGNAL(released()), this, SLOT(selectTextColor()));
  connect(consoleBgColorPushButton, SIGNAL(released()), this, SLOT(selectBgColor()));

}

ConfigDialog::~ConfigDialog()
{
}

int ConfigDialog::currentTab()
{
  return editorTabWidget->currentIndex();
}

void ConfigDialog::setCurrentTab(int index)
{
  if (index >= 0 && index < 4) {
    editorTabWidget->setCurrentIndex(index);
  }
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
  m_options->wrapLines = wrapLinesCheckBox->isChecked();
  m_options->enableWidgets = widgetsCheckBox->isChecked();
  m_options->useInvalue = channelComboBox->currentIndex() == 0;
  m_options->showWidgetsOnRun = showWidgetsOnRunCheckBox->isChecked();
  m_options->showTooltips = showTooltipsCheckBox->isChecked();
  m_options->enableFLTK = enableFLTKCheckBox->isChecked();

  m_options->useAPI = ApiRadioButton->isChecked();
  m_options->thread = threadCheckBox->isChecked();
  m_options->bufferSize = BufferSizeLineEdit->text().toInt();
  m_options->bufferSizeActive = BufferSizeCheckBox->isChecked();
  m_options->HwBufferSize = HwBufferSizeLineEdit->text().toInt();
  m_options->HwBufferSizeActive = HwBufferSizeCheckBox->isChecked();
  m_options->dither = DitherCheckBox->isChecked();
  m_options->additionalFlags = AdditionalFlagsLineEdit->text();
  m_options->additionalFlagsActive = AdditionalFlagsCheckBox->isChecked();
  m_options->fileUseOptions = FileUseOptionsCheckBox->isChecked();
  m_options->fileOverrideOptions = FileOverrideCheckBox->isChecked();
  m_options->fileAskFilename = AskFilenameCheckBox->isChecked();
  m_options->filePlayFinished = FilePlayFinishedCheckBox->isChecked();
  m_options->fileFileType = FileTypeComboBox->currentIndex();
  m_options->fileSampleFormat = FileFormatComboBox->currentIndex();
  m_options->fileInputFilenameActive = InputFilenameCheckBox->isChecked();
  m_options->fileInputFilename = InputFilenameLineEdit->text();
  m_options->fileOutputFilenameActive = OutputFilenameCheckBox->isChecked();
  m_options->fileOutputFilename = OutputFilenameLineEdit->text();
  m_options->rtUseOptions = RtUseOptionsCheckBox->isChecked();
  m_options->rtOverrideOptions = RtOverrideCheckBox->isChecked();
  m_options->rtAudioModule = RtModuleComboBox->currentIndex();
  m_options->rtInputDevice = RtInputLineEdit->text();
  m_options->rtOutputDevice = RtOutputLineEdit->text();
  m_options->rtJackName = JackNameLineEdit->text();
  m_options->rtMidiModule = RtMidiModuleComboBox->currentIndex();
  m_options->rtMidiInputDevice = RtMidiInputLineEdit->text();
  m_options->rtMidiOutputDevice = RtMidiOutputLineEdit->text();

  m_options->sampleFormat = sampleFormatComboBox->currentIndex();

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
  m_options->defaultCsdActive = defaultCsdCheckBox->isChecked();
  m_options->defaultCsd = defaultCsdLineEdit->text();

  m_options->terminal = TerminalLineEdit->text();
  m_options->browser = browserLineEdit->text();
  m_options->dot = dotLineEdit->text();
  m_options->waveeditor = WaveEditorLineEdit->text();
  m_options->waveplayer = WavePlayerLineEdit->text();
  m_options->language = languageComboBox->currentIndex();

  emit(changeFont());
  QDialog::accept();
}

void ConfigDialog::browseInputFilename()
{
  browseSaveFile(m_options->fileInputFilename);
  InputFilenameLineEdit->setText(m_options->fileInputFilename);
}

void ConfigDialog::browseOutputFilename()
{
  browseSaveFile(m_options->fileOutputFilename);
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

void ConfigDialog::browseDefaultCsd()
{
  browseFile(m_options->defaultCsd);
  if (!m_options->defaultCsd.endsWith(".csd")) {
    QMessageBox::warning(this, tr("QuteCsound"),
                         tr("Only files with extension .csd are accepted"));
    return;
  }
  defaultCsdLineEdit->setText(m_options->defaultCsd);
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

void ConfigDialog::browseDot()
{
  browseFile(m_options->dot);
  dotLineEdit->setText(m_options->dot);
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

void ConfigDialog::selectAudioInput()
{
  QList<QPair<QString, QString> > deviceList = getAudioInputDevices();
  QMenu menu(this);
  QVector<QAction*> actions;

  QPair<QString, QString> device;
  device.first = "none";
  device.second = "";
  deviceList.prepend(device);

  device.first = "default";
  device.second = "adc";
  deviceList.prepend(device);

  for (int i = 0; i < deviceList.size(); i++) {
    QAction* action =  menu.addAction(deviceList[i].first + " (" + deviceList[i].second +")");
    actions.append(action);
  }

  int index = actions.indexOf(menu.exec(this->mapToGlobal(QPoint(260,440))));
  if (index >= 0)
    RtInputLineEdit->setText(deviceList[index].second);
}

void ConfigDialog::selectAudioOutput()
{
  QList<QPair<QString, QString> > deviceList = getAudioOutputDevices();
  QMenu menu(this);
  QVector<QAction*> actions;

  QPair<QString, QString> device;
  device.first = "none";
  device.second = "";
  deviceList.prepend(device);

  device.first = "default";
  device.second = "dac";
  deviceList.prepend(device);

  for (int i = 0; i < deviceList.size(); i++) {
    QAction* action =  menu.addAction(deviceList[i].first + " (" + deviceList[i].second +")");
    actions.append(action);
  }

  int index = actions.indexOf(menu.exec(this->mapToGlobal(QPoint(260,475))));
  if (index >= 0)
    RtOutputLineEdit->setText(deviceList[index].second);
}

void ConfigDialog::selectMidiInput()
{
  QList<QPair<QString, QString> > deviceList = getMidiInputDevices();
  QString module = _configlists.rtMidiNames[RtMidiModuleComboBox->currentIndex()];
  QMenu menu(this);
  QVector<QAction*> actions;

  QPair<QString, QString> device;
  device.first = "none";
  device.second = "";
  deviceList.prepend(device);

  if (module == "portmidi") {
    device.first = "all";
    device.second = "a";
    deviceList.prepend(device);
  }

  if (module == "virtual") {
    device.first = "enabled";
    device.second = "0";
    deviceList.prepend(device);
  }

  for (int i = 0; i < deviceList.size(); i++) {
    QAction* action =  menu.addAction(deviceList[i].first + " (" + deviceList[i].second +")");
    actions.append(action);
  }

  int index = actions.indexOf(menu.exec(this->mapToGlobal(QPoint(560,445))));
  if (index >= 0)
    RtMidiInputLineEdit->setText(deviceList[index].second);
}

void ConfigDialog::selectMidiOutput()
{
  QList<QPair<QString, QString> > deviceList = getMidiOutputDevices();
  QString module = _configlists.rtMidiNames[RtMidiModuleComboBox->currentIndex()];
  QMenu menu(this);
  QVector<QAction*> actions;

  QPair<QString, QString> device;
  device.first = "none";
  device.second = "";
  deviceList.prepend(device);

  for (int i = 0; i < deviceList.size(); i++) {
    QAction* action =  menu.addAction(deviceList[i].first + " (" + deviceList[i].second +")");
    actions.append(action);
  }

  int index = actions.indexOf(menu.exec(this->mapToGlobal(QPoint(560,475))));
  if (index >= 0)
    RtMidiOutputLineEdit->setText(deviceList[index].second);
}

void ConfigDialog::browseFile(QString &destination)
{
  QString file =  QFileDialog::QFileDialog::getOpenFileName(this,tr("Select File"),destination);
  if (file!="")
    destination = file;
}

void ConfigDialog::browseSaveFile(QString &destination)
{
  QString file =  QFileDialog::QFileDialog::getSaveFileName(this,tr("Select File"),destination);
  if (file!="")
    destination = file;
}

void ConfigDialog::browseDir(QString &destination)
{
  QString dir =  QFileDialog::QFileDialog::getExistingDirectory(this,tr("Select Directory"),destination);
  if (dir!="")
    destination = dir;
}

QList<QPair<QString, QString> > ConfigDialog::getMidiInputDevices()
{
  // Adapted from blue by Steven Yi
  QList<QPair<QString, QString> > deviceList;
  QString module = _configlists.rtMidiNames[RtMidiModuleComboBox->currentIndex()];
  if (module == "none") {
    return deviceList;
  }
  if (module == "alsa") {
    // This commented section uses the wrong file to query devices. maybe this used to work? 
//     QFile f("/proc/asound/seq/clients");
//     f.open(QIODevice::ReadOnly | QIODevice::Text);
//     QString values = QString(f.readAll());
//     QStringList st = values.split("\n");
//     QString line;
//     for (int i = 0; i < st.size(); i++){
//       line = st[i].trimmed();
//       if (line.startsWith("Client") && line.indexOf(":") >= 0) {
//         QString clientNum = QString::number(line.mid(6,line.indexOf(":") - 6).trimmed().toInt());
//         while (i < st.size() - 2) {
//           i++;
// 
//           QString tempLine = st[i].trimmed();
//           if (tempLine.startsWith("Port")) {
//             QString capabilities = tempLine.mid(tempLine.lastIndexOf("("));
//             if (capabilities.indexOf("R") >= 0) {
//               QStringList portParts = tempLine.split("\"");
//               int portNum = tempLine.mid(6, tempLine.indexOf(":") - 6).trimmed().toInt();
//               QPair<QString, QString> device;
//               device.first = portParts[1];
//               device.second = "hw:" + clientNum + "," + QString::number(portNum);
//               deviceList.append(device);
//             }
//           }
//           else if (tempLine.startsWith("Client")) {
//             i--;
//             break;
//           }
//         }
//       }
//     }
  }
  else { // if not alsa (i.e. winmm or portmidi)
    QFile file(":/test.csd");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
      return deviceList;
    QString jackCSD = QString(file.readAll());
    QString tempText = jackCSD;
    tempText.replace("$SR", "1000");
    QTemporaryFile tempFile(QDir::tempPath() + "/" + "testcsdQuteCsoundXXXXXX.csd");
    tempFile.open();
    QTextStream out(&tempFile);
    out << tempText;
    tempFile.close();
    tempFile.open();

    QStringList flags;
//     QString rtAudioFlag = "-+rtaudio=" + module;
    flags << "-+msg_color=false"/* << rtAudioFlag*/ << "-odac"  << "-M999" << tempFile.fileName();
    QStringList messages = m_parent->runCsoundInternally(flags);

    QString startText, endText;
    if (module == "portmidi") {
      startText = "The available MIDI";
      endText = "*** PortMIDI";
    }
    else if (module == "winmm") {
      startText = "The available MIDI";
      endText = "rtmidi: input device number is out of range";
    }
    if (startText == "" && endText == "") {
      return deviceList;
    }
    bool collect = false;
    foreach (QString line, messages) {
      if (collect) {
        if (endText.length() > 0 && line.indexOf(endText) >= 0) {
          collect = false;
        }
        else {
          if (line.indexOf(":") >= 0) {
            qDebug("%s", line.toStdString().c_str());
            QPair<QString, QString> device;
            device.first = line.mid(line.indexOf(":") + 1).trimmed();
            device.second = line.mid(0,line.indexOf(":")).trimmed();
            deviceList.append(device);
          }
        }
      }
      else if (line.indexOf(startText) >= 0) {
        collect = true;
      }
    }
  }
  return deviceList;
}

QList<QPair<QString, QString> > ConfigDialog::getMidiOutputDevices()
{
  QList<QPair<QString, QString> > deviceList;
  QString module = _configlists.rtMidiNames[RtMidiModuleComboBox->currentIndex()];
  if (module == "none") {
    return deviceList;
  }
  if (module == "alsa") {
    QFile f("/proc/asound/seq/clients");
    f.open(QIODevice::ReadOnly | QIODevice::Text);
    QString values = QString(f.readAll());
    QStringList st = values.split("\n");
    QString line;
    for (int i = 0; i < st.size(); i++){
      line = st[i].trimmed();
      if (line.startsWith("Client") && line.indexOf(":") >= 0) {
        QString clientNum = QString::number(line.mid(6,line.indexOf(":") - 6).trimmed().toInt());
        while (i < st.size() - 2) {
          i++;

          QString tempLine = st[i].trimmed();
          if (tempLine.startsWith("Port")) {
            QString capabilities = tempLine.mid(tempLine.lastIndexOf("("));
            if (capabilities.indexOf("W") >= 0) {
              QStringList portParts = tempLine.split("\"");
              int portNum = tempLine.mid(6, tempLine.indexOf(":") - 6).trimmed().toInt();
              QPair<QString, QString> device;
              device.first = portParts[1];
              device.second = "hw:" + clientNum + "," + QString::number(portNum);
              deviceList.append(device);
            }
          }
          else if (tempLine.startsWith("Client")) {
            i--;
            break;
          }
        }
      }
    }
  }
  else { // if not alsa (i.e. winmm or portmidi)
    QFile file(":/test.csd");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
      return deviceList;
    QString jackCSD = QString(file.readAll());
    QString tempText = jackCSD;
    tempText.replace("$SR", "1000");
    QTemporaryFile tempFile(QDir::tempPath() + "/" + "testcsdQuteCsoundXXXXXX.csd");
    tempFile.open();
    QTextStream out(&tempFile);
    out << tempText;
    tempFile.close();
    tempFile.open();

    QStringList flags;
    flags << "-+msg_color=false" << "-odac"  << "-Q999" << tempFile.fileName();
    QStringList messages = m_parent->runCsoundInternally(flags);

    QString startText, endText;
    if (module == "portmidi") {
      startText = "The available MIDI";
      endText = "*** PortMIDI";
    }
    else if (module == "winmm") {
      startText = "The available MIDI";
      endText = "rtmidi: output device number is out of range";
    }
    if (startText == "" && endText == "") {
      return deviceList;
    }
    bool collect = false;
    foreach (QString line, messages) {
      if (collect) {
        if (endText.length() > 0 && line.indexOf(endText) >= 0) {
          collect = false;
        }
        else {
          if (line.indexOf(":") >= 0) {
            qDebug("%s", line.toStdString().c_str());
            QPair<QString, QString> device;
            device.first = line.mid(line.indexOf(":") + 1).trimmed();
            device.second = line.mid(0,line.indexOf(":")).trimmed();
            deviceList.append(device);
          }
        }
      }
      else if (line.indexOf(startText) >= 0) {
        collect = true;
      }
    }
  }
  return deviceList;
}

QList<QPair<QString, QString> > ConfigDialog::getAudioInputDevices()
{
  qDebug("qutecsound::getAudioInputDevices()");
  QList<QPair<QString, QString> > deviceList;
  QString module = _configlists.rtAudioNames[RtModuleComboBox->currentIndex()];
  if (module == "none") {
    return deviceList;
  }
  if (module == "alsa") {
    QFile f("/proc/asound/pcm");
    f.open(QIODevice::ReadOnly | QIODevice::Text);
    QString values = QString(f.readAll());
    QStringList st = values.split("\n");
    foreach (QString line, st) {
      if (line.indexOf("capture") >= 0) {
        QStringList parts = line.split(":");

        QStringList cardId = parts[0].split("-");
        QString buffer = "";
        buffer.append(parts[1]).append(" : ").append(parts[2]);

        QPair<QString, QString> device;
        device.first = buffer;
        device.second = "adc:hw:" + QString::number(cardId[0].toInt()) + "," + QString::number(cardId[1].toInt());
        deviceList.append(device);
      }
    }
  }
  else if (module=="jack") {
    QFile file(":/test.csd");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
      return deviceList;
    QString jackCSD = QString(file.readAll());
    QString tempText = jackCSD;
    tempText.replace("$SR", "1000");
    QTemporaryFile tempFile(QDir::tempPath() + "/" + "testcsdQuteCsoundXXXXXX.csd");
    tempFile.open();
    QTextStream out(&tempFile);
    out << tempText;
    tempFile.close();
    tempFile.open();

    QStringList flags;
    // -odac is needed otherwise csound segfaults
    flags << "-+msg_color=false" << "-+rtaudio=jack" << "-iadc:xxx" << "-odac:xxx" << "-B2048" <<  tempFile.fileName();
    QStringList messages = m_parent->runCsoundInternally(flags);

    QString sr = "";
    foreach (QString line, messages) {
      if (line.indexOf("does not match JACK sample rate") >= 0) {
        sr = line.mid(line.lastIndexOf(" ") + 1);
      }
    }
    if (sr == "") {
      return deviceList;
    }

    tempText = jackCSD;
    tempText.replace("$SR", sr);
    out << tempText;
    tempFile.close();
    tempFile.open();

    messages = m_parent->runCsoundInternally(flags); // run with same flags as before

    QString previousLine = "";
    foreach (QString line, messages) {
      qDebug("jack %s----",line.toStdString().c_str());
      if (line.endsWith("channel)\n") || line.endsWith("channels)\n")) {
        QStringList parts = previousLine.split("\"");
        QPair<QString, QString> device;
        device.first = parts[1];
        device.second = "adc:" + parts[1];
        deviceList.append(device);
      }
      previousLine = line;
    }
  }  //ends if (module=="jack")
  else { // if not alsa or jack (i.e. coreaudio or portaudio)
    QFile file(":/test.csd");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
      return deviceList;
    QString jackCSD = QString(file.readAll());
    QString tempText = jackCSD;
    tempText.replace("$SR", "1000");
    QTemporaryFile tempFile(QDir::tempPath() + "/" + "testcsdQuteCsoundXXXXXX.csd");
    tempFile.open();
    QTextStream out(&tempFile);
    out << tempText;
    tempFile.close();
    tempFile.open();

    QStringList flags;
    QString rtAudioFlag = "-+rtaudio=" + module + " ";
    flags << "-+msg_color=false" << rtAudioFlag << "-iadc999" << "-odac999" << "-d" << tempFile.fileName();
    QStringList messages = m_parent->runCsoundInternally(flags);

    QString startText, endText;
    if (module=="portaudio") {
      startText = "PortAudio: available";
      endText = "error:";
    }
    else if (module=="winmm" || module=="mme") {
      startText = "The available input devices are:";
      endText = "device number is out of range";
    }
    else if (module=="coreaudio") {
      startText = "CoreAudio Module: found";
      endText = "";
    }
    if (startText == "" && endText == "") {
      return deviceList;
    }
    bool collect = false;
    foreach (QString line, messages) {
      if (collect) {
        if (endText.length() > 0 && line.indexOf(endText) >= 0) {
          collect = false;
        }
        else {
          if (module == "coreaudio") {
            QString coreAudioMatch = "=> CoreAudio device";

            if (line.indexOf(coreAudioMatch) >= 0) {
              line = line.mid(coreAudioMatch.length()).trimmed();

              QPair<QString, QString> device;
              device.first = line.mid(line.indexOf(":")).trimmed();
              device.second = "adc" + line.left(line.indexOf(":"));
              deviceList.append(device);
            }
          } // if not coreaudio, i.e. portaudio
          else if (line.indexOf(":") >= 0) {
            QPair<QString, QString> device;
            device.first = line.mid(line.indexOf(":") + 1).trimmed();
            device.second = "adc" + line.left(line.indexOf(":")).trimmed();
            deviceList.append(device);
          }
        }
      }
      else if (line.indexOf(startText) >= 0) {
        collect = true;
      }
    }
  }
  return deviceList;
}

QList<QPair<QString, QString> > ConfigDialog::getAudioOutputDevices()
{
  qDebug("qutecsound::getAudioOutputDevices()");
  QList<QPair<QString, QString> > deviceList;
  QString module = _configlists.rtAudioNames[RtModuleComboBox->currentIndex()];
  if (module == "none") {
    return deviceList;
  }
  if (module == "alsa") {
    QFile f("/proc/asound/pcm");
    f.open(QIODevice::ReadOnly | QIODevice::Text);
    QString values = QString(f.readAll());
    QStringList st = values.split("\n");
    foreach (QString line, st) {
      if (line.indexOf("playback") >= 0) {
        QStringList parts = line.split(":");

        QStringList cardId = parts[0].split("-");
        QString buffer = "";
        buffer.append(parts[1]).append(" : ").append(parts[2]);

        QPair<QString, QString> device;
        device.first = buffer;
        device.second = "dac:hw:" + QString::number(cardId[0].toInt()) + "," + QString::number(cardId[1].toInt());
        deviceList.append(device);
      }
    }
  }
  else if (module=="jack") {
    QFile file(":/test.csd");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
      return deviceList;
    QString jackCSD = QString(file.readAll());
    QString tempText = jackCSD;
    tempText.replace("$SR", "1000");
    QTemporaryFile tempFile(QDir::tempPath() + "/" + "testcsdQuteCsoundXXXXXX.csd");
    tempFile.open();
    QTextStream out(&tempFile);
    out << tempText;
    tempFile.close();
    tempFile.open();

    QStringList flags;
    flags << "-+msg_color=false" << "-+rtaudio=jack" << "-odac:xxx" << "-B2048" <<  tempFile.fileName();
    QStringList messages = m_parent->runCsoundInternally(flags);

    QString sr = "";
    foreach (QString line, messages) {
      if (line.indexOf("does not match JACK sample rate") >= 0) {
        sr = line.mid(line.lastIndexOf(" ") + 1);
      }
    }
    if (sr == "") {
      return deviceList;
    }

    tempText = jackCSD;
    tempText.replace("$SR", sr);
    out << tempText;
    tempFile.close();
    tempFile.open();

    messages = m_parent->runCsoundInternally(flags); // run with same flags as before

    QString previousLine = "";
    foreach (QString line, messages) {
      if (line.endsWith("channel)\n") || line.endsWith("channels)\n")) {
        QStringList parts = previousLine.split("\"");
        QPair<QString, QString> device;
        device.first = parts[1];
        device.second = "dac:" + parts[1];
        deviceList.append(device);
      }
      previousLine = line;
    }
  }  //ends if (module=="jack")
  else { // if not alsa or jack (i.e. coreaudio or portaudio)
    QFile file(":/test.csd");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
      return deviceList;
    QString jackCSD = QString(file.readAll());
    QString tempText = jackCSD;
    tempText.replace("$SR", "1000");
    QTemporaryFile tempFile(QDir::tempPath() + "/" + "testcsdQuteCsoundXXXXXX.csd");
    tempFile.open();
    QTextStream out(&tempFile);
    out << tempText;
    tempFile.close();
    tempFile.open();

    QStringList flags;
    QString rtAudioFlag = "-+rtaudio=" + module + " ";
    flags << "-+msg_color=false" << rtAudioFlag << "-odac999" << tempFile.fileName();
    QStringList messages = m_parent->runCsoundInternally(flags);

    QString startText, endText;
    if (module=="portaudio") {
      startText = "PortAudio: available";
      endText = "error:";
    }
    else if (module=="winmm" || module=="mme") {
      startText = "The available output devices are:";
      endText = "device number is out of range";
    }
    else if (module=="coreaudio") {
      startText = "CoreAudio Module: found";
      endText = "";
    }
    if (startText == "" && endText == "") {
      return deviceList;
    }
    bool collect = false;
    foreach (QString line, messages) {
      if (collect) {
        if (endText.length() > 0 && line.indexOf(endText) >= 0) {
          collect = false;
        }
        else {
          if (module == "coreaudio") {
            QString coreAudioMatch = "=> CoreAudio device";

            if (line.indexOf(coreAudioMatch) >= 0) {
              line = line.mid(coreAudioMatch.length()).trimmed();

              QPair<QString, QString> device;
              device.first = line.mid(line.indexOf(":")).trimmed();
              device.second = "dac" + line.left(line.indexOf(":"));
              deviceList.append(device);
            }
          } // if not coreaudio, i.e. portaudio
          else if (line.indexOf(":") >= 0) {
            QPair<QString, QString> device;
            device.first = line.mid(line.indexOf(":") + 1).trimmed();
            device.second = "dac" + line.left(line.indexOf(":")).trimmed();
            deviceList.append(device);
          }
        }
      }
      else if (line.indexOf(startText) >= 0) {
        collect = true;
      }
    }
  }
  return deviceList;
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
