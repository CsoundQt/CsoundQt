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

#include "documentpage.h"
#include "qutecsound.h"
#include "opentryparser.h"
#include "types.h"
#include "dotgenerator.h"
#include "highlighter.h"
#include "liveeventframe.h"
#include "eventsheet.h"

DocumentPage::DocumentPage(QWidget *parent, OpEntryParser *opcodeTree):
    QTextEdit(parent), m_opcodeTree(opcodeTree)
{
  fileName = "";
  companionFile = "";
  macGUI = "";
  askForFile = true;
  readOnly = false;
  errorMarked = false;
  saveLiveEvents = true;
  m_highlighter = new Highlighter();
  connect(document(), SIGNAL(contentsChanged()), this, SLOT(changed()));
//   connect(this, SIGNAL(cursorPositionChanged()), this, SLOT(moved()));
}

DocumentPage::~DocumentPage()
{
  qDebug() << "DocumentPage::~DocumentPage()";
}

void DocumentPage::keyPressEvent(QKeyEvent *event)
{
  // TODO is this function necessary any more?
    if (event == QKeySequence::Cut)
    {
        emit doCut();
        return;
    }
    if (event == QKeySequence::Copy)
    {
        emit doCopy();
        return;
    }
    if (event == QKeySequence::Paste)
    {
        emit doPaste();
        return;
    }
    return QTextEdit::keyPressEvent(event);
}

void DocumentPage::contextMenuEvent(QContextMenuEvent *event)
{
  QMenu *menu = createStandardContextMenu();
  menu->addSeparator();
  QMenu *opcodeMenu = menu->addMenu("Opcodes");
  QMenu *mainMenu = 0;
  QMenu *subMenu;
  QString currentMain = "";
  for (int i = 0; i < m_opcodeTree->getCategoryCount(); i++) {
    QString category = m_opcodeTree->getCategory(i);
    QStringList categorySplit = category.split(":");
    if (!categorySplit.isEmpty() && categorySplit[0] != currentMain) {
      mainMenu = opcodeMenu->addMenu(categorySplit[0]);
      currentMain = categorySplit[0];
    }
    if (categorySplit.size() < 2) {
      subMenu = mainMenu;
    }
    else {
      subMenu = mainMenu->addMenu(categorySplit[1]);
    }
    foreach(Opcode opcode, m_opcodeTree->getOpcodeList(i)) {
      QAction *action = subMenu->addAction(opcode.opcodeName, this, SLOT(opcodeFromMenu()));
      action->setData(opcode.outArgs + opcode.opcodeName + opcode.inArgs);
    }
  }
  menu->exec(event->globalPos());
  delete menu;
}

void DocumentPage::closeEvent(QCloseEvent *event)
{
  qDebug() << "DocumentPage::closeEvent";
  for (int i = 0; i < liveEventFrames.size(); i++) {
    delete liveEventFrames[i];  // These widgets have the order not to delete on close
    liveEventFrames.remove(i);
  }
  delete m_highlighter;
  QTextEdit::closeEvent(event);
}

int DocumentPage::setTextString(QString text, bool autoCreateMacCsoundSections)
{
  if (text.contains("<MacOptions>") and text.contains("</MacOptions>")) {
    QString options = text.right(text.size()-text.indexOf("<MacOptions>"));
    options.resize(options.indexOf("</MacOptions>") + 13);
    setMacOptionsText(options);
//     qDebug("<MacOptions> present. \n%s", options.toStdString().c_str());
    if (text.indexOf("</MacOptions>") + 13 < text.size() and text[text.indexOf("</MacOptions>") + 13] == '\n')
      text.remove(text.indexOf("</MacOptions>") + 13, 1); //remove final line break
    if (text.indexOf("<MacOptions>") > 0 and text[text.indexOf("<MacOptions>") - 1] == '\n')
      text.remove(text.indexOf("<MacOptions>") - 1, 1); //remove initial line break
    text.remove(text.indexOf("<MacOptions>"), options.size());
//     qDebug("<MacOptions> present. %s", getMacOptions("WindowBounds").toStdString().c_str());
  }
  else {
    if (autoCreateMacCsoundSections) {
      QString defaultMacOptions = "<MacOptions>\nVersion: 3\nRender: Real\nAsk: Yes\nFunctions: ioObject\nListing: Window\nWindowBounds: 72 179 400 200\nCurrentView: io\nIOViewEdit: On\nOptions:\n</MacOptions>\n";
      setMacOptionsText(defaultMacOptions);
    }
    else
      setMacOptionsText("");
  }
  if (text.contains("<MacPresets>") and text.contains("</MacPresets>")) {
    macPresets = text.right(text.size()-text.indexOf("<MacPresets>"));
    macPresets.resize(macPresets.indexOf("</MacPresets>") + 12);
    if (text.indexOf("</MacPresets>") + 12 < text.size() and text[text.indexOf("</MacPresets>") + 12] == '\n')
      text.remove(text.indexOf("</MacPresets>") + 12, 1); //remove final line break
    if (text.indexOf("<MacPresets>") > 0 and text[text.indexOf("<MacPresets>") - 1] == '\n')
      text.remove(text.indexOf("<MacPresets>") - 1, 1); //remove initial line break
    text.remove(text.indexOf("<MacPresets>"), macPresets.size());
    qDebug("<MacPresets> present.");
  }
  else {
    macPresets = "";
  }
  if (text.contains("<MacGUI>") and text.contains("</MacGUI>")) {
    macGUI = text.right(text.size()-text.indexOf("<MacGUI>"));
    macGUI.resize(macGUI.indexOf("</MacGUI>") + 9);
    if (text.indexOf("</MacGUI>") + 9 < text.size() and text[text.indexOf("</MacGUI>") + 9] == '\n')
      text.remove(text.indexOf("</MacGUI>") + 9, 1); //remove final line break
    if (text.indexOf("<MacGUI>") > 0 and text[text.indexOf("<MacGUI>") - 1] == '\n')
      text.remove(text.indexOf("<MacGUI>") - 1, 1); //remove initial line break
    text.remove(text.indexOf("<MacGUI>"), macGUI.size());
//     qDebug("<MacGUI> present.");
  }
  else {
    if (autoCreateMacCsoundSections) {
      macGUI = "\n<MacGUI>\nioView nobackground {59352, 11885, 65535}\nioSlider {5, 5} {20, 100} 0.000000 1.000000 0.000000 slider1\n</MacGUI>\n";
    }
    else {
      macGUI = "";
    }
  }
  // This here is for compatibility with MacCsound
  QString optionsText = getMacOptions("Options:");
  if (optionsText.contains(" -o")) {
    QString outFile = optionsText.mid(optionsText.indexOf(" -o") + 1);
    int index = outFile.indexOf(" -");
    if (index > 0) {
      outFile = outFile.left(index);
    }
    optionsText.remove(outFile);
    setMacOption("Options:", optionsText);
    index = text.indexOf("<CsOptions>");
    int endindex = text.indexOf("</CsOptions>");
    if (index >= 0 and endindex > index) {
      text.remove(index, endindex - index);
      text.insert(index, "<CsOptions>\n" + outFile);
    }
    else {
      index = text.indexOf("<CsInstruments>");
      text.insert(index, "<CsOptions>\n" + outFile + "\n</CsOptions>\n");
    }
  }
  m_highlighter->setDocument(document());
  if (!text.contains("<CsoundSynthesizer>")) {//TODO this check is very flaky....
    setPlainText(text);
    document()->setModified(true);
    return 0;  // Don't add live event panel if not a csd file.
  }
  // Load Live Event Panels ------------------------
  while (text.contains("<EventPanel") and text.contains("</EventPanel>")) {
    QString liveEventsText = text.mid(text.indexOf("<EventPanel "),
                                      text.indexOf("</EventPanel>") - text.indexOf("<EventPanel ") + 13);
    qDebug() << "DocumentPage::setTextString   " << liveEventsText;
    LiveEventFrame *frame = newLiveEventFrame();
    QString scoText = liveEventsText.mid(liveEventsText.indexOf(">") + 1,
                                         liveEventsText.indexOf("</EventPanel>") - liveEventsText.indexOf(">") - 1 );
    frame->getSheet()->setRowCount(1);
    frame->getSheet()->setColumnCount(6);
    frame->setFromText(scoText);
//    frame->show();
    if (liveEventsText.contains("name=\"")) {
      int index = liveEventsText.indexOf("name=\"") + 6;
      QString name = liveEventsText.mid(index,
                                        liveEventsText.indexOf("\"", index) - index );
      frame->setName(name);
    }
    if (liveEventsText.contains("tempo=\"")) {
      int index = liveEventsText.indexOf("tempo=\"") + 7;
      QString tempostr = liveEventsText.mid(index,
                                            liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      double tempo = tempostr.toDouble(&ok);
      if (ok)
        frame->setTempo(tempo);
    }
    if (liveEventsText.contains("loop=\"")) {
      int index = liveEventsText.indexOf("loop=\"") + 6;
      QString loopstr = liveEventsText.mid(index,
                                           liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      double loop = loopstr.toDouble(&ok);
      if (ok)
        frame->setLoopLength(loop);
    }
    int posx, posy, width, height;
    if (liveEventsText.contains("x=\"")) {
      int index = liveEventsText.indexOf("x=\"") + 3;
      QString xstr = liveEventsText.mid(index,
                                        liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      posx = xstr.toInt(&ok);
      if (!ok)
        posx = frame->x();
    }
    if (liveEventsText.contains("y=\"")) {
      int index = liveEventsText.indexOf("y=\"") + 3;
      QString ystr = liveEventsText.mid(index,
                                        liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      posy = ystr.toInt(&ok);
      if (!ok)
        posy = frame->y();
    }
    if (liveEventsText.contains("width=\"")) {
      int index = liveEventsText.indexOf("width=\"") + 7;
      QString wstr = liveEventsText.mid(index,
                                        liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      width = wstr.toInt(&ok);
      if (!ok)
        width = frame->width();
    }
    if (liveEventsText.contains("height=\"")) {
      int index = liveEventsText.indexOf("height=\"") + 8;
      QString hstr = liveEventsText.mid(index,
                                        liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      height = hstr.toInt(&ok);
      if (!ok)
        height = frame->height();
    }
    frame->move(posx, posy);
    frame->resize(width, height);
    text.remove(liveEventsText);
  }
  if (liveEventFrames.size() == 0) {
    LiveEventFrame *e = newLiveEventFrame();
    e->setFromText(QString()); // Must set blank for undo history point
//    e->show();
  }
  setPlainText(text);
  document()->setModified(true);
  return 0;
}

void DocumentPage::setColorVariables(bool color)
{
  m_highlighter->setColorVariables(color);
}

void DocumentPage::setOpcodeNameList(QStringList list)
{
  m_highlighter->setOpcodeNameList(list);
}

QString DocumentPage::getFullText()
{
  QString fullText;
  fullText = document()->toPlainText();
//  if (!fullText.endsWith("\n"))
//    fullText += "\n";
  if (fileName.endsWith(".csd",Qt::CaseInsensitive) or fileName == "") {
    fullText += getMacOptionsText() + "\n" + macGUI + "\n" + macPresets + "\n";
    QString liveEventsText = "";
    if (saveLiveEvents) { // Only add live events sections if file is a csd file
      for (int i = 0; i < liveEventFrames.size(); i++) {
        QString panel = "<EventPanel name=\"";
        panel += liveEventFrames[i]->getName() + "\" tempo=\"";
        panel += QString::number(liveEventFrames[i]->getTempo(), 'f', 8) + "\" loop=\"";
        panel += QString::number(liveEventFrames[i]->getLoopLength(), 'f', 8) + "\" name=\"";
        panel += liveEventFrames[i]->getName() + "\" x=\"";
        panel += QString::number(liveEventFrames[i]->x()) + "\" y=\"";
        panel += QString::number(liveEventFrames[i]->y()) + "\" width=\"";
        panel += QString::number(liveEventFrames[i]->width()) + "\" height=\"";
        panel += QString::number(liveEventFrames[i]->height()) + "\">";
        panel += liveEventFrames[i]->getPlainText();
        panel += "</EventPanel>";
        liveEventsText += panel;
      }
      fullText += liveEventsText;
    }
  }
  return fullText;
}

// QString DocumentPage::getXmlWidgetsText()
// {
//   
// }

QString DocumentPage::getOptionsText()
{
  QString text = document()->toPlainText();
  int index = text.indexOf("<CsOptions>") + 11;
  int end = text.indexOf("</CsOptions>") - 1 ;
  if (index < 0 or end < 0)
    return QString();
  text = text.mid(index, end-index);
  return text;
}

QString DocumentPage::getDotText()
{
  if (fileName.endsWith("sco")) {
    qDebug() << "DocumentPage::getDotText(): No dot for sco files";
    return QString();
  }
  QString orcText = getFullText();
  if (!fileName.endsWith("orc")) { //asume csd
    if (orcText.contains("<CsInstruments>") && orcText.contains("</CsInstruments>")) {
      orcText = orcText.mid(orcText.indexOf("<CsInstruments>") + 15,
                            orcText.indexOf("</CsInstruments>") - orcText.indexOf("<CsInstruments>") - 15);
    }
  }
  DotGenerator dot(fileName, orcText, m_opcodeTree);
  return dot.getDotText();
}

// QString DocumentPage::connectedNodeText(QString nodeName, QString label, QString dest)
// {
//   QString nodeText = "    " + nodeName;
//   nodeText += "[label=\"" + label + "\" shape=none fontsize=8 splines=polyline]\n";
//   nodeText += "    "+ nodeName + "->" + dest + "[splines=polyline]\n";
//   return nodeText;
// }

// QString DocumentPage::dotTextForExpression(QString expression, QString &outNode)
// {
//   QString text = "";
// //   QString outNode = "";
//   QString node1 = "";
//   QString node2 = "";
//   while (expression.contains("(")) {
//     int parenIndex = expression.lastIndexOf("(");
//     int parenCloseIndex = expression.indexOf(")");
//     QString innerExpression = expression.mid(parenIndex,parenCloseIndex - parenIndex + 1 );
//     qDebug() << "Inner expression:" <<  innerExpression;
//     text += dotTextForExpression(innerExpression, outNode);
//     dotTextForExpression(QString expression, QString &outNode);
//   }
//   while (expression.contains(QRegExp("[\\*\\/\\+\\-]+"))) {
//   }
//   text = "  ExNd_" + expression + "_" + outNode + " [label = " + expression + "]\n";
//   text = "  ExNd_" + expression + "_" + outNode + " -> " outNode + "\n";
//   outNode = "ExNd_" + expression + "_" + outNode;
//   return text;
// }

QString DocumentPage::getMacWidgetsText()
{
  return macGUI;
}

QString DocumentPage::getMacOptionsText()
{
  return macOptions.join("\n");
}

QString DocumentPage::getMacOptions(QString option)
{
  if (!option.endsWith(":"))
    option += ":";
  if (!option.endsWith(" "))
    option += " ";
  int index = macOptions.indexOf(QRegExp(option + ".*"));
  if (index < 0) {
    qDebug("DocumentPage::getMacOptions() Option %s not found!", option.toStdString().c_str());
    return QString("");
  }
  return macOptions[index].mid(option.size());
}

QRect DocumentPage::getWidgetPanelGeometry()
{
  int index = macOptions.indexOf(QRegExp("WindowBounds: .*"));
  if (index < 0) {
//     qDebug ("DocumentPage::getWidgetPanelGeometry() no Geometry!");
    return QRect();
  }
  QString line = macOptions[index];
  QStringList values = line.split(" ");
  values.removeFirst();  //remove property name
  return QRect(values[0].toInt(),
               values[1].toInt(),
               values[2].toInt(),
               values[3].toInt());
}

void DocumentPage::getToIn()
{
  setPlainText(changeToInvalue(document()->toPlainText()));
  document()->setModified(true);
}

void DocumentPage::inToGet()
{
  setPlainText(changeToChnget(document()->toPlainText()));
  document()->setModified(true);
}

QString DocumentPage::changeToChnget(QString text)
{
  QStringList lines = text.split("\n");
  QString newText = "";
  foreach (QString line, lines) {
    if (line.contains("invalue")) {
      line.replace("invalue", "chnget");
    }
    else if (line.contains("outvalue")) {
      line.replace("outvalue", "chnset");
      int arg1Index = line.indexOf("chnset") + 7;
      int arg2Index = line.indexOf(",") + 1;
      int arg2EndIndex = line.indexOf(QRegExp("[\\s]*[;]"), arg2Index);
      QString arg1 = line.mid(arg1Index, arg2Index-arg1Index - 1).trimmed();
      QString arg2 = line.mid(arg2Index, arg2EndIndex-arg2Index).trimmed();
      QString comment = line.mid(arg2EndIndex);
      qDebug() << arg1 << arg2 << arg2EndIndex;
      line = line.mid(0, arg1Index) + " " +  arg2 + ", " + arg1;
      if (arg2EndIndex > 0)
        line += " " + comment;
    }
    newText += line + "\n";
  }
  return newText;
}

QString DocumentPage::changeToInvalue(QString text)
{
  QStringList lines = text.split("\n");
  QString newText = "";
  foreach (QString line, lines) {
    if (line.contains("chnget")) {
      line.replace("chnget", "invalue");
    }
    else if (line.contains("chnset")) {
      line.replace("chnset", "outvalue");
      int arg1Index = line.indexOf("outvalue") + 8;
      int arg2Index = line.indexOf(",") + 1;
      int arg2EndIndex = line.indexOf(QRegExp("[\\s]*[;]"), arg2Index);
      QString arg1 = line.mid(arg1Index, arg2Index-arg1Index - 1).trimmed();
      QString arg2 = line.mid(arg2Index, arg2EndIndex-arg2Index).trimmed();
      QString comment = line.mid(arg2EndIndex);
      qDebug() << arg1 << arg2 << arg2EndIndex;
      line = line.mid(0, arg1Index) + " " + arg2 + ", " + arg1;
      if (arg2EndIndex > 0)
        line += " " + comment;
    }
    newText += line + "\n";
  }
  return newText;
}

void DocumentPage::markErrorLines(QList<int> lines)
{
  QTextCharFormat errorFormat;
  errorFormat.setBackground(QBrush(QColor(255, 182, 193)));
  QTextCursor cur = textCursor();
  cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor);
  int lineCount = 1;
  foreach(int line, lines) {
    // Csound reports the line numbers incorrectly... but only on my machine apparently...
    while (lineCount < line) {
      lineCount++;
//       cur.movePosition(QTextCursor::NextCharacter, QTextCursor::MoveAnchor);
      cur.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor);
    }
    cur.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
    cur.mergeCharFormat(errorFormat);
    setTextCursor(cur);
    cur.movePosition(QTextCursor::StartOfBlock, QTextCursor::MoveAnchor);
  }
  setTextCursor(cur);
  errorMarked = true;
}

void DocumentPage::unmarkErrorLines()
{
  if (!errorMarked)
    return;
  int position = verticalScrollBar()->value();
  QTextCursor currentCursor = textCursor();
  errorMarked = false;
//   qDebug("DocumentPage::unmarkErrorLines()");
  selectAll();
  QTextCursor cur = textCursor();
  QTextCharFormat format = cur.blockCharFormat();
  format.clearBackground();
  cur.setCharFormat(format);
  setTextCursor(cur);  //sets format
  setTextCursor(currentCursor); //returns cursor to initial position
  verticalScrollBar()->setValue(position); //return document display to initial position
}

void DocumentPage::updateCsladspaText(QString text)
{
  QTextCursor cursor = textCursor();
  QTextDocument *doc = document();
  moveCursor(QTextCursor::Start);
  if (find("<csLADSPA>") and find("</csLADSPA>")) {
    QString curText = doc->toPlainText();
    int index = curText.indexOf("<csLADSPA>");
    curText.remove(index, curText.indexOf("</csLADSPA>") + 11 - index);
    curText.insert(index, text);
    doc->setPlainText(curText);
  }
  else { //csLADSPA section not present, or incomplete
    find("<CsoundSynthesizer>"); //cursor moves there
    moveCursor(QTextCursor::EndOfLine);
    insertPlainText(QString("\n") + text + QString("\n"));
  }
  moveCursor(QTextCursor::Start);
}

QString DocumentPage::getFilePath()
{
  return fileName.left(fileName.lastIndexOf("/"));
}

int DocumentPage::currentLine()
{
  QTextCursor cursor = textCursor();
//   cursor.clearSelection();
//   cursor.setPosition(0,QTextCursor::KeepAnchor);
//   QString section = cursor.selectedText();
//   qDebug() << section;
//   return section.count('\n');
  return cursor.blockNumber() + 1;
}

void DocumentPage::showLiveEventFrames(bool visible)
{
  qDebug() << "DocumentPage::showLiveEventFrames  " << visible << (int) this;
  for (int i = 0; i < liveEventFrames.size(); i++) {
    if (visible) {
      liveEventFrames[i]->show();
    }
    else {
      liveEventFrames[i]->hide();
    }
  }
}

void DocumentPage::setMacWidgetsText(QString widgetText)
{
//   qDebug() << "DocumentPage::setMacWidgetsText: ";
  macGUI = widgetText;
//   document()->setModified(true);
}

void DocumentPage::setMacOptionsText(QString text)
{
  macOptions = text.split('\n');
}

void DocumentPage::setMacOption(QString option, QString newValue)
{
  if (!option.endsWith(":"))
    option += ":";
  if (!option.endsWith(" "))
    option += " ";
  int index = macOptions.indexOf(QRegExp(option + ".*"));
  if (index < 0) {
    qDebug("DocumentPage::setMacOption() Option not found!");
    return;
  }
  macOptions[index] = option + newValue;
  qDebug("DocumentPage::setMacOption() %s", macOptions[index].toStdString().c_str());
}

void DocumentPage::setWidgetPanelPosition(QPoint position)
{
  int index = macOptions.indexOf(QRegExp("WindowBounds: .*"));
  if (index < 0) {
    qDebug ("DocumentPage::getWidgetPanelGeometry() no Geometry!");
    return;
  }
  QStringList parts = macOptions[index].split(" ");
  parts.removeFirst();
  QString newline = "WindowBounds: " + QString::number(position.x()) + " ";
  newline += QString::number(position.y()) + " ";
  newline += parts[2] + " " + parts[3];
  macOptions[index] = newline;
//   qDebug("DocumentPage::setWidgetPanelPosition() %i %i", position.x(), position.y());
}

void DocumentPage::setWidgetPanelSize(QSize size)
{
  int index = macOptions.indexOf(QRegExp("WindowBounds: .*"));
  if (index < 0) {
    qDebug ("DocumentPage::getWidgetPanelGeometry() no Geometry!");
    return;
  }
  QStringList parts = macOptions[index].split(" ");
  parts.removeFirst();
  QString newline = "WindowBounds: ";
  newline += parts[0] + " " + parts[1] + " ";
  newline += QString::number(size.width()) + " ";
  newline += QString::number(size.height());
  macOptions[index] = newline;
//   qDebug("DocumentPage::setWidgetPanelSize() %i %i", size.width(), size.height());
}

void DocumentPage::jumpToLine(int line)
{
  int lineCount = 1;
  QTextCursor cur = textCursor();
  cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor);
  while (lineCount < line) {
    lineCount++;
    //       cur.movePosition(QTextCursor::NextCharacter, QTextCursor::MoveAnchor);
    cur.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor);
  }
  moveCursor(QTextCursor::End); // go to end to make sure line is put at the top of text
  setTextCursor(cur);
}

void DocumentPage::comment()
{
  QTextCursor cursor = textCursor();
  if (cursor.position() > cursor.anchor()) {
    int temp = cursor.anchor();
    cursor.setPosition(cursor.position());
    cursor.setPosition(temp, QTextCursor::KeepAnchor);
  }
  if (!cursor.atBlockStart()) {
    cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
  }
  QString text = cursor.selectedText();
  text.prepend(";");
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n;"));
  cursor.insertText(text);
  setTextCursor(cursor);
}

void DocumentPage::uncomment()
{
  QTextCursor cursor = textCursor();
  if (cursor.position() > cursor.anchor()) {
    int temp = cursor.anchor();
    cursor.setPosition(cursor.position());
    cursor.setPosition(temp, QTextCursor::KeepAnchor);
  }
  QString text = cursor.selectedText();
  if (!cursor.atBlockStart() && !text.startsWith(";")) {
    cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
    text = cursor.selectedText();
  }
  if (text.startsWith(";"))
    text.remove(0,1);
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n"));
  text.replace(QString("\n;"), QString("\n")); //TODO make more robust
  cursor.insertText(text);
  setTextCursor(cursor);
}

void DocumentPage::indent()
{
//   qDebug("DocumentPage::indent");
  QTextCursor cursor = textCursor();
  if (cursor.position() > cursor.anchor()) {
    int temp = cursor.anchor();
    cursor.setPosition(cursor.position());
    cursor.setPosition(temp, QTextCursor::KeepAnchor);
  }
  if (!cursor.atBlockStart()) {
    cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
  }
  QString text = cursor.selectedText();
//   if (text[0] == '\n')
  text.prepend("\t"); //TODO check if previous character is \n
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n\t"));
  cursor.insertText(text);
  setTextCursor(cursor);
}

void DocumentPage::unindent()
{
  QTextCursor cursor = textCursor();
  if (cursor.position() > cursor.anchor()) {
    int temp = cursor.anchor();
    cursor.setPosition(cursor.position());
    cursor.setPosition(temp, QTextCursor::KeepAnchor);
  }
  if (!cursor.atBlockStart()) {
    cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
  }
  QString text = cursor.selectedText();
  if (text.startsWith("\t"))
    text.remove(0,1);
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n"));
  text.replace(QString("\n\t"), QString("\n")); //TODO make more robust
  cursor.insertText(text);
  setTextCursor(cursor);
}

void DocumentPage::opcodeFromMenu()
{
  QAction *action = (QAction *) QObject::sender();
  QTextCursor cursor = textCursor();
  QString text = action->data().toString();
  cursor.insertText(text);
}

LiveEventFrame * DocumentPage::newLiveEventFrame(QString text)
{
  qDebug() << "DocumentPage::newLiveEventFrame()";
  // TODO delete these frames, for proper cleanup
  // TODO remove from QVector when they are deleted individually
  LiveEventFrame *e = new LiveEventFrame("Live Event", this, Qt::Window);
  e->setAttribute(Qt::WA_DeleteOnClose, false);
//  e->show();

  if (!text.isEmpty()) {
    e->setFromText(text);
  }
  liveEventFrames.append(e);
  connect(e, SIGNAL(closed()), this, SLOT(liveEventFrameClosed()));
  connect(e, SIGNAL(newFrameSignal(QString)), this, SLOT(newLiveEventFrame(QString)));
  connect(e, SIGNAL(deleteFrameSignal(LiveEventFrame *)), this, SLOT(deleteLiveEventFrame(LiveEventFrame *)));
  emit registerLiveEvent(dynamic_cast<QWidget *>(e));
  return e;
}

void DocumentPage::deleteLiveEventFrame(LiveEventFrame *frame)
{
  qDebug() << "deleteLiveEventFrame(LiveEventFrame *frame)";
  qApp->processEvents();
  int index = liveEventFrames.indexOf(frame);
  if (index >= 0) {
    frame->forceDestroy();
    liveEventFrames.remove(index);
  }
  else {
    qDebug() << "DocumentPage::deleteLiveEventFrame frame not found";
  }
  qDebug() << "deleteLiveEventFrame(LiveEventFrame *frame) out";
}

void DocumentPage::changed()
{
  unmarkErrorLines();
  emit currentTextUpdated();
}

void DocumentPage::liveEventFrameClosed()
{
  qDebug() << "DocumentPage::liveEventFrameClosed()";
//  LiveEventFrame *e = dynamic_cast<LiveEventFrame *>(QObject::sender());
//  if (e != 0) { // This shouldn't really be necessary but just in case
  bool shown = false;
  for (int i = 0; i < liveEventFrames.size(); i++) {
    if (liveEventFrames[i]->isVisible())
      shown = true;
  }
  emit liveEventsVisible(shown);
//  }
}

// void DocumentPage::moved()
// {
//   qDebug() << "DocumentPage::moved()" << currentLine();
//   emit(currentLineChanged(currentLine()));
// }
