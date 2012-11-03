/*
	Copyright (C) 2010 Andres Cabrera
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

#include "pluginspage.h"
#include "ui_pluginspage.h"

#include <QDir>
#include <QDebug>

PluginsPage::PluginsPage(QWidget *parent, QString opcodeDir) :
	QWizardPage(parent),
	ui(new Ui::PluginsPage)
{
	ui->setupUi(this);
	connect(ui->selectAllButton, SIGNAL(released()), this, SLOT(selectAll()));
	connect(ui->selectNoneButton, SIGNAL(released()), this, SLOT(selectNone()));
	connect(ui->deselectFltkButton, SIGNAL(released()), this, SLOT(deselectFltk()));
	//  registerField("plugins", ui->pluginsListWidget);
	connect(ui->pluginsListWidget, SIGNAL(itemSelectionChanged () ), this, SLOT(selectionChanged()));
	if (!opcodeDir.isEmpty()) {
		setField("opcodeDir", opcodeDir);
	}
	updateOpcodeDir();
}

PluginsPage::~PluginsPage()
{
	delete ui;
}

void PluginsPage::selectAll()
{
	ui->pluginsListWidget->selectAll();
}

void PluginsPage::selectNone()
{
	ui->pluginsListWidget->clearSelection();
}

void PluginsPage::deselectFltk()
{
	QList<QString> fltkNames;
	fltkNames << "libwidgets" << "libvirtual" << "libfluidOpcodes";
	QList<QListWidgetItem *> selected = ui->pluginsListWidget->selectedItems();
	foreach (QListWidgetItem *item, selected) {
		foreach (QString name, fltkNames) {
			if (item->text().startsWith(name)) {
				item->setSelected(false);
			}
		}
	}
}

void PluginsPage::updateOpcodeDir()
{
	QStringList filters;
	QStringList plugins;
	QString opcodeDir = field("opcodeDir").toString();
#ifdef Q_OS_MAC
	opcodeDir = field("libDir").toString() + "/CsoundLib";
	if (field("useDoubles").toBool()) {
		opcodeDir += "64";
	}
	opcodeDir += ".framework/Resources/Opcodes";
	if (!QFile::exists(opcodeDir) && !field("opcodeDir").toString().isEmpty() ) {
		opcodeDir = field("opcodeDir").toString();
	}
#endif
	qDebug() << "PluginsPage::updateOpcodeDir " << opcodeDir;
#ifdef Q_OS_LINUX
	filters << "*.so";
#endif
#ifdef Q_OS_MAC
	filters << "*.dylib";
#endif
#ifdef Q_OS_WIN32
	filters << "*.dll";
#endif
	plugins = QDir(opcodeDir).entryList(filters);
	foreach (QString plugin, plugins) {
		if (!plugin.startsWith(".")) {
			ui->pluginsListWidget->addItem(plugin);
		}
	}
	m_opcodeDir = opcodeDir;
	ui->pluginsListWidget->selectAll();
}

QString PluginsPage::getOpcodeDir()
{
	return m_opcodeDir;
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

void PluginsPage::selectionChanged()
{
	QList<QListWidgetItem *> selected = ui->pluginsListWidget->selectedItems();
	QStringList plugins;
	foreach (QListWidgetItem *item, selected) {
		plugins << item->text();
	}
	setProperty("plugins", plugins);
}
