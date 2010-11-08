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

#include "appwizard.h"
#include <QCheckBox>
#include <QGroupBox>
#include <QLabel>
#include <QLineEdit>
#include <QRadioButton>
#include <QVBoxLayout>
#include <QGridLayout>
#include <QListWidget>


AppWizard::AppWizard(QWidget *parent) :
    QWizard(parent)
{
  addPage(new PathPage);
  addPage(new PluginsPage);
//  addPage(new CodeStylePage);
//  addPage(new OutputFilesPage);
//  addPage(new ConclusionPage);
//
//  setPixmap(QWizard::BannerPixmap, QPixmap(":/images/banner.png"));
//  setPixmap(QWizard::BackgroundPixmap, QPixmap(":/images/background.png"));

  setWindowTitle(tr("Standalone Application Generator"));
}

//void AppWizard::accept()
//{
//  QDialog::accept();
//}

PathPage::PathPage(QWidget *parent)
    : QWizardPage(parent)
{
    setTitle(tr("Class Information"));
    setSubTitle(tr("Specify basic information about the class for which you "
                   "want to generate skeleton source code files."));
    setPixmap(QWizard::LogoPixmap, QPixmap(":/images/logo1.png"));

    classNameLabel = new QLabel(tr("&Class name:"));
    classNameLineEdit = new QLineEdit;
    classNameLabel->setBuddy(classNameLineEdit);

    baseClassLabel = new QLabel(tr("B&ase class:"));
    baseClassLineEdit = new QLineEdit;
    baseClassLabel->setBuddy(baseClassLineEdit);

    qobjectMacroCheckBox = new QCheckBox(tr("Generate Q_OBJECT &macro"));

    groupBox = new QGroupBox(tr("C&onstructor"));

    qobjectCtorRadioButton = new QRadioButton(tr("&QObject-style constructor"));
    qwidgetCtorRadioButton = new QRadioButton(tr("Q&Widget-style constructor"));
    defaultCtorRadioButton = new QRadioButton(tr("&Default constructor"));
    copyCtorCheckBox = new QCheckBox(tr("&Generate copy constructor and "
                                        "operator="));

    defaultCtorRadioButton->setChecked(true);

    connect(defaultCtorRadioButton, SIGNAL(toggled(bool)),
            copyCtorCheckBox, SLOT(setEnabled(bool)));

    registerField("className*", classNameLineEdit);
    registerField("baseClass", baseClassLineEdit);
    registerField("qobjectMacro", qobjectMacroCheckBox);
    registerField("qobjectCtor", qobjectCtorRadioButton);
    registerField("qwidgetCtor", qwidgetCtorRadioButton);
    registerField("defaultCtor", defaultCtorRadioButton);
    registerField("copyCtor", copyCtorCheckBox);

    QVBoxLayout *groupBoxLayout = new QVBoxLayout;
    groupBoxLayout->addWidget(qobjectCtorRadioButton);
    groupBoxLayout->addWidget(qwidgetCtorRadioButton);
    groupBoxLayout->addWidget(defaultCtorRadioButton);
    groupBoxLayout->addWidget(copyCtorCheckBox);
    groupBox->setLayout(groupBoxLayout);

    QGridLayout *layout = new QGridLayout;
    layout->addWidget(classNameLabel, 0, 0);
    layout->addWidget(classNameLineEdit, 0, 1);
    layout->addWidget(baseClassLabel, 1, 0);
    layout->addWidget(baseClassLineEdit, 1, 1);
    layout->addWidget(qobjectMacroCheckBox, 2, 0, 1, 2);
    layout->addWidget(groupBox, 3, 0, 1, 2);
    setLayout(layout);
}


PluginsPage::PluginsPage(QWidget *parent)
    : QWizardPage(parent)
{

}
