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

#include <QCheckBox>
#include <QGroupBox>
#include <QLabel>
#include <QLineEdit>
#include <QRadioButton>
#include <QVBoxLayout>
#include <QGridLayout>
#include <QListWidget>


#include "appwizard.h"
#include "appdetailspage.h"
#include "additionalfilespage.h"
#include "pluginspage.h"


AppWizard::AppWizard(QWidget *parent,QString opcodeDir) :
    QWizard(parent)
{
  addPage(new AppDetailsPage);
  addPage(new PluginsPage(this, opcodeDir));
  addPage(new AdditionalFilesPage(this));
//  addPage(new CodeStylePage);
//  addPage(new OutputFilesPage);
//  addPage(new ConclusionPage);
//
//  setPixmap(QWizard::BannerPixmap, QPixmap(":/images/banner.png"));
//  setPixmap(QWizard::BackgroundPixmap, QPixmap(":/images/background.png"));

  setWindowTitle(tr("Standalone Application Generator"));
}

void AppWizard::accept()
{
  QString appName =  field("appName").toString();
  QString targetDir =  field("targetDir").toString();
  bool autorun =  field("autorun").toBool();
//  int platform =  field("platform").toBool();
  QDialog::accept();
}


