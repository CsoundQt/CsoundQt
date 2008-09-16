/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#include <QtGui>
#include "utilitiesdialog.h"
#include "configlists.h"
#include "options.h"
#include "types.h"

UtilitiesDialog::UtilitiesDialog(QWidget *parent, Options *options, ConfigLists *m_configlist)
  : QDialog(parent), m_options(options)
{
  setupUi(this);
}


UtilitiesDialog::~UtilitiesDialog()
{
}




void UtilitiesDialog::browseFile(QString &destination, QString extension)
{
  QString file =  QFileDialog::QFileDialog::getOpenFileName(this,tr("Select File"),destination);
  if (file!="")
    destination = file;
}

void UtilitiesDialog::browseDir(QString &destination)
{
  QString dir =  QFileDialog::QFileDialog::getExistingDirectory(this,tr("Select Directory"),destination);
  if (dir!="")
    destination = dir;
}
