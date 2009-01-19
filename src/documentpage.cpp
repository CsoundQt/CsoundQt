/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera                                  *
 *   mantaraya36@gmail.com                                                 *
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
#include "qutecsound.h"
#include "opentryparser.h"
#include "types.h"
#include "node.h"

DocumentPage::DocumentPage(QWidget *parent, OpEntryParser *opcodeTree):
    QTextEdit(parent), m_opcodeTree(opcodeTree)
{
  fileName = "";
  companionFile = "";
  askForFile = true;
  readOnly = false;
}

DocumentPage::~DocumentPage()
{
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

int DocumentPage::setTextString(QString text)
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
//     qDebug("<MacOptions> present. %s", getMacOption("WindowBounds").toStdString().c_str());
  }
  else {
    QString defaultMacOptions = "<MacOptions>\nVersion: 3\nRender: Real\nAsk: Yes\nFunctions: ioObject\nListing: Window\nWindowBounds: 72 179 400 200\nCurrentView: io\nIOViewEdit: On\nOptions: -b128 -A -s -m167 -R\n</MacOptions>\n";
    setMacOptionsText(defaultMacOptions);
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
    qDebug("<MacGUI> present.");
  }
  else {
    macGUI = "\n<MacGUI>\nioView nobackground {59352, 11885, 65535}\nioSlider {5, 5} {20, 100} 0.000000 1.000000 0.000000 slider1\nioSlider {45, 5} {20, 100} 0.000000 1.000000 0.000000 slider2\nioSlider {85, 5} {20, 100} 0.000000 1.000000 0.000000 slider3\nioSlider {125, 5} {20, 100} 0.000000 1.000000 0.000000 slider4\nioSlider {165, 5} {20, 100} 0.000000 1.000000 0.000000 slider5\n</MacGUI>\n";
  }
  setPlainText(text);
  document()->setModified(true);
  return 0;
}

QString DocumentPage::getFullText()
{
  QString fullText;
  fullText = document()->toPlainText();
  if (!fullText.endsWith("\n"))
    fullText += "\n";
  if (fileName.endsWith(".csd"))
    fullText += getMacOptionsText() + "\n" + macGUI + "\n" + macPresets + "\n";
  return fullText;
}

QString DocumentPage::getDotText()
{
  QString dotText = "digraph csd {\n    fontsize=18\n    label=\"" + fileName + "\"\n";
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
  QStringList instruments;
  while (orcText.contains(QRegExp("\\b*instr"))) {
    int index = orcText.indexOf(QRegExp("\\b*instr"));
    int end = orcText.indexOf("endin", index) + 6 ;
    QString instrument = orcText.mid(index, end - index);
    instruments.append(instrument);
    orcText.remove(instrument);
  }
  QVector<QVector <Node> > instrumentGraphs;
  QVector<QString> instrumentNames;
  foreach (QString instrument, instruments) {
    QVector <Node> instrumentGraph;
    QStringList lines = instrument.split("\n", QString::SkipEmptyParts);
    foreach (QString line, lines) {
      if (line.contains("instr")) {
        instrumentNames.append(line.remove("instr").trimmed());
      }
      else if (line.contains("endin")) {
      }
      else {
        QStringList parts = line.split(QRegExp("\\s+"), QString::SkipEmptyParts);
        if (parts.size() > 0) {
          if (parts[0].startsWith(";")) {
            //TODO handle comments
          }
          else {
            Node node;
            for (int i = 0; i < parts.size(); i++){
              QString inArgs = "";
              QString opcodeName = "";
              QString outArgs = "";
              // determine if part is an opcode
              if (m_opcodeTree->isOpcode(parts[i])) {
                opcodeName = parts[i];
                for (int j = 0; j < i; j++) {
                  outArgs += parts[j];
                }
                for (int j = i + 1; j < parts.size(); j++) {
                  inArgs += parts[j];
                }
                node.setName(opcodeName);
                int commentIndex = inArgs.indexOf(";");
                if (commentIndex > 0)
                  inArgs.resize(commentIndex);
                QStringList args = inArgs.split(QRegExp("[\\s,]+"), QString::SkipEmptyParts);
                bool string = false;
                QString stringArg = "";
                foreach (QString arg, args) {
                  if (arg.startsWith("\"") || string) {
                    string = true;
                    stringArg += arg + " ";
                  }
                  if (arg.endsWith("\"")) {
                    string = false;
                    stringArg.chop(1); //remove last space
                    arg =  stringArg;
                    stringArg = "";
                  }
                  if (!string) {
                    Port port;
                    port.name = arg;
                    port.connected = false;
                    node.newInput(port);
                  }
                }
                args = outArgs.split(QRegExp("[\\s,]+"), QString::SkipEmptyParts);
                foreach (QString arg, args) {
//                   qDebug() << "outArg:" << arg;
                  Port port;
                  // TODO dive into expressions
                  port.name = arg;
                  port.connected = false;
                  node.newOutput(port);
                }
                break;
              }
            }
            m_opcodeTree->getOpcodeArgNames(node);
            instrumentGraph.append(node);
          }
        }
      }
    }
    instrumentGraphs.append(instrumentGraph);
  }
  QHash<QString, QString> tokenSource;
  for (int i = 0; i < instrumentGraphs.size(); i++) {
    dotText += "subgraph cluster_" + QString::number(i) + " {\n    color=black\n fontsize=18\n";
    dotText += "label=\"instr " + instrumentNames[i]  + "\"\n";
    for (int j = 0; j < instrumentGraphs[i].size(); j++) {
      QVector<Port> inputs = instrumentGraphs[i][j].getInputs();
      QVector<Port> outputs = instrumentGraphs[i][j].getOutputs();
      dotText += "   Node" + QString::number(i) + "_" + QString::number(j) + "[label =\"{";
      if (inputs.size() > 0 && instrumentGraphs[i][j].getName() != "=") {
        dotText += "{";
          for (int x = 0; x < inputs.size(); x++) {
            QString name = inputs[x].argName;
            if (name != "\\") { //hack for multiline opcode lines, this should be taken care of earier....
              name.replace("\"", "\\\"");
              dotText += "<i" + QString::number(x) + "> " + name + " |";
            }
          }
          dotText.chop(1); // remove last |
          dotText += "}|";
      }
      dotText += instrumentGraphs[i][j].getName();
      if (outputs.size() > 0 && instrumentGraphs[i][j].getName() != "=") {
        dotText += "|{";
        for (int x = 0; x < outputs.size(); x++) {
          QString name = outputs[x].argName;
          name.replace("\"", "\\\"");
          dotText += "<o" + QString::number(x) + "> " + name + "|";
        }
        dotText.chop(1); // remove last |
        dotText += "} ";
      }
      dotText += "}\" shape=Mrecord fontsize=11 fontname=\"Arial\" repulsiveforce=2 rank=sink]\n  ";
      for (int n = 0; n < inputs.size(); n++) {
        if (tokenSource.value(inputs[n].name) != "") {
//           qDebug() << "token Found" << tokenSource[inputs[n].name];
          dotText += "    " + tokenSource[inputs[n].name];
          dotText += "->Node" + QString::number(i) + "_" + QString::number(j) + ":i";
          dotText += QString::number(n) + " [label=\"" + inputs[n].name + "\" fontsize=8]\n";
          instrumentGraphs[i][j].setInputPortConnected(true, n);
        }
        else /*if (!instrumentGraphs[i][j].inputPortConnected(n))*/ {// no available source
//           qDebug() << tokenSource.keys();
          QString name = inputs[n].name;
          QString label = inputs[n].name;
          label.replace("\"", "\\\"");
          QString nodeName = "ArgNode" + QString::number(i) + "_" + QString::number(j) + "_" + QString::number(n);
          dotText += "    " + nodeName + " [label =\"" + label + "\" shape=box fontname=\"Arial\"  fontsize=10]\n";
          QList<QString> keys = tokenSource.keys();
//           qDebug() << keys;
          QStringList expTokens = label.split(QRegExp("[\\+\\-\\*\\/\\^\\)\\(\\%\\!]+"), QString::SkipEmptyParts);
          if (expTokens.size() > 1 && !label.contains("\"")) { //means it is an expression
            dotText += "    " + nodeName + "->";
            dotText += "   Node" + QString::number(i) + "_" + QString::number(j);
            dotText += " [fontsize=10]\n";
          }
          bool connected = false;
          foreach (QString key, keys) {
            foreach (QString token, expTokens) {
              token.remove(QRegExp("\\s+"));
              if (token == key) {
                if (key != "") {
//                   qDebug() << "expTokens match" << token;
                  dotText += "    " + tokenSource[token] + "->" + nodeName;
  //                 dotText += "->Node" + QString::number(i) + "_" + QString::number(j) + ":i";
                  dotText += " [label=\"" + token + "\" fontsize=8 ]\n";
                  connected = true;
                  break;
                }
              }
            }
          }
          if (connected == false) {
//             qDebug() << "Connect argument without origin";
            dotText += "    " + nodeName;
            dotText += "->Node" + QString::number(i) + "_" + QString::number(j) + ":i" + QString::number(n) + "\n";
          }
        }
      }
      for (int w = 0; w < outputs.size(); w++) {
        if (outputs[w].name.startsWith("i") || outputs[w].name.startsWith("k")
            || outputs[w].name.startsWith("a") || outputs[w].name.startsWith("f")
            || outputs[w].name.startsWith("w") || outputs[w].name.startsWith("g")) {
          tokenSource[outputs[w].name] = "Node" + QString::number(i) + "_" + QString::number(j) + ":o" + QString::number(w);
//           qDebug() << "tokenSource" << outputs[w].name << "--" << tokenSource[outputs[w].name];
        }
      }
    }
    dotText += "}\n"; //close subgraph
  }
  dotText += "}\n"; //close main graph
  return dotText;
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

QString DocumentPage::getMacOption(QString option)
{
  if (!option.endsWith(":"))
    option += ":";
  if (!option.endsWith(" "))
    option += " ";
  int index = macOptions.indexOf(QRegExp(option + ".*"));
  if (index < 0) {
    qDebug("DocumentPage::getMacOption() Option %s not found!", option.toStdString().c_str());
    return QString("");
  }
  return macOptions[index].mid(option.size());
}

QRect DocumentPage::getWidgetPanelGeometry()
{
  int index = macOptions.indexOf(QRegExp("WindowBounds: .*"));
  if (index < 0) {
    qDebug ("DocumentPage::getWidgetPanelGeometry() no Geometry!");
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

void DocumentPage::setMacWidgetsText(QString text)
{
//   qDebug("DocumentPage::setMacWidgetsText");
  macGUI = text;
  document()->setModified(true);
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

void DocumentPage::comment()
{
  QTextCursor cursor = textCursor();
  QString text = cursor.selectedText();
  text.prepend(";");
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n;"));
  cursor.insertText(text);
  setTextCursor(cursor);
}

void DocumentPage::uncomment()
{
  QTextCursor cursor = textCursor();
  QString text = cursor.selectedText();
  if (text.startsWith(";"))
    text.remove(0,1);
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n"));
  text.replace(QString("\n;"), QString("\n")); //TODO make more robust
  cursor.insertText(text);
  setTextCursor(cursor);
}

void DocumentPage::indent()
{
  qDebug("DocumentPage::indent");
  QTextCursor cursor = textCursor();
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
