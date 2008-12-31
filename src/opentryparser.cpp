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
        opcode.opcodeName = elem.text();
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
