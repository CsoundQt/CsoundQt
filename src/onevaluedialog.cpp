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

#include "onevaluedialog.h"
#include "ui_onevaluedialog.h"

OneValueDialog::OneValueDialog(QWidget *parent) :
    QDialog(parent),
    m_ui(new Ui::OneValueDialog)
{
    m_ui->setupUi(this);
    m_ui->valueSpinBox->setFocus(Qt::OtherFocusReason);
    m_ui->valueSpinBox->selectAll();
}

OneValueDialog::~OneValueDialog()
{
    delete m_ui;
}

double OneValueDialog::value()
{
  return m_ui->valueSpinBox->value();
}

void OneValueDialog::changeEvent(QEvent *e)
{
    QDialog::changeEvent(e);
    switch (e->type()) {
    case QEvent::LanguageChange:
        m_ui->retranslateUi(this);
        break;
    default:
        break;
    }
}
