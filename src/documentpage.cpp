/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
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
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              *
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
  text.replace(QRegExp("^\n\r^\n"), "\r\n");
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
    qDebug("<MacGUI> present.\n%s", macGUI.toStdString().c_str());
  }
  else {
    macGUI = "<MacGUI>\nioView nobackground {59352, 11885, 65535}\nioSlider {5, 5} {20, 100} 0.000000 1.000000 0.000000 slider1\nioSlider {45, 5} {20, 100} 0.000000 1.000000 0.000000 slider2\nioSlider {85, 5} {20, 100} 0.000000 1.000000 0.000000 slider3\nioSlider {125, 5} {20, 100} 0.000000 1.000000 0.000000 slider4\nioSlider {165, 5} {20, 100} 0.000000 1.000000 0.000000 slider5\n</MacGUI>";
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

QString DocumentPage::getMacWidgetsText()
{
  return macGUI;
}

void DocumentPage::setMacWidgetsText(QString text)
{
  qDebug("DocumentPage::setMacWidgetsText");
  macGUI = text;
  document()->setModified(true);
}
