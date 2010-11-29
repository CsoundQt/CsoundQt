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

#include "pluginspage.h"
#include "ui_pluginspage.h"

#include <QDir>

PluginsPage::PluginsPage(QWidget *parent, QString opcodeDir) :
    QWizardPage(parent),
    ui(new Ui::PluginsPage)
{
    ui->setupUi(this);
    connect(ui->selectAllButton, SIGNAL(released()), this, SLOT(selectAll()));
    connect(ui->selectNoneButton, SIGNAL(released()), this, SLOT(selectNone()));
    connect(ui->deselectFltkButton, SIGNAL(released()), this, SLOT(deselectFltk()));
    QStringList filters;
    QStringList plugins;
    QString platform = field("platform").toString();
    if (platform == 0) { // Linux
      filters << "*.so";
    }
    else if (platform == 0) { // OS X
      filters << "*.dylib";
    }
    else if  (platform == 0) { // Windows
      filters << "*.dll";
    }
    plugins = QDir(opcodeDir).entryList(filters);
    foreach (QString plugin, plugins) {
      ui->listWidget->addItem(plugin);
    }
    ui->listWidget->selectAll();
    registerField("plugins", ui->listWidget);
}

PluginsPage::~PluginsPage()
{
    delete ui;
}

void PluginsPage::selectAll()
{
  ui->listWidget->selectAll();
}

void PluginsPage::selectNone()
{
  ui->listWidget->clearSelection();
}

void PluginsPage::deselectFltk()
{
  ui->listWidget->clearSelection();

}

void PluginsPage::changeEvent(QEvent *e)
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
