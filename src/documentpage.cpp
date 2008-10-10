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
#include "documentpage.h"

DocumentPage::DocumentPage(QWidget *parent):
    QTextEdit(parent)
{
  fileName = "";
  companionFile = "";
  askForFile = true;
}


DocumentPage::~DocumentPage()
{
}

int DocumentPage::setTextString(QString text)
{
  //TODO filter MacCsound elements
  if (text.contains("<MacOptions>") and text.contains("</MacOptions>")) {
    macOptions = text.right(text.size()-text.indexOf("<MacOptions>"));
    macOptions.resize(macOptions.indexOf("</MacOptions>") + 13);
    //Removes line breaks also
    text.remove(text.indexOf("<MacOptions>") - 1, macOptions.size() + 1);
    qDebug("<MacOptions> present.");
  }
  else {
    macOptions = "";
  }
  if (text.contains("<MacGUI>") and text.contains("</MacGUI>")) {
    macGUI = text.right(text.size()-text.indexOf("<MacGUI>"));
    macGUI.resize(macGUI.indexOf("</MacGUI>") + 9);
    //Removes line breaks also (there are two new lines at the end)
    //TODO something is odd here... some line breaks remain (possibly \r)
    text.remove(text.indexOf("<MacGUI>") - 1, macGUI.size() + 2);
    qDebug("<MacGUI> present.");
  }
  else {
    macGUI = "";
  }
  setPlainText(text);
  return 0;
}

QString DocumentPage::getFullText()
{
  QString fullText;
  fullText = document()->toPlainText();
  if (!fullText.endsWith("\n"))
    fullText += "\n";
  fullText += macOptions + "\n" + macGUI + "\n";
  return fullText;
}
