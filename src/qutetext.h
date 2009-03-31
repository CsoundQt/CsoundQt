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

    virtual QString getWidgetLine();

    virtual double getValue();
    virtual void setValue(double value);
    virtual void setValue(QString value);

    void setType(QString type);
    virtual void setAlignment(int alignment);
    void setFont(QString font);
    void setFontSize(int fontSize);
    void setTextColor(QColor textColor);
    void setBgColor(QColor bgColor);
    void setBg(bool bg);
    void setBorder(bool border);
    virtual void setText(QString text);

  protected:
    virtual void createPropertiesDialog();
    virtual void applyProperties();

    double m_resolution;
    QString m_type;
//     int m_alignment;
    QString m_font;
    int m_fontSize;
    QString m_text;
//     QColor m_textColor;
//     QColor m_bgColor;
//     bool m_bg;
//     bool m_border;

//     QComboBox * typeComboBox;
    QTextEdit *text;
    QPushButton *textColor;
    QPushButton *bgColor;
    QCheckBox *bg;
    QCheckBox *border;
    QFontComboBox  *font;
    QComboBox * fontSize;
    QComboBox * alignment;

  private slots:
    void selectTextColor();
    void selectBgColor();
};

class QuteLineEdit : public QuteText
{
  Q_OBJECT
  public:
    QuteLineEdit(QWidget* parent);
    ~QuteLineEdit();

    virtual void setAlignment(int alignment);
    virtual void setText(QString text);
    virtual QString getWidgetLine();
    virtual QString getStringValue();
    virtual void dropEvent(QDropEvent *event);

  protected:
    virtual void createPropertiesDialog();
    virtual void applyProperties();
};

class QuteScrollNumber : public QuteText
{
  Q_OBJECT
  public:
    QuteScrollNumber(QWidget* parent);
    ~QuteScrollNumber();

    virtual void setResolution(double resolution);
    virtual void setAlignment(int alignment);
    virtual void setText(QString text);
    virtual QString getWidgetLine();
    virtual QString getCabbageLine();
    virtual QString getCsladspaLine();
    virtual QString getStringValue();
    virtual double getValue();

  protected:
    virtual void createPropertiesDialog();
    virtual void applyProperties();

    QDoubleSpinBox* resolutionSpinBox;
    int m_places;

  public slots:
    void addValue(double delta);
    void setValue(double value);
};

class ScrollNumberWidget : public QLabel
{
  Q_OBJECT
  public:
    ScrollNumberWidget(QWidget* parent) : QLabel(parent) {pressed = false;}
    ~ScrollNumberWidget() {}

    void setResolution(double resolution)
    {
      m_resolution = resolution;
    }
    double getResolution()
    {
      return m_resolution;
    }

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event)
    {emit(popUpMenu(event->globalPos()));}

    virtual void mouseMoveEvent(QMouseEvent * event)
    {
      if (pressed) {
        double delta = (oldy - event->y()) * m_resolution;
        emit addValue(delta);
        oldy = event->y();
      }
    }
    virtual void mousePressEvent(QMouseEvent * event)
    {
      if (event->button() & Qt::LeftButton) {
        if (event->modifiers() & Qt::ShiftModifier) {
          emit setValue(0);
        }
        oldy = event->y();
        pressed = true;
      }
    }
    virtual void mouseReleaseEvent (QMouseEvent * event)
    {
      QLabel::mouseReleaseEvent(event);
      pressed = false;
    }

  private:
    double m_resolution;
    int oldy;
    bool pressed;

  signals:
    void popUpMenu(QPoint pos);
    void addValue(double delta);
    void setValue(double value);
};

#endif
