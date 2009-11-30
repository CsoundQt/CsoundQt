/*
    Copyright (C) 2009 Andres Cabrera
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

#include "widgetpreset.h"

WidgetPreset::WidgetPreset()
{
}

QString WidgetPreset::getName()
{
  return m_name;
}

double WidgetPreset::getValue(QString id)
{
  int index = idIndex(id);
  if (index >= 0 && index < m_data.size()) {
    return m_data[index].value;
  }
  qDebug() << "WidgetPreset::getValue UUid not recognized!";
  return 0.0;
}

double WidgetPreset::getValue2(QString id)
{
  int index = idIndex(id);
  if (index >= 0 && index < m_data.size()) {
    return m_data[index].value2;
  }
  qDebug() << "WidgetPreset::getValue2 UUid not recognized!";
  return 0.0;
}

QString WidgetPreset::getStringValue(QString id)
{
  int index = idIndex(id);
  if (index >= 0 && index < m_data.size()) {
    return m_data[index].stringValue;
  }
  qDebug() << "WidgetPreset::getStringValue UUid not recognized!";
  return QString();
}

void WidgetPreset::setName(QString name)
{
  m_name = name;
}

void WidgetPreset::setValue(QString id, double value)
{
  int index = idIndex(id);
  if (index < 0) {
    PresetData p;
    m_data.append(p);
    index = m_data.size() - 1;
  }
  if (index >= m_data.size()) {
    qDebug() << "WidgetPreset::setValue index out of range";
    return;
  }
  m_data[index].value = value;
}

void WidgetPreset::setValue2(QString id, double value)
{
  int index = idIndex(id);
  if (index < 0) {
    PresetData p;
    m_data.append(p);
    index = m_data.size() - 1;
  }
  if (index >= m_data.size()) {
    qDebug() << "WidgetPreset::setValue2 index out of range";
    return;
  }
  m_data[index].value2 = value;
}

void WidgetPreset::setStringValue(QString id, QString value)
{
  int index = idIndex(id);
  if (index < 0) {
    PresetData p;
    m_data.append(p);
    index = m_data.size() - 1;
  }
  if (index >= m_data.size()) {
    qDebug() << "WidgetPreset::setStringValue index out of range";
    return;
  }
  m_data[index].stringValue = value;
}

void WidgetPreset::clear()
{
  m_data.clear();
}

void WidgetPreset::purge()
{
  // Discard repeated entries. Is this really necessary?
  qDebug() << "WidgetPreset::purge() not implemented yet.";
}

int WidgetPreset::idIndex(QString id)
{
  int index = -1;
  for (int i = 0; i < m_data.size(); i++) {
    if (m_data[i].id == id) {
      index = i;
      break;
    }
  }
  return index;
}
