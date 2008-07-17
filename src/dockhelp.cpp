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
#include "dockhelp.h"

#include <QTextBrowser>
#include <QTextDocument>
#include <QTextStream>
#include <QFile>
#include <QMessageBox>

DockHelp::DockHelp(QWidget *parent)
  : QDockWidget(parent)
{
  setWindowTitle("Opcode Help");
  text = new QTextBrowser();
  text->setAcceptRichText(true);
  setWidget (text);
  QString index = QString(DEFAULT_HTML_DIR) + QString("/index.html");
  loadFile(index);
}

DockHelp::~DockHelp()
{
}

void DockHelp::loadFile(QString fileName)
{
  QFile file(fileName);
  if (!file.open(QFile::ReadOnly | QFile::Text)) {
    QMessageBox::warning(this, tr("QuteCsound"),
                         tr("Cannot read file %1:\n%2.")
                             .arg(fileName)
                             .arg(file.errorString()));
    return;
  }
  QTextStream in(&file);
  text->setSource (fileName);
  //text->setHtml(in.readAll());
}
