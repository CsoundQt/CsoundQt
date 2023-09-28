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

#ifndef OPENTRYPARSER_H
#define OPENTRYPARSER_H

#include <QString>
#include <QStringList>
#include <QtXml>
#include "node.h"
#include "types.h" // For Opcode class

class OpEntryParser
{
public:
	OpEntryParser(QString opcodeFile);

	~OpEntryParser();

    void parseOpcodesXml(QString opcodeFile);
    void sortOpcodes();
	void addExtraOpcodes();
    QStringList opcodeNameList(bool includeDisabled=false);
	QString getSyntax(QString opcodeName);
	QVector<Opcode> getPossibleSyntax(QString word);
	QList< QPair<QString, QList<Opcode> > > getOpcodesByCategory();
	int getCategoryCount();
	QString getCategory(int index);
	QStringList getCategoryList();
	QList<Opcode> getOpcodeList(int index);
	bool isOpcode(QString opcodeName);
	bool getOpcodeArgNames(Node &node);
    void setUdos(QHash<QString, Opcode>*udosMap) { m_udosMap = udosMap; }
    Opcode findOpcode(QString opcodeName);
    bool isKnownOpcode(QString name);
    QList<Opcode> opcodeList;

private:
	QString m_opcodeFile;
    QHash<QString, Opcode> opcodeMap;
	QList< QPair<QString, QList<Opcode> > > opcodeCategoryList;
	QVector<QList<Opcode> > opcodeListCategory;
	QStringList categoryList;
	QStringList excludedOpcodes;
    QStringList m_opcodeNameListCache;

	void addOpcode(Opcode opcode);
    void addFlag(QString flag, QString description);

    QHash<QString, Opcode>*m_udosMap;

};

#endif
