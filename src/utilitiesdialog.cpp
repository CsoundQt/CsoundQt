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
#include "utilitiesdialog.h"
#include "configlists.h"
#include "options.h"
#include "types.h"

UtilitiesDialog::UtilitiesDialog(QWidget *parent, Options *options/*, ConfigLists * m_configlist*/)
  : QDialog(parent), m_options(options)
{
  setupUi(this);

  helpBrowser->setAcceptRichText(true);
  QStringList searchPaths;
  searchPaths << m_options->csdocdir;
  helpBrowser->setSearchPaths(searchPaths);
  connect(tabWidget, SIGNAL(currentChanged(int)), this, SLOT(changeTab(int)));

  connect(atsaInputToolButton, SIGNAL(released()), this, SLOT(browseAtsaInput()));
  connect(atsaOutputToolButton, SIGNAL(released()), this, SLOT(browseAtsaOutput()));
  connect(pvInputToolButton, SIGNAL(released()), this, SLOT(browsePvInput()));
  connect(pvOutputToolButton, SIGNAL(released()), this, SLOT(browsePvOutput()));
  connect(hetInputToolButton, SIGNAL(released()), this, SLOT(browseHetInput()));
  connect(hetOutputToolButton, SIGNAL(released()), this, SLOT(browseHetOutput()));
  connect(lpInputToolButton, SIGNAL(released()), this, SLOT(browseLpInput()));
  connect(lpOutputToolButton, SIGNAL(released()), this, SLOT(browseLpOutput()));
  connect(cvInputToolButton, SIGNAL(released()), this, SLOT(browseCvInput()));
  connect(cvOutputToolButton, SIGNAL(released()), this, SLOT(browseCvOutput()));

  connect(atsaInputLineEdit, SIGNAL(textChanged(QString)), this, SLOT(setAtsaOutput(QString)));
  connect(pvInputLineEdit, SIGNAL(textChanged(QString)), this, SLOT(setPvanalOutput(QString)));
  connect(hetInputLineEdit, SIGNAL(textChanged(QString)), this, SLOT(setHetroOutput(QString)));
  connect(lpInputLineEdit, SIGNAL(textChanged(QString)), this, SLOT(setLpanalOutput(QString)));
  connect(cvInputLineEdit, SIGNAL(textChanged(QString)), this, SLOT(setCvanalOutput(QString)));
  changeHelp(m_options->csdocdir + "/cvanal.html");
}

UtilitiesDialog::~UtilitiesDialog()
{
}

void UtilitiesDialog::runAtsa()
{
  QString flags = "-U atsa ";

  flags += "-b" + atsaBeginLineEdit->text() + " ";
  flags += "-e" + atsaEndLineEdit->text() + " ";
  flags += "-l" + atsaLowestLineEdit->text() + " ";
  flags += "-H" + atsaHighestLineEdit->text() + " ";
  flags += "-d" + atsaDeviationLineEdit->text() + " ";
  flags += "-c" + atsaCycleLineEdit->text() + " ";
  flags += "-h" + atsaHopSizeLineEdit->text() + " ";
  flags += "-m" + atsaMagnitudeLineEdit->text() + " ";
  flags += "-t" + atsaLengthLineEdit->text() + " ";
  flags += "-s" + atsaMinSegmentLineEdit->text() + " ";
  flags += "-g" + atsaMinGapLineEdit->text() + " ";
  flags += "-T" + atsaThresholdLineEdit->text() + " ";
  flags += "-P" + atsaLastPeakLineEdit->text() + " ";
  flags += "-S" + atsaSmrLineEdit->text() + " ";
  flags += "-F" + QString::number(atsaFileTypeComboBox->currentIndex()+1) + " ";
  flags += "-w" + QString::number(atsaWindowComboBox->currentIndex()) + " ";

  flags += "\"" + atsaInputLineEdit->text() + "\" ";
  flags += "\"" + atsaOutputLineEdit->text() + "\" ";

//   qDebug(flags.toStdString().c_str());
  emit(runUtility(flags));
}

void UtilitiesDialog::resetAtsa()
{
  atsaBeginLineEdit->setText("0.0");
  atsaEndLineEdit->setText("0.0");
  atsaLowestLineEdit->setText("20");
  atsaHighestLineEdit->setText("20000");
  atsaDeviationLineEdit->setText("0.1");
  atsaCycleLineEdit->setText("4");
  atsaHopSizeLineEdit->setText("0.25");
  atsaMagnitudeLineEdit->setText("-60");
  atsaLengthLineEdit->setText("3");
  atsaMinSegmentLineEdit->setText("3");
  atsaMinGapLineEdit->setText("3");
  atsaThresholdLineEdit->setText("30");
  atsaLastPeakLineEdit->setText("0.0");
  atsaSmrLineEdit->setText("0.5");
  atsaFileTypeComboBox->setCurrentIndex(0);
  atsaWindowComboBox->setCurrentIndex(0);
}

void UtilitiesDialog::setAtsaOutput(QString name)
{
  QString out = "";
  if (name.contains("."))
    out = name.left(name.lastIndexOf(".")) + ".ats";
  else
    out = name + ".ats";
  atsaOutputLineEdit->setText(out);
}

void UtilitiesDialog::runPvanal()
{
  QString flags = "-U pvanal ";

  flags += "-s" + pvSrLineEdit->text() + " ";
  flags += "-c" + pvChannelLineEdit->text() + " ";
  flags += "-b" + pvBeginLineEdit->text() + " ";
  flags += "-d" + pvDurationLineEdit->text() + " ";
  flags += "-n" + pvFrameLineEdit->text() + " ";
  flags += "-w" + pvOverlapLineEdit->text() + " ";

  switch (pvWindowComboBox->currentIndex()) {
    case 0:
      break;
    case 1:
      flags += "-H ";
      break;
    case 2:
      flags += "-K ";
      flags += "-B" + pvBetaLineEdit->text() ;
      break;
    default:
      break;
  }
  flags += "\"" + pvInputLineEdit->text() + "\" ";
  flags += "\"" + pvOutputLineEdit->text() + "\" ";

//   qDebug(flags.toStdString().c_str());
  emit(runUtility(flags));
}

void UtilitiesDialog::resetPvanal()
{
  pvSrLineEdit->setText("");
  pvChannelLineEdit->setText("1");
  pvBeginLineEdit->setText("0.0");
  pvDurationLineEdit->setText("0.0");
  pvFrameLineEdit->setText("1024");
  pvOverlapLineEdit->setText("4");

  pvWindowComboBox->setCurrentIndex(0);
  pvBetaLineEdit->setText("6.4");
}

void UtilitiesDialog::setPvanalOutput(QString name)
{
  QString out = "";
  if (name.contains("."))
    out = name.left(name.lastIndexOf(".")) + ".pvx";
  else
    out = name + ".pvx";
  pvOutputLineEdit->setText(out);
}

void UtilitiesDialog::runHetro()
{
  QString flags = "-U hetro ";

  flags += "-s" + hetSrLineEdit->text() + " ";
  flags += "-c" + hetChannelLineEdit->text() + " ";
  flags += "-b" + hetBeginLineEdit->text() + " ";
  flags += "-d" + hetDurationLineEdit->text() + " ";
  flags += "-f" + hetStartLineEdit->text() + " ";
  flags += "-h" + hetPartialsLineEdit->text() + " ";
  flags += "-M" + hetMaxLineEdit->text() + " ";
  flags += "-m" + hetMinLineEdit->text() + " ";
  flags += "-n" + hetBreakpointsLineEdit->text() + " ";
  flags += "-l" + hetCutoffLineEdit->text() + " ";
  flags += "\"" + hetInputLineEdit->text() + "\" ";
  flags += "\"" + hetOutputLineEdit->text() + "\" ";

//   qDebug(flags.toStdString().c_str());
  emit(runUtility(flags));
}

void UtilitiesDialog::resetHetro()
{
  hetSrLineEdit->setText("44100");
  hetChannelLineEdit->setText("1");
  hetBeginLineEdit->setText("0.0");
  hetDurationLineEdit->setText("0.0");
  hetStartLineEdit->setText("0.0");
  hetPartialsLineEdit->setText("10");
  hetMaxLineEdit->setText("32767");
  hetMinLineEdit->setText("64");
  hetBreakpointsLineEdit->setText("256");
  hetCutoffLineEdit->setText("0");
}

void UtilitiesDialog::setHetroOutput(QString name)
{
  QString out = "";
  if (name.contains("."))
    out = name.left(name.lastIndexOf(".")) + ".het";
  else
    out = name + ".het";
  hetOutputLineEdit->setText(out);
}

void UtilitiesDialog::runLpanal()
{
  QString flags = "-U lpanal ";

  flags += "-s" + lpSrLineEdit->text() + " ";
  flags += "-c" + lpChannelLineEdit->text() + " ";
  flags += "-b" + lpBeginLineEdit->text() + " ";
  flags += "-d" + lpDurationLineEdit->text() + " ";
  flags += "-p" + lpPolesLineEdit->text() + " ";
  flags += "-h" + lpHopSizeLineEdit->text() + " ";
  flags += "-P" + lpLowestLineEdit->text() + " ";
  flags += "-Q" + lpMaxLineEdit->text() + " ";
  flags += "-v" + QString::number(lpVerbosityComboBox->currentIndex()) + " ";
  if (lpAlternateCheckBox->isChecked())
    flags += "-a ";
  flags += "\"" + lpInputLineEdit->text() + "\" ";
  flags += "\"" + lpOutputLineEdit->text() + "\" ";

//   qDebug(flags.toStdString().c_str());
  emit(runUtility(flags));
}

void UtilitiesDialog::resetLpanal()
{
  lpSrLineEdit->setText("44100");
  lpChannelLineEdit->setText("1");
  lpBeginLineEdit->setText("0.0");
  lpDurationLineEdit->setText("0.0");
  lpPolesLineEdit->setText("34");
  lpHopSizeLineEdit->setText("200");
  lpVerbosityComboBox->setCurrentIndex(0);
  lpAlternateCheckBox->setChecked(true);
}

void UtilitiesDialog::setLpanalOutput(QString name)
{
  QString out = "";
  if (name.contains("."))
    out = name.left(name.lastIndexOf(".")) + ".lp";
  else
    out = name + ".lp";
  lpOutputLineEdit->setText(out);
}

void UtilitiesDialog::runCvanal()
{
  QString flags = "-U cvanal ";

  flags += "-s" + cvSrLineEdit->text() + " ";
  flags += "-b" + cvBeginLineEdit->text() + " ";
  flags += "-d" + cvDurationLineEdit->text() + " ";
  if (cvChannelLineEdit->text()!= "")
    flags += "-c" + cvChannelLineEdit->text() + " ";
  flags += "\"" + cvInputLineEdit->text() + "\" ";
  flags += "\"" + cvOutputLineEdit->text() + "\" ";

//   qDebug(flags.toStdString().c_str());
  emit(runUtility(flags));
}

void UtilitiesDialog::resetCvanal()
{
  cvSrLineEdit->setText("44100");
  cvBeginLineEdit->setText("0.0");
  cvDurationLineEdit->setText("0.0");
  cvChannelLineEdit->setText("");
}

void UtilitiesDialog::setCvanalOutput(QString name)
{
  QString out = "";
  if (name.contains("."))
    out = name.left(name.lastIndexOf(".")) + ".cv";
  else
    out = name + ".cv";
  cvOutputLineEdit->setText(out);
}

void UtilitiesDialog::browseAtsaInput()
{
  QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"));
  if (fileName != "")
    atsaInputLineEdit->setText(fileName);
}

void UtilitiesDialog::browseAtsaOutput()
{
  QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"));
  if (fileName != "")
    atsaOutputLineEdit->setText(fileName);
}

void UtilitiesDialog::browsePvInput()
{
  QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"));
  if (fileName != "")
    pvInputLineEdit->setText(fileName);
}

void UtilitiesDialog::browsePvOutput()
{
  QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"));
  if (fileName != "")
    pvOutputLineEdit->setText(fileName);
}

void UtilitiesDialog::browseHetInput()
{
  QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"));
  if (fileName != "")
    hetInputLineEdit->setText(fileName);
}

void UtilitiesDialog::browseHetOutput()
{
  QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"));
  if (fileName != "")
    hetOutputLineEdit->setText(fileName);
}

void UtilitiesDialog::browseLpInput()
{
  QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"));
  if (fileName != "")
    lpInputLineEdit->setText(fileName);
}

void UtilitiesDialog::browseLpOutput()
{
  QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"));
  if (fileName != "")
    lpOutputLineEdit->setText(fileName);
}

void UtilitiesDialog::browseCvInput()
{
  QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"));
  if (fileName != "")
    cvInputLineEdit->setText(fileName);
}

void UtilitiesDialog::browseCvOutput()
{
  QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"));
  if (fileName != "")
    cvOutputLineEdit->setText(fileName);
}

void UtilitiesDialog::browseFile(QString &destination, QString /*extension*/)
{
  QString file =  QFileDialog::getOpenFileName(this,tr("Select File"),destination);
  if (file!="")
    destination = file;
}

void UtilitiesDialog::browseDir(QString &destination)
{
  QString dir =  QFileDialog::getExistingDirectory(this,tr("Select Directory"),destination);
  if (dir!="")
    destination = dir;
}

void UtilitiesDialog::changeHelp(QString filename)
{
//  qDebug() << "UtilitiesDialog::changeHelp "  << filename;
  QFile file(filename);
  if (!file.open(QFile::ReadOnly | QFile::Text)) {
//     QMessageBox::warning(this, tr("QuteCsound"),
//                          tr("Cannot read file %1:\n%2.")
//                              .arg(fileName)
//                              .arg(file.errorString()));
    return;
  }
#ifdef Q_OS_WIN32
  QTextStream in(&file);
  in.setAutoDetectUnicode(true);
  helpBrowser->setHtml(in.readAll());
#else
  helpBrowser->setSource(QUrl(filename));
#endif
}

void UtilitiesDialog::changeTab(int tab)
{
  QString filename = m_options->csdocdir;
  switch (tab) {
    case 0:
      filename += "/cvanal.html";
      changeHelp(filename);
      break;
    case 1:
      filename += "/hetro.html";
      changeHelp(filename);
      break;
    case 2:
      filename += "/lpanal.html";
      changeHelp(filename);
      break;
    case 3:
      filename += "/pvanal.html";
      changeHelp(filename);
      break;
    case 4:
      filename += "/UtilityAtsa.html";
      changeHelp(filename);
      break;
    default:
      break;
  }
}

void UtilitiesDialog::closeEvent(QCloseEvent * /*event*/)
{
  emit Close(false);
}
