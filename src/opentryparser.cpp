/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
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
#include "algorithm"

#include <QFile>

void OpEntryParser::parseOpcodesXml(QString opcodeFile) {
    QDomDocument m_doc("opcodes");
    QFile file(opcodeFile);
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
                    op.inArgs = node.nextSibling().toText().data().simplified();
                }
                else {
                    op.outArgs = node.toText().data().simplified();
                    node = node.nextSibling();
                    op.opcodeName = node.toElement().text().simplified();
                    node = node.nextSibling();
                    if (!node.isNull())
                        op.inArgs = node.toText().data().simplified();
                }
                // check if several parenthesis ie description added to inArgs like "(MidiNoteNumber)  (init- or control-rate args only)"
                // remove, if existing
                if (op.inArgs.count("(")>1) {
                    QString inArgs = op.inArgs;
                    int lastIndex = inArgs.lastIndexOf("(");
                    if (lastIndex>0) {
                        inArgs = inArgs.left(lastIndex-1);
                        op.inArgs = inArgs;
                    }
                }
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
        opcodeCategoryList.append(newCategory);
        cat = cat.nextSiblingElement("category");
    }
}

OpEntryParser::OpEntryParser(QString opcodeFile)
	: m_opcodeFile(opcodeFile)
{
    m_udosMap = nullptr;
    parseOpcodesXml(opcodeFile);
	addExtraOpcodes();
}

OpEntryParser::~OpEntryParser()
{
}

void OpEntryParser::addExtraOpcodes()
{
    addOpcode(Opcode("then"));

    addFlag("use-system-sr", "Use the samplerate defined by the realtime audio backend");
    addFlag("omacro", "--omacro:XXX=YYY set orchestra macro XXX to value YYY");
    addFlag("port", "--port=N. listen to UDP port N for instruments/orchestra code");

}

void OpEntryParser::sortOpcodes()
{
    std::sort(opcodeList.begin(), opcodeList.end(),
              [](const Opcode &a, const Opcode &b) -> bool { return a.opcodeName < b.opcodeName; });
}

QStringList OpEntryParser::opcodeNameList()
{
	QStringList list;
    for (int i = 0; i<opcodeList.size();i++)  {
		list.append(opcodeList[i].opcodeName);
	}
	return list;
}

void OpEntryParser::addOpcode(Opcode opcode)
{
    opcodeList.append(opcode);
}

void OpEntryParser::addFlag(QString flag, QString desc) {
    Opcode opcode(flag);
    opcode.desc = desc;
    opcode.isFlag = 1;
    opcodeList.append(opcode);
}

Opcode OpEntryParser::findOpcode(QString opcodeName) {
    for (int i = 0; i < opcodeList.size(); i++) {
        if (opcodeList[i].opcodeName == opcodeName) {
            return opcodeList[i];
        }
    }
    if(m_udosMap->contains(opcodeName)) {
        return m_udosMap->value(opcodeName);
    }
    qDebug() << "OpEntryParser::findOpcode: opcode " << opcodeName << "not found";
    return Opcode("");
}

QString opcodeSyntax(Opcode opc) {
    QString syntax = opc.outArgs.simplified();
    if (!opc.outArgs.isEmpty())
        syntax += " ";
    syntax += opc.opcodeName.simplified();
    if (!opc.inArgs.isEmpty()) {
        syntax += " " + opc.inArgs.simplified();
    }
    if(!opc.desc.isEmpty()) {
        syntax += "<br />[ " + opc.desc + " ]";
    }
    return syntax;
}

QString OpEntryParser::getSyntax(QString opcodeName)
{
    if (opcodeName.size() < 2) {
        return "";
	}
    Opcode opc = findOpcode(opcodeName);
    if(!opc.opcodeName.isEmpty()) {
        QString syntax = opcodeSyntax(opc);
        return syntax;
    }
    return "";
}

QVector<Opcode> OpEntryParser::getPossibleSyntax(QString word)
{
    QVector<Opcode> out;
	for (int i = 0; i < opcodeList.size(); i++) {
		if (opcodeList[i].opcodeName.startsWith(word)) {
			out << opcodeList[i];
		}
	}
    auto it = m_udosMap->constBegin();
    while(it != m_udosMap->constEnd()) {
        if(it->opcodeName.startsWith(word))
            out << it.value();
        it++;
    }
    return out;
}

QList< QPair<QString, QList<Opcode> > > OpEntryParser::getOpcodesByCategory()
{
	return opcodeCategoryList;
}

int OpEntryParser::getCategoryCount()
{
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
    for (int i = 0; i< opcodeList.size();i++)  {
		if (opcodeName == opcodeList[i].opcodeName) {
            return true;
        }
	}
    if(this->m_udosMap->contains(opcodeName))
        return true;
    return false;
}


bool OpEntryParser::getOpcodeArgNames(Node &node)
{
    QString opcodeName = node.getName();
	QVector<Port> inputs = node.getInputs();
	QVector<Port> outputs = node.getOutputs();
    int idx = -1;
    for (int i = 0; i< opcodeList.size();i++)  {
        if (opcodeName == opcodeList[i].opcodeName) {
            idx = i;
            break;
        }
    }
    Opcode opcode;
    if(idx >= 0) {
        opcode = opcodeList[idx];
    } else {
        if(m_udosMap->contains(opcodeName))
            opcode = m_udosMap->value(opcodeName);
        else
            return false;
    }
    QString inArgs = opcode.inArgs;
    QString inArgsOpt = "";
    if (inArgs.contains("["))
        inArgsOpt = inArgs.mid(inArgs.indexOf("["));
    inArgs.remove(inArgsOpt);
    QStringList args = inArgs.split(QRegExp("[,\\\"]+"), Qt::SkipEmptyParts);
    for (int count = 0; count < args.size(); count ++) {
        args[count] = args[count].trimmed();
        if (args[count] == "")
            args.removeAt(count);
    }
    QStringList argsOpt = inArgsOpt.split(QRegExp("[,\\\\\\s\\[\\]]+"), Qt::SkipEmptyParts);
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
            }
            else {
                qDebug("OpEntryParser::getOpcodeArgNames: Error too many inargs");
            }
        }
    }
    QString outArgs = opcode.outArgs;
    QString outArgsOpt = "";
    if (outArgs.contains("["))
        outArgsOpt = outArgs.mid(outArgs.indexOf("["));
    outArgs.remove(outArgsOpt);
    args = outArgs.split(QRegExp("[,\\s]+"), Qt::SkipEmptyParts);
    argsOpt = outArgsOpt.split(QRegExp("[,\\\\\\s\\[\\]]"), Qt::SkipEmptyParts);
    for (int j = 0; j < outputs.size(); j++) {
        if (j < args.size()) {
            outputs[j].argName = args[j];
            outputs[j].optional = false;
        }
        else {
            //optional parameter
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
    return true;
}
