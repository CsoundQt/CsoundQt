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

#include "settingsdialog.h"
#include "ui_settingsdialog.h"

#include <QTemporaryFile>
#include <QFile>
#include <QDebug>
#include <QProcess>
#include <QMessageBox>

#include "types.h"

#ifdef QCS_RTMIDI
#include "RtMidi.h"
#endif


SettingsDialog::SettingsDialog(QWidget *parent, CsoundOptions *options) :
  QDialog(parent),
  ui(new Ui::SettingsDialog), m_options(options)
{
  ui->setupUi(this);

  refreshAudioIn();
  refreshAudioOut();
  refreshMidiIn();
  refreshMidiOut();
  refreshMidiControl();

  ui->audioInComboBox->setCurrentIndex(ui->audioInComboBox->findData(m_options->rtInputDevice));
  ui->audioOutComboBox->setCurrentIndex(ui->audioOutComboBox->findData(m_options->rtOutputDevice));
  ui->midiInComboBox->setCurrentIndex(ui->midiInComboBox->findData(m_options->rtMidiInputDevice));
  ui->midiOutComboBox->setCurrentIndex(ui->midiOutComboBox->findData(m_options->rtMidiOutputDevice));

  if (ui->audioInComboBox->currentIndex() < 0) {
    ui->audioInComboBox->setCurrentIndex(0);
  }
  if (ui->audioOutComboBox->currentIndex() < 0) {
    ui->audioOutComboBox->setCurrentIndex(0);
  }
  if (ui->midiInComboBox->currentIndex() < 0) {
    ui->midiInComboBox->setCurrentIndex(0);
  }
  if (ui->midiOutComboBox->currentIndex() < 0) {
    ui->midiOutComboBox->setCurrentIndex(0);
  }

  ui->bufferCheckBox->setChecked(m_options->bufferSizeActive);
  ui->hwBufferCheckBox->setChecked(m_options->HwBufferSizeActive);
  ui->bufferComboBox->setCurrentIndex(ui->bufferComboBox->findText(QString::number(m_options->bufferSize)));
  ui->hwBufferComboBox->setCurrentIndex(ui->hwBufferComboBox->findText(QString::number(m_options->HwBufferSize)));

  ui->midiInterfaceComboBox->hide();
#ifdef QCS_RTMIDI
  try {
    RtMidiIn midiin;
    for (int i = 0; i < (int) midiin.getPortCount(); i++) {
      ui->midiInterfaceComboBox->addItem(QString::fromStdString(midiin.getPortName(i)), QVariant(i));
    }
  }
  catch (RtError &error) {
    // Handle the exception here
    error.printMessage();
  }
#endif
}

SettingsDialog::~SettingsDialog()
{
  delete ui;
}

QStringList SettingsDialog::getFlags()
{
  QStringList flags;
  flags << "-+rtaudio=portaudio";
  flags << ui->audioInComboBox->itemData(ui->audioInComboBox->currentIndex()).toStringList();
  flags << ui->audioOutComboBox->itemData(ui->audioOutComboBox->currentIndex()).toStringList();
  return flags;
}

void SettingsDialog::refreshAudioIn()
{
  QStringList rtmodules;
  int curIndex = ui->audioInComboBox->currentIndex();
  ui->audioInComboBox->clear();
#ifdef Q_OS_LINUX
  rtmodules << "alsa" << "portaudio" << "jack";
#endif
#ifdef Q_OS_WIN32
  rtmodules << "portaudio" << "winmme";
#endif
#ifdef Q_OS_MAC
  rtmodules << "auhal" << "portaudio";
#endif
  ui->audioInComboBox->addItem("None", "");
  ui->audioInComboBox->setItemData(ui->audioInComboBox->count() - 1,
                                   "", Qt::UserRole + 1);
  ui->audioInComboBox->addItem("default", "adc");
  ui->audioInComboBox->setItemData(ui->audioInComboBox->count() - 1,
                                   "", Qt::UserRole + 1);

  foreach (QString module, rtmodules) {
    int moduleIndex = _configlists.rtAudioNames.indexOf(module);
    if (moduleIndex < 0) {continue;}
    QList<QPair<QString, QString> > deviceList = _configlists.getAudioInputDevices(moduleIndex);
    for (int i = 0; i < deviceList.size(); i++) {
      ui->audioInComboBox->addItem(deviceList[i].first+ " (" + module + ")",
                                   deviceList[i].second);
      ui->audioInComboBox->setItemData(ui->audioInComboBox->count() - 1,
                                       module, Qt::UserRole + 1);
    }
  }
  ui->audioInComboBox->setCurrentIndex(curIndex);
}

void SettingsDialog::refreshAudioOut()
{
  QStringList rtmodules;

  int curIndex = ui->audioOutComboBox->currentIndex();
  ui->audioOutComboBox->clear();
#ifdef Q_OS_LINUX
  rtmodules << "alsa" << "portaudio" << "jack";
#endif
#ifdef Q_OS_WIN32
  rtmodules << "portaudio" << "winmme";
#endif
#ifdef Q_OS_MAC
  rtmodules << "auhal" << "portaudio";
#endif
  ui->audioOutComboBox->addItem("None", "");
  ui->audioOutComboBox->setItemData(ui->audioOutComboBox->count() - 1,
                                   "", Qt::UserRole + 1);
  ui->audioOutComboBox->addItem("default", "dac");
  ui->audioOutComboBox->setItemData(ui->audioInComboBox->count() - 1,
                                   "", Qt::UserRole + 1);
  foreach (QString module, rtmodules) {
    int moduleIndex = _configlists.rtAudioNames.indexOf(module);
    if (moduleIndex < 0) {continue;}
    QList<QPair<QString, QString> > deviceList = _configlists.getAudioOutputDevices(moduleIndex);

    for (int i = 0; i < deviceList.size(); i++) {
      ui->audioOutComboBox->addItem(deviceList[i].first + " (" + module + ")",
                                    deviceList[i].second);
      ui->audioOutComboBox->setItemData(ui->audioOutComboBox->count() - 1,
                                        module, Qt::UserRole + 1);
    }
  }
  ui->audioOutComboBox->setCurrentIndex(curIndex);
}

void SettingsDialog::refreshMidiIn()
{
  QStringList rtmodules;
  int curIndex = ui->midiInComboBox->currentIndex();
  ui->midiInComboBox->clear();
#ifdef Q_OS_LINUX
  rtmodules << "alsa" << "portmidi";
#endif
#ifdef Q_OS_WIN32
  rtmodules << "winmme" << "portmidi" ;
#endif
#ifdef Q_OS_MAC
  rtmodules << "auhal" << "portmidi";
#endif

  ui->midiInComboBox->addItem("None", "");
  ui->midiInComboBox->setItemData(ui->midiInComboBox->count() - 1,
                                  "", Qt::UserRole + 1);
  foreach (QString module, rtmodules) {
    int moduleIndex = _configlists.rtMidiNames.indexOf(module);
    if (moduleIndex < 0) {continue;}
    QList<QPair<QString, QString> > deviceList = _configlists.getMidiInputDevices(moduleIndex);

    for (int i = 0; i < deviceList.size(); i++) {
      ui->midiInComboBox->addItem(deviceList[i].first + " (" + module + ")",
                                  deviceList[i].second);
      ui->midiInComboBox->setItemData(ui->midiInComboBox->count() - 1,
                                      module, Qt::UserRole + 1);
    }
  }

  ui->midiInComboBox->setCurrentIndex(curIndex);
}

void SettingsDialog::refreshMidiOut()
{
  QStringList rtmodules;
  int curIndex = ui->midiOutComboBox->currentIndex();
  ui->midiOutComboBox->clear();
#ifdef Q_OS_LINUX
  rtmodules << "alsa" << "portmidi";
#endif
#ifdef Q_OS_WIN32
  rtmodules << "winmme" << "portmidi" ;
#endif
#ifdef Q_OS_MAC
  rtmodules << "auhal" << "portmidi";
#endif
  ui->midiOutComboBox->addItem("None", "");
  ui->midiOutComboBox->setItemData(ui->midiOutComboBox->count() - 1,
                                  "", Qt::UserRole + 1);
  foreach (QString module, rtmodules) {
    int moduleIndex = _configlists.rtMidiNames.indexOf(module);
    if (moduleIndex < 0) {continue;}
    QList<QPair<QString, QString> > deviceList = _configlists.getMidiOutputDevices(moduleIndex);

    for (int i = 0; i < deviceList.size(); i++) {
      ui->midiOutComboBox->addItem(deviceList[i].first + " (" + module + ")",
                                   deviceList[i].second);
      ui->midiOutComboBox->setItemData(ui->midiOutComboBox->count() - 1,
                                       module, Qt::UserRole + 1);
    }
  }
  ui->midiOutComboBox->setCurrentIndex(curIndex);
}

void SettingsDialog::refreshMidiControl()
{
}

void SettingsDialog::accept()
{
  QString audioModule = ui->audioInComboBox->itemData(ui->audioInComboBox->currentIndex(),
                                                      Qt::UserRole + 1).toString();
  QString audioModule2 = ui->audioOutComboBox->itemData(ui->audioOutComboBox->currentIndex(),
                                                        Qt::UserRole + 1).toString();
  if (!audioModule.isEmpty() && !audioModule2.isEmpty()
      && audioModule != audioModule2) {
    QMessageBox::warning(this, tr("Error"),
                         tr("Please use the same Audio module for input and output device."));
    return;
  }
  QString midiModule = ui->midiInComboBox->itemData(ui->midiInComboBox->currentIndex(),
                                                    Qt::UserRole + 1).toString();
  QString midiModule2 = ui->midiOutComboBox->itemData(ui->midiOutComboBox->currentIndex(),
                                                      Qt::UserRole + 1).toString();
  if (!midiModule.isEmpty() && !midiModule2.isEmpty()
      && midiModule != midiModule2) {
    QMessageBox::warning(this, tr("Error"),
                         tr("Please use the same MIDI module for input and output device."));
    return;
  }
  m_options->rtAudioModule = _configlists.rtAudioNames.indexOf(audioModule);
  m_options->rtMidiModule = _configlists.rtMidiNames.indexOf(midiModule);
  if (m_options->rtAudioModule < 0) {
    m_options->rtAudioModule = 0;
  }
  if (m_options->rtMidiModule < 0) {
    m_options->rtMidiModule = 0;
  }
  m_options->rtInputDevice = ui->audioInComboBox->itemData(ui->audioInComboBox->currentIndex()).toString();
  m_options->rtOutputDevice = ui->audioOutComboBox->itemData(ui->audioOutComboBox->currentIndex()).toString();
  m_options->rtMidiInputDevice = ui->midiInComboBox->itemData(ui->midiInComboBox->currentIndex()).toString();
  m_options->rtMidiOutputDevice = ui->midiOutComboBox->itemData(ui->midiOutComboBox->currentIndex()).toString();

  m_options->bufferSizeActive = ui->bufferCheckBox->isChecked();
  m_options->HwBufferSizeActive = ui->hwBufferCheckBox->isChecked();
  m_options->bufferSize = ui->bufferComboBox->currentText().toInt();
  m_options->HwBufferSize = ui->hwBufferComboBox->currentText().toInt();

  // FIXME fix support for midi control of widgets.
//  m_options->midiInterface = midiInterfaceComboBox->itemData(midiInterfaceComboBox->currentIndex()).toInt();

  QDialog::accept();
}

void SettingsDialog::changeEvent(QEvent *e)
{
  QDialog::changeEvent(e);
  switch (e->type()) {
  case QEvent::LanguageChange:
    ui->retranslateUi(this);
    break;
  default:
    break;
  }
}
