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

#include "appdetailspage.h"
#include "ui_appdetailspage.h"

#include <QFileDialog>

AppDetailsPage::AppDetailsPage(QWidget *parent) :
    QWizardPage(parent),
    ui(new Ui::AppDetailsPage)
{
  ui->setupUi(this);
  registerField("appName", ui->appNameLineEdit);

  registerField("targetDir", ui->targetDirLineEdit);
  registerField("autorun", ui->autorunCheckBox);
  registerField("platform", ui->platformComboBox);
  registerField("useDoubles", ui->presicionComboBox);
  registerField("libDir", ui->libLineEdit);
  registerField("opcodeDir", ui->opcodeLineEdit);
  registerField("sdkDir", ui->sdkLineEdit);

  connect(ui->browseTargetButton,SIGNAL(released()),
          this, SLOT(browseTarget()));
  connect(ui->browseLibraryButton,SIGNAL(released()),
          this, SLOT(browseLibrary()));
  connect(ui->browseOpcodesButton,SIGNAL(released()),
          this, SLOT(browseOpcodes()));
  connect(ui->browseSdkButton,SIGNAL(released()),
          this, SLOT(browseSdk()));
  connect(ui->opcodeLineEdit, SIGNAL(textChanged(QString)),
          this, SLOT(opcodeDirChanged()));
  connect(ui->libLineEdit, SIGNAL(textChanged(QString)),
          this, SLOT(libDirChanged()));
#ifdef Q_OS_MAC
  ui->libLabel->setText("Framework Dir");
  ui->opcodeLineEdit->hide();
  ui->browseOpcodesButton->hide();
  ui->opcodeDirLabel->hide();
#endif
}

AppDetailsPage::~AppDetailsPage()
{
    delete ui;
}

void AppDetailsPage::changeEvent(QEvent *e)
{
    QWizardPage::changeEvent(e);
    switch (e->type()) {
    case QEvent::LanguageChange:
        ui->retranslateUi(this);
        break;
    default:
        break;
    }
}

void AppDetailsPage::browseTarget()
{
  QString destination = field("targetDir").toString();
  QString dir =  QFileDialog::QFileDialog::getExistingDirectory(this,tr("Select Target Directory"),destination);
  if (dir!="") {
    setField("targetDir", dir);
  }
}

void AppDetailsPage::browseLibrary()
{
  QString destination = field("libDir").toString();
  QString dir =  QFileDialog::QFileDialog::getExistingDirectory(this,tr("Select Csound Library Directory"),destination);
  if (dir!="") {
    setField("libDir", dir);
  }
}

void AppDetailsPage::browseOpcodes()
{
  QString destination = field("opcodeDir").toString();
  QString dir =  QFileDialog::QFileDialog::getExistingDirectory(this,tr("Select Csound Opcodes Directory"),destination);
  if (dir!="") {
    setField("opcodeDir", dir);
  }
}

void AppDetailsPage::browseSdk()
{
  QString destination = field("sdkDir").toString();
  QString dir =  QFileDialog::QFileDialog::getExistingDirectory(this,tr("Select QuteCsound SDK Directory"),destination);
  if (dir!="") {
    setField("sdkDir", dir);
  }
}


void AppDetailsPage::platformChanged()
{
  emit platformChangedSignal();
}

void AppDetailsPage::opcodeDirChanged()
{
  emit opcodeDirChangedSignal();
}

void AppDetailsPage::libDirChanged()
{
  emit libDirChangedSignal();
}

