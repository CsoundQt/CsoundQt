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

#ifndef WIDGETPRESET_H
#define WIDGETPRESET_H

#include <QtCore>

class PresetData
{
  public:
    QString id;
    int mode; // 1=1 value 2=value2 4=stringValue  OR combination of these
    float value;
    float value2;
    QString stringValue;
};

class WidgetPreset
{
  public:
    WidgetPreset();

    QString getXmlText();
    QString getName();
    int getNumber();
    QStringList getWidgetIds();
//    int getMode(QString id);
//    double getValue(QString id);
//    double getValue2(QString id);
//    QString getStringValue(QString id);
    int getMode(int index);
    double getValue(int index);
    double getValue2(int index);
    QString getStringValue(int index);

    void setName(QString name);
    void setNumber(int number);
    void addValue(QString id, double value);
    void addValue2(QString id, double value);
    void addStringValue(QString id, QString value);

    int idIndex(QString id);  // index of id data -1 if not exists

    void clear();
//    void purge();

  private:
    QString m_name;
    int m_number;
    QVector<PresetData> m_data;
};

#endif // WIDGETPRESET_H
