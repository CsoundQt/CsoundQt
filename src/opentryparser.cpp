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

    QDomDocument m_doc("opcodes");
  QFile file(m_opcodeFile);
  if (!file.open(QIODevice::ReadOnly)) {
    qDebug() << "OpEntryParser::OpEntryParser could not find opcode file:" << opcodeFile;
    return;
  }
  if (!m_doc.setContent(&file)) {
    qDebug() << "OpEntryParser::OpEntryParser set content";
    file.close();
    return;
  }
  file.close();
  excludedOpcodes << "|" << "||" << "^" << "+" << "*" << "-" << "/";
//      << "instr" << "endin" << "opcode" << "endop"
//      << "sr" << "kr" << "ksmps" << "nchnls" << "0dbfs";
  QDomElement docElem = m_doc.documentElement();
  QList<Opcode> opcodesInCategoryList;

  QDomElement cat = docElem.firstChildElement("category");
  while(!cat.isNull()) {
    QString catName = cat.attribute("name", "Miscellaneous");
    opcodesInCategoryList.clear();
    QDomElement opcode = cat.firstChildElement("opcode");
    while(!opcode.isNull()) {
      QDomElement desc = opcode.firstChildElement("desc");
      QString description = desc.text();
      QDomElement synop = opcode.firstChildElement("synopsis");
      while(!synop.isNull()) {
        Opcode op;
        op.desc = description;
        QDomElement s = synop.toElement();
        QDomNode node = s.firstChild();
        QDomElement elem = node.toElement();
        if (elem.tagName()=="opcodename") {
          op.opcodeName = elem.text().simplified();
          op.inArgs = node.nextSibling().toText().data();
        }
        else {
          op.outArgs = node.toText().data().simplified();
          node = node.nextSibling();
          op.opcodeName = node.toElement().text().simplified();
          node = node.nextSibling();
          if (!node.isNull())
            op.inArgs = node.toText().data().simplified();
        }
        //               qDebug() << "out =" << op.outArgs << " op=" << op.opcodeName << " in=" << op.inArgs << "---" << description;
        if (op.opcodeName != "" && excludedOpcodes.count(op.opcodeName) == 0
            && catName !="Utilities") {
          addOpcode(op);
          opcodesInCategoryList << op;
        }
        synop = synop.nextSiblingElement("synopsis");
      }
      opcode = opcode.nextSiblingElement("opcode");
    }
    QPair<QString, QList<Opcode> > newCategory(catName, opcodesInCategoryList);
    opcodeListCategory.append(opcodesInCategoryList);
    categoryList.append(catName);
    // 	qDebug() << "Category: " << categoryList.last();
    opcodeCategoryList.append(newCategory);
    cat = cat.nextSiblingElement("category");
  }
  addExtraOpcodes();
}

OpEntryParser::~OpEntryParser()
{
}

void OpEntryParser::addExtraOpcodes()
{
  Opcode opcode;
  opcode.outArgs = "";
  opcode.opcodeName = "then";
  opcode.inArgs ="";
  addOpcode(opcode);
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
  QString out = "";
  int size = opcodeList.size();
  while (i < size && !opcodeList[i].opcodeName.startsWith(opcodeName)) {
    i++;
  }
  if (i < size) {
    QString syntax = opcodeList[i].outArgs.simplified();
    if (!opcodeList[i].outArgs.isEmpty())
      syntax += " ";
    syntax += opcodeList[i].opcodeName.simplified();
    if (!opcodeList[i].inArgs.isEmpty()) {
      syntax += " " + opcodeList[i].inArgs.simplified();
    }
    out = syntax + "    [ " + opcodeList[i].desc + " ]";
  }
  return out;
}

QVector<Opcode> OpEntryParser::getPossibleSyntax(QString word)
{
  QVector<Opcode> out;
  for (int i = 0; i < opcodeList.size(); i++) {
    if (opcodeList[i].opcodeName.startsWith(word)) {
       out << opcodeList[i];
    }
  }
  return out;
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
