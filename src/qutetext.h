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
#ifndef QUTETEXT_H
#define QUTETEXT_H

#include "qutewidget.h"

class QuteText : public QuteWidget
{
  Q_OBJECT
  public:
    QuteText(QWidget *parent);

    ~QuteText();

    QString getWidgetLine();

    double getValue();

    void setResolution(double resolution);
    void setAlignment(int alignment);
    void setFont(QString font);
    void setFontSize(int fontSize);
    void setTextColor(QColor textColor);
    void setBgColor(QColor bgColor);
    void setBg(bool bg);
    void setBorder(bool border);
    void setText(QString text);

    virtual void createPropertiesDialog();
    virtual void applyProperties();

  private:
    double m_resolution;
//     int m_alignment;
    QString m_font;
    int m_fontSize;
//     QColor m_textColor;
//     QColor m_bgColor;
//     bool m_bg;
//     bool m_border;

    QLineEdit *text;
    QPushButton *textColor;
    QPushButton *bgColor;
    QCheckBox *bg;
    QCheckBox *border;

  private slots:
    void selectTextColor();
    void selectBgColor();
};

class QuteTextEdit : public QTextEdit
{
  Q_OBJECT
  public:
    QuteTextEdit(QWidget* parent) : QTextEdit(parent)
    {
    }

    ~QuteTextEdit() {};

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event)
    {
      emit(popUpMenu(event->globalPos()));
    }

  signals:
    void popUpMenu(QPoint pos);
};

class QuteLabel : public QLabel
{
  Q_OBJECT
  public:
    QuteLabel(QWidget* parent) : QLabel(parent)
    {
    }

    ~QuteLabel() {};

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event)
    {
      emit(popUpMenu(event->globalPos()));
    }

  signals:
    void popUpMenu(QPoint pos);
};

#endif
