/*
	Copyright (C) 2009 Andres Cabrera
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

#include "widgetpreset.h"

WidgetPreset::WidgetPreset()
{
}

QString WidgetPreset::getXmlText()
{
	QString out = QString();
	out += "<preset name=\"" + m_name + "\" number=\""  + QString::number(m_number) + "\" >\n";
	for (int i = 0; i < m_data.size(); i++) {

		if (m_data[i].mode & 1) {
			out += "<value id=\"" + m_data[i].id + "\" mode=\"1\" >";
			out += QString::number(m_data[i].value, 'f', 8);
			out += "</value>\n";
		}
		if (m_data[i].mode & 2) {
			out += "<value id=\"" + m_data[i].id + "\" mode=\"2\" >";
			out += QString::number(m_data[i].value2, 'f', 8);
			out += "</value>\n";
		}
		if (m_data[i].mode & 4) {
			out += "<value id=\"" + m_data[i].id + "\" mode=\"4\" >";
			out += m_data[i].stringValue;
			out += "</value>\n";
		}
	}
	out += "</preset>\n";
	//  qDebug() << "WidgetPreset::getXmlText() " << out;
	return out;
}

QString WidgetPreset::getName()
{
	return m_name;
}

int WidgetPreset::getNumber()
{
	return m_number;
}

QStringList WidgetPreset::getWidgetIds()
{
	QStringList list;
	for (int i = 0; i < m_data.size(); i++) {
		list << m_data[i].id;
	}
	return list;
}

//int WidgetPreset::getMode(QString id)
//{
//  int index = idIndex(id);
//  if (index >= 0 && index < m_data.size()) {
//    return m_data[index].mode;
//  }
//  return -1;
//}

int WidgetPreset::getMode(int index)
{
	return m_data[index].mode;
}

//double WidgetPreset::getValue(QString id)
//{
//  int index = idIndex(id);
//  if (index >= 0 && index < m_data.size()) {
//    return m_data[index].value;
//  }
//  qDebug() << "WidgetPreset::getValue UUid not recognized!";
//  return 0.0;
//}

double WidgetPreset::getValue(int index)
{
	return m_data[index].value;
}

//double WidgetPreset::getValue2(QString id)
//{
//  int index = idIndex(id);
//  if (index >= 0 && index < m_data.size()) {
//    return m_data[index].value2;
//  }
//  qDebug() << "WidgetPreset::getValue2 UUid not recognized!";
//  return 0.0;
//}

double WidgetPreset::getValue2(int index)
{
	return m_data[index].value2;
}

//QString WidgetPreset::getStringValue(QString id)
//{
//  int index = idIndex(id);
//  if (index >= 0 && index < m_data.size()) {
//    return m_data[index].stringValue;
//  }
//  qDebug() << "WidgetPreset::getStringValue UUid not recognized!";
//  return QString();
//}

QString WidgetPreset::getStringValue(int index)
{
	return m_data[index].stringValue;
}

void WidgetPreset::setName(QString name)
{
	m_name = name;
}

void WidgetPreset::setNumber(int number)
{
	m_number = number;
}

void WidgetPreset::addValue(QString id, double value)
{
	int index = idIndex(id);
	if (index < 0) {
		PresetData p;
		m_data.append(p);
		index = m_data.size() - 1;
		m_data[index].id = id;
		m_data[index].mode = 0;
	}
	if (index >= m_data.size()) {
		qDebug() << "WidgetPreset::setValue index out of range";
		return;
	}
	m_data[index].mode = m_data[index].mode | 1;
	m_data[index].value = value;
	//  qDebug() << " WidgetPreset::addValue " << m_data[index].mode;
}

void WidgetPreset::addValue2(QString id, double value)
{
	int index = idIndex(id);
	if (index < 0) {
		PresetData p;
		m_data.append(p);
		index = m_data.size() - 1;
		m_data[index].id = id;
		m_data[index].mode = 0;
	}
	if (index >= m_data.size()) {
		qDebug() << "WidgetPreset::setValue2 index out of range";
		return;
	}
	m_data[index].mode = m_data[index].mode | 2;
	m_data[index].value2 = value;
}

void WidgetPreset::addStringValue(QString id, QString value)
{
	int index = idIndex(id);
	if (index < 0) {
		PresetData p;
		m_data.append(p);
		index = m_data.size() - 1;
		m_data[index].id = id;
		m_data[index].mode = 0;
	}
	if (index >= m_data.size()) {
		qDebug() << "WidgetPreset::setStringValue index out of range";
		return;
	}
	m_data[index].mode = m_data[index].mode | 4;
	m_data[index].stringValue = value;
	//  qDebug() << "WidgetPreset::addStringValue " << value;
}

void WidgetPreset::clear()
{
	m_data.clear();
}

//void WidgetPreset::purge()
//{
//  // Discard repeated entries. Is this really necessary?
//  qDebug() << "WidgetPreset::purge() not implemented yet.";
//}

int WidgetPreset::idIndex(QString id)
{
	int index = -1;
	for (int i = 0; i < m_data.size(); i++) {
		//    qDebug() << "WidgetPreset::idIndex " << id << "---" << m_data[i].id;
		if (m_data[i].id == id) {
			index = i;
			break;
		}
	}
	return index;
}
