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

#include "dockhelp.h"

#include <QTextBrowser>
#include <QTextDocument>
#include <QTextStream>
#include <QPushButton>
#include <QFile>
#include <QMessageBox>
#include <QDir>

DockHelp::DockHelp(QWidget *parent)
  : QDockWidget(parent)
{
  setWindowTitle("Opcode Help");
  setMinimumSize(400,200);
  text = new QTextBrowser(this);
  text->setAcceptRichText(true);
  text->setOpenLinks(false);
  connect(text, SIGNAL(anchorClicked(QUrl)), this, SLOT(followLink(QUrl)));
  setWidget (text);
  QPushButton* backButton = new QPushButton(QIcon(":/images/gtk-media-play-trl.png"), "", this);
  backButton->move(100, 3);
  backButton->resize(25, 25);
  connect(backButton, SIGNAL(released()), this, SLOT(browseBack()));
  QPushButton* forwardButton = new QPushButton(QIcon(":/images/gtk-media-play-ltr.png"), "", this);
  forwardButton->move(130, 3);
  forwardButton->resize(25, 25);
  connect(forwardButton, SIGNAL(released()), this, SLOT(browseForward()));
}

DockHelp::~DockHelp()
{
}

bool DockHelp::hasFocus()
{
  return QDockWidget::hasFocus() || text->hasFocus();
}

void DockHelp::loadFile(QString fileName)
{
  QFile file(fileName);
  if (!file.open(QFile::ReadOnly | QFile::Text)) {
//     QMessageBox::warning(this, tr("QuteCsound"),
//                          tr("Cannot read file %1:\n%2.")
//                              .arg(fileName)
//                              .arg(file.errorString()));
    text->setText(tr("Not Found! Make sure the documentation path is set in the Configuration Dialog."));
    return;
  }
  //FIXME: Fix this hack so it works fine in windows as well...
  QStringList searchPaths;
  searchPaths << docDir;
  text->setSearchPaths(searchPaths);
#ifdef WIN32
  QTextStream in(&file);
  in.setAutoDetectUnicode(true);
  text->setHtml(in.readAll());
#else
  text->setSource(QUrl(fileName));
#endif

}

void DockHelp::closeEvent(QCloseEvent * /*event*/)
{
  emit Close(false);
}

void DockHelp::showGen()
{
  this->setVisible(true);
  this->loadFile(docDir + "/ScoreGenRef.html");
}

void DockHelp::showOverview()
{
  this->setVisible(true);
  this->loadFile(docDir + "/PartOpcodesOverview.html");
}

void DockHelp::browseBack()
{
  text->backward();
}

void DockHelp::browseForward()
{
  text->forward();
}

void DockHelp::followLink(QUrl url)
{
  if (url.host() == "") {
    // Will not follow external links for safety, only local files
    if (url.toString().endsWith(".csd")) {
      emit openManualExample(url.toLocalFile());
    }
    else {
    text->setSource(url);
    }
  }
  else {
    QMessageBox::warning(this, tr("QuteCsound"),
                    tr("External links can't be followed in help browser."));
  }
}

void DockHelp::copy()
{
  text->copy();
}
