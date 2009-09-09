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

#include "opentryparser.h"
#include "types.h"

#include <QFile>


OpEntryParser::OpEntryParser(QString opcodeFile)
  : m_opcodeFile(opcodeFile)
{
  m_doc = new QDomDocument("opcodes");
  QFile file(m_opcodeFile);
  if (!file.open(QIODevice::ReadOnly))
    return;
  if (!m_doc->setContent(&file)) {
    file.close();
    return;
  }
  file.close();
  excludedOpcodes << "|" << "||" << "^" << "+" << "*" << "-" << "/";
//      << "instr" << "endin" << "opcode" << "endop"
//      << "sr" << "kr" << "ksmps" << "nchnls" << "0dbfs";
  QDomElement docElem = m_doc->documentElement();
  QList<Opcode> opcodesInCategoryList;

  QDomNode n = docElem.firstChild();
  while(!n.isNull()) {
    QString catName;
    opcodesInCategoryList.clear();
    QDomElement e = n.toElement();
    if(!e.isNull()) {
//       qDebug() << e.attribute("name", "Miscellaneous");
      catName = e.attribute("name", "Miscellaneous");
    }
    QDomNode synop = e.firstChild();
    while(!synop.isNull()) {
      Opcode opcode;
      QDomElement op = synop.toElement();
      QDomNode node = op.firstChild();
      QDomElement elem = node.toElement();
      if (elem.tagName()=="opcodename") {
        opcode.opcodeName = elem.text().trimmed();
        opcode.inArgs = node.nextSibling().toText().data();
      }
      else {
        opcode.outArgs = node.toText().data();
        node = node.nextSibling();
        opcode.opcodeName = node.toElement().text();
        node = node.nextSibling();
        if (!node.isNull())
          opcode.inArgs = node.toText().data();
      }
//       qDebug() << "out =" << opcode.outArgs << " op=" << opcode.opcodeName << " in=" << opcode.inArgs;
      if (opcode.opcodeName != "" and excludedOpcodes.count(opcode.opcodeName)==0
          and catName !="Utilities") {
        addOpcode(opcode);
        opcodesInCategoryList << opcode;
      }
      synop = synop.nextSibling();
    }
    QPair<QString, QList<Opcode> > newCategory(catName, opcodesInCategoryList);
    opcodeListCategory.append(opcodesInCategoryList);
    categoryList.append(catName);
// 	qDebug() << "Category: " << categoryList.last();
    opcodeCategoryList.append(newCategory);
    n = n.nextSibling();
  }
}


OpEntryParser::~OpEntryParser()
{
}


QStringList OpEntryParser::opcodeNameList()
{
  QStringList list;
//   qDebug("OpEntryParser::opcodeNameList() opcodeList.size() = %i",opcodeList.size());
  for (int i = 0; i<opcodeList.size();i++)  {
    list.append(opcodeList[i].opcodeName);
  }
  return list;
}

void OpEntryParser::addOpcode(Opcode opcode)
{
  int i = 0;
  int size = opcodeList.size();
  while (i<size && opcodeList[i].opcodeName < opcode.opcodeName)
    i++;
  opcodeList.insert(i, opcode);
}

QString OpEntryParser::getSyntax(QString opcodeName)
{
  int i = 0;
  int size = opcodeList.size();
  while (i < size && !opcodeList[i].opcodeName.startsWith(opcodeName)) {
    i++;
  }
  if (i < size) {
    QString syntax = opcodeList[i].outArgs + " " + opcodeList[i].opcodeName
        + " " + opcodeList[i].inArgs;
    return syntax;
  }
  else
    return QString("");
}

QList< QPair<QString, QList<Opcode> > > OpEntryParser::getOpcodesByCategory()
{
  return opcodeCategoryList;
}

int OpEntryParser::getCategoryCount()
{
// qDebug("OpEntryParser::getCategoryCount()");
  return categoryList.size();
}

QString OpEntryParser::getCategory(int index)
{
  if (index < categoryList.size()) 
    return categoryList[index];
  else return QString();
}

QStringList OpEntryParser::getCategoryList()
{
  return QStringList(categoryList);
}

QList<Opcode> OpEntryParser::getOpcodeList(int index)
{
  return opcodeListCategory[index];
}

bool OpEntryParser::isOpcode(QString opcodeName)
{
  bool isOpcode = false;
  for (int i = 0; i< opcodeList.size();i++)  {
    if (opcodeName == opcodeList[i].opcodeName) {
      isOpcode = true;
      break;
    }
  }
  return isOpcode;
}

bool OpEntryParser::getOpcodeArgNames(Node &node)
{
  bool isOpcode = false;
  QString opcodeName = node.getName();
  QVector<Port> inputs = node.getInputs();
  QVector<Port> outputs = node.getOutputs();
  for (int i = 0; i< opcodeList.size();i++)  {
    if (opcodeName == opcodeList[i].opcodeName) {
      isOpcode = true;
      QString inArgs = opcodeList[i].inArgs;
      QString inArgsOpt = "";
      if (inArgs.contains("["))
        inArgsOpt = inArgs.mid(inArgs.indexOf("["));
      inArgs.remove(inArgsOpt);
      QStringList args = inArgs.split(QRegExp("[,\\\"]+"), QString::SkipEmptyParts);
      for (int count = 0; count < args.size(); count ++) {
        args[count] = args[count].trimmed();
        qDebug() << args[count];
        if (args[count] == "")
          args.removeAt(count);
      }
      QStringList argsOpt = inArgsOpt.split(QRegExp("[,\\\\\\s\\[\\]]+"), QString::SkipEmptyParts);
      for (int j = 0; j < inputs.size(); j++) {
        if (j < args.size()) {
          inputs[j].argName = args[j];
          inputs[j].optional = false;
        }
        else { //optional parameter
          int index = j - args.size();
          if (index < inArgsOpt.size()) {
            if (index < argsOpt.size()) {
              // in case the opcode contains an undefined number of optional arguments
              inputs[j].argName = argsOpt[index];
            }
            else {
              inputs[j].argName = "";
            }
            inputs[j].optional = true;
//             qDebug() << "OpEntryParser::getOpcodeArgNames " <<  inputs[j].argName ;
          }
          else {
            qDebug("OpEntryParser::getOpcodeArgNames: Error too many inargs");
          }
        }
      }
      QString outArgs = opcodeList[i].outArgs;
      QString outArgsOpt = "";
      if (outArgs.contains("["))
        outArgsOpt = outArgs.mid(outArgs.indexOf("["));
      outArgs.remove(outArgsOpt);
      args = outArgs.split(QRegExp("[,\\s]+"), QString::SkipEmptyParts);
      argsOpt = outArgsOpt.split(QRegExp("[,\\\\\\s\\[\\]]"), QString::SkipEmptyParts);
      for (int j = 0; j < outputs.size(); j++) {
        if (j < args.size()) {
          outputs[j].argName = args[j];
          outputs[j].optional = false;
        }
        else { //optional parameter
          int index = j - args.size();
          if (index < inArgsOpt.size()) {
            if (index < argsOpt.size()) {
              // in case the opcode contains an undefined number of optional arguments
              outputs[j].argName = argsOpt[index];
            }
            else {
              outputs[j].argName = "";
            }
            outputs[j].optional = true;
          }
          else {
            qDebug("OpEntryParser::getOpcodeArgNames: Error too many outargs");
          }
        }
      }
      node.setInputs(inputs);
      node.setOutputs(outputs);
      break;
    }
  }
  return isOpcode;
}
