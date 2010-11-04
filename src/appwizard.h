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

#ifndef APPWIZARD_H
#define APPWIZARD_H

#include <QWizard>

class QCheckBox;
class QGroupBox;
class QLabel;
class QLineEdit;
class QRadioButton;

class AppWizard : public QWizard
{
Q_OBJECT
public:
    explicit AppWizard(QWidget *parent = 0);

signals:

public slots:

};

class PathPage : public QWizardPage
{
   Q_OBJECT

public:
   PathPage(QWidget *parent = 0);

private:
   QLabel *classNameLabel;
   QLabel *baseClassLabel;
   QLineEdit *classNameLineEdit;
   QLineEdit *baseClassLineEdit;
   QCheckBox *qobjectMacroCheckBox;
   QGroupBox *groupBox;
   QRadioButton *qobjectCtorRadioButton;
   QRadioButton *qwidgetCtorRadioButton;
   QRadioButton *defaultCtorRadioButton;
   QCheckBox *copyCtorCheckBox;
};

#endif // APPWIZARD_H
