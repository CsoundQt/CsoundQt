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

#include "dotgenerator.h"
#include "opentryparser.h"
#include "node.h"

DotGenerator::DotGenerator(QString fileName, QString orcText, OpEntryParser *opcodeTree) :
    m_fileName(fileName), m_orcText(orcText), m_opcodeTree(opcodeTree)
{
}


DotGenerator::~DotGenerator()
{
}

QString DotGenerator::getDotText()
{
  QString dotText = "digraph csd {\n    fontsize=18\n    label=\"" + m_fileName + "\"\n";
  QStringList instruments;
  while (m_orcText.contains(QRegExp("\\b*instr"))) {
    int index = m_orcText.indexOf(QRegExp("\\b*instr"));
    int end = m_orcText.indexOf("endin", index) + 6 ;
    QString instrument = m_orcText.mid(index, end - index);
    instruments.append(instrument);
    m_orcText.remove(instrument);
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
      else if (line.contains("endin")) { // Do nothing
      }
      else {
        QStringList parts = line.split(QRegExp("\\s+"), QString::SkipEmptyParts);
//         qDebug() << parts << "----------";
        if (parts.size() > 0) {
          if (parts[0].startsWith(";")) {
            //TODO handle comments
          } //TODO handle if, gotos and labels
          else {
            instrumentGraph.append(createNode(parts));
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
      dotText += makeNodeText(i,j,instrumentGraphs[i][j].getName(),inputs ,outputs);

      for (int n = 0; n < inputs.size(); n++) {
        dotText += makeinputConnection(i, j, n, inputs[n], tokenSource);
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


Node DotGenerator::createNode(QStringList parts)
{
  Node node;
  QVector <Node> instrumentGraph;
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
      QString comment = "";
      if (commentIndex > 0) {
        comment = inArgs.mid(commentIndex);
      }
      inArgs.remove(comment);
      QStringList args = inArgs.split(QRegExp("[,\\s]+"), QString::SkipEmptyParts);
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
  return node;
}

QString DotGenerator::makeNodeText(const int i,
                                   const int j,
                                   const QString name,
                                   QVector<Port> &inputs,
                                   QVector<Port> &outputs)
{
  QString nodeText = "   Node" + QString::number(i) + "_" + QString::number(j) + "[label =\"{";
  if (inputs.size() > 0 && name != "=") {
    nodeText += "{";
    for (int x = 0; x < inputs.size(); x++) {
      QString name = inputs[x].argName;
      if (name != "\\") { //hack for multiline opcode lines, this should be taken care of earier....
        name.replace("\"", "\\\"");
        nodeText += "<i" + QString::number(x) + "> " + name + " |";
      }
    }
    nodeText.chop(1); // remove last |
    nodeText += "}|";
  }
  nodeText += name;
  if (outputs.size() > 0 && name != "=") {
    nodeText += "|{";
    for (int x = 0; x < outputs.size(); x++) {
      QString name = outputs[x].argName;
      name.replace("\"", "\\\"");
      nodeText += "<o" + QString::number(x) + "> " + name + "|";
    }
    nodeText.chop(1); // remove last |
    nodeText += "} ";
  }
  nodeText += "}\" shape=Mrecord fontsize=11 fontname=\"Arial\" repulsiveforce=2 rank=sink]\n  ";
  return nodeText;
}


QString DotGenerator::makeinputConnection(int i, int j, int n, Port input, QHash<QString, QString> &tokenSource)
{
  QString text = "";
  if (tokenSource.value(input.name) != "") {
//           qDebug() << "token Found" << tokenSource[input.name];
    text += "    " + tokenSource[input.name];
    text += "->Node" + QString::number(i) + "_" + QString::number(j) + ":i";
    text += QString::number(n) + " [label=\"" + input.name + "\" fontsize=8]\n";
//     instrumentGraphs[i][j].setInputPortConnected(true, n);
  }
  else /*if (!instrumentGraphs[i][j].inputPortConnected(n))*/ {// no available source
//           qDebug() << tokenSource.keys();
    QString name = input.name;
    QString label = input.name;
    label.replace("\"", "\\\"");
    QString nodeName = "ArgNode" + QString::number(i) + "_" + QString::number(j) + "_" + QString::number(n);
    text += "    " + nodeName + " [label =\"" + label + "\" shape=box fontname=\"Arial\"  fontsize=10]\n";
    QList<QString> keys = tokenSource.keys();
//           qDebug() << keys;
    QStringList expTokens = label.split(QRegExp("[\\+\\-\\*\\/\\^\\)\\(\\%\\!]+"), QString::SkipEmptyParts);
    if (expTokens.size() > 1 && !label.contains("\"")) { //means it is an expression
      text += "    " + nodeName + "->";
      text += "   Node" + QString::number(i) + "_" + QString::number(j);
      text += " [fontsize=10]\n";
    }
    bool connected = false;
    foreach (QString key, keys) {
      foreach (QString token, expTokens) {
        token.remove(QRegExp("\\s+"));
        if (token == key) {
          if (key != "") {
//                   qDebug() << "expTokens match" << token;
            text += "    " + tokenSource[token] + "->" + nodeName;
  //                 text += "->Node" + QString::number(i) + "_" + QString::number(j) + ":i";
            text += " [label=\"" + token + "\" fontsize=8 ]\n";
            connected = true;
            break;
          }
        }
      }
    }
    if (connected == false) {
//             qDebug() << "Connect argument without origin";
      text += "    " + nodeName;
      text += "->Node" + QString::number(i) + "_" + QString::number(j) + ":i" + QString::number(n) + "\n";
    }
  }
  return text;
}