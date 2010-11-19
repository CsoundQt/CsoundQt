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

#ifndef ADDITIONALFILESPAGE_H
#define ADDITIONALFILESPAGE_H

#include <QWizardPage>

namespace Ui {
    class AdditionalFilesPage;
}

class AdditionalFilesPage : public QWizardPage {
    Q_OBJECT
public:
    AdditionalFilesPage(QWidget *parent = 0);
    ~AdditionalFilesPage();

protected:
    void changeEvent(QEvent *e);

private:
    Ui::AdditionalFilesPage *ui;
};

#endif // ADDITIONALFILESPAGE_H
