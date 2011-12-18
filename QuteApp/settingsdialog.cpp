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
#include <QDir>


SettingsDialog::SettingsDialog(QWidget *parent, CsoundOptions *options) :
  QDialog(parent),
  ui(new Ui::SettingsDialog), m_options(options)
{
  ui->setupUi(this);
  m_csound = new Csound();
  m_csound->EnableMessageBuffer(0);

  refreshAudioIn();
  refreshAudioOut();
  refreshMidiIn();
  refreshMidiOut();
  refreshMidiControl();

  ui->audioInComboBox->setCurrentIndex(ui->audioInComboBox->findData(m_options->rtInputDevice));
  ui->audioOutComboBox->setCurrentIndex(ui->audioOutComboBox->findData(m_options->rtOutputDevice));
  ui->midiInComboBox->setCurrentIndex(ui->midiInComboBox->findData(m_options->rtMidiInputDevice));
  ui->midiOutComboBox->setCurrentIndex(ui->midiOutComboBox->findData(m_options->rtMidiOutputDevice));

}

SettingsDialog::~SettingsDialog()
{
  m_csound->DestroyMessageBuffer();
  delete m_csound;
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
  QStringList args;
  QString csOut;
  QMultiHash<QString, QString> devices;

  ui->audioInComboBox->clear();

  args << "-odac" << "-iadc99"<< "-+rtaudio=portaudio";
  csOut = runCsound(args);
  devices.unite(parsePortAudioIn(csOut));

  QMultiHash<QString, QString>::const_iterator it;
  for (it = devices.constBegin(); it != devices.constEnd(); it++ ) {
    ui->audioInComboBox->addItem(it.key(), it.value());
  }
}

void SettingsDialog::refreshAudioOut()
{
  QStringList args;
  QString csOut;
  QMultiHash<QString, QString> devices;

  ui->audioOutComboBox->clear();

  args << "-odac99" << "-+rtaudio=portaudio";
  csOut = runCsound(args);
  devices.unite(parsePortAudioOut(csOut));

  QMultiHash<QString, QString>::const_iterator it;
  for (it = devices.constBegin(); it != devices.constEnd(); it++ ) {
    ui->audioOutComboBox->addItem(it.key(), it.value());
  }
}

void SettingsDialog::refreshMidiIn()
{
}

void SettingsDialog::refreshMidiOut()
{
}

void SettingsDialog::refreshMidiControl()
{
}

void SettingsDialog::accept()
{
//  m_options->rtAudioModule = "portaudio";
  m_options->rtInputDevice = ui->audioInComboBox->itemData(ui->audioInComboBox->currentIndex()).toString();
  m_options->rtOutputDevice = ui->audioOutComboBox->itemData(ui->audioOutComboBox->currentIndex()).toString();
  m_options->rtMidiInputDevice = ui->midiInComboBox->itemData(ui->midiInComboBox->currentIndex()).toString();
  m_options->rtMidiInputDevice = ui->midiOutComboBox->itemData(ui->midiInComboBox->currentIndex()).toString();

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

QString SettingsDialog::runCsound(QStringList args)
{
  QString output;

  QTemporaryFile f("QuteApp-temp-XXXXXX.csd");
  if (!f.open()) {
    qDebug() << "SettingsDialog::runCsound error creating temp file. Aborting";
    return QString();
  }
  QFile csdFile(":/main/tester.csd");
  csdFile.open(QFile::ReadOnly);
  f.write(csdFile.readAll());
  f.flush();
  QString opcodeDir = QDir::currentPath();
  qDebug() << "...." << opcodeDir;
  csoundSetGlobalEnv("OPCODEDIR", opcodeDir.toLocal8Bit().data());
  csoundSetGlobalEnv("OPCODEDIR64", opcodeDir.toLocal8Bit().data());
  m_csound->Compile(f.fileName().toLocal8Bit().data(),
                    args.at(0).toLocal8Bit().data(),
                    args.at(1).toLocal8Bit().data(),
                    "--old-parser");
  m_csound->PerformKsmps();

  while (m_csound->GetMessageCnt() > 0) {
    output += QString(m_csound->GetFirstMessage());
    m_csound->PopFirstMessage();
  }
  m_csound->Cleanup();
  m_csound->Reset();
  qDebug() << output;
  return output;
}

QMultiHash<QString, QString> SettingsDialog::parsePortAudioIn(QString csOutput)
{
  QHash<QString, QString> devices;

  QStringList messages = csOutput.split("\n");

  QString startText, endText;
  startText = "PortAudio: available";
  endText = "error:";
  bool collect = false;
  foreach (QString line, messages) {
    if (collect) {
      if (endText.length() > 0 && line.indexOf(endText) >= 0) {
        collect = false;
      } else {
        if (line.indexOf(":") >= 0) {
          QString args = "adc" + line.left(line.indexOf(":")).trimmed();
          devices.insert(line.mid(line.indexOf(":") + 1).trimmed(),args);
        }
      }
    } else if (line.indexOf(startText) >= 0) {
      collect = true;
    }
  }
  return devices;
}

QMultiHash<QString, QString> SettingsDialog::parsePortAudioOut(QString csOutput)
{
  QHash<QString, QString> devices;

  QStringList messages = csOutput.split("\n");

  QString startText, endText;
  startText = "PortAudio: available";
  endText = "error:";
  bool collect = false;
  foreach (QString line, messages) {
    if (collect) {
      if (endText.length() > 0 && line.indexOf(endText) >= 0) {
        collect = false;
      } else {
        if (line.indexOf(":") >= 0) {
          QString args = "dac" + line.left(line.indexOf(":")).trimmed();
          devices.insert(line.mid(line.indexOf(":") + 1).trimmed(),args);
        }
      }
    } else if (line.indexOf(startText) >= 0) {
      collect = true;
    }
  }
  return devices;
}

QMultiHash<QString, QString> SettingsDialog::parseJackAudioIn(QString csOutput)
{
  QHash<QString, QString> devices;
  return devices;
}

