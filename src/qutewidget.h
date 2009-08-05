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

#ifndef QUTEWIDGET_H
#define QUTEWIDGET_H

#include <QtGui>
#include <QHash>

#define USE_WIDGET_MUTEX

class QuteWidget : public QWidget
{
  Q_OBJECT
  public:
    QuteWidget(QWidget* parent);

    ~QuteWidget();

    const QString name() {return m_name;}

    virtual void setWidgetLine(QString line);
    virtual void setChannelName(QString name);
    virtual void setWidgetGeometry(int x, int y, int w, int h);
    virtual void setRange(int min, int max);
    virtual void setValue(double value);
    virtual void setValue2(double value);
    virtual void setValue(QString value);
    virtual void setResolution(double resolution);
    virtual void setChecked(bool checked);

    virtual QString getChannelName();
    virtual QString getChannel2Name();
    virtual QString getWidgetLine();
    virtual QString getWidgetXmlText();
    virtual double getValue();
    virtual double getValue2();
    virtual double getResolution();
    virtual QString getStringValue();
    virtual QString getCabbageLine();
    virtual QString getCsladspaLine();

    void markChanged();

  protected:
    QSpinBox *xSpinBox;
    QSpinBox *ySpinBox;
    QSpinBox *wSpinBox;
    QSpinBox *hSpinBox;
    QLabel *channelLabel;
    QLineEdit *nameLineEdit;
    QString m_line;
    QWidget *m_layoutWidget;
    QWidget *m_widget;
    QDialog *dialog;
    QGridLayout *layout;

    QString m_name, m_name2;
    double m_min, m_max;
    double m_resolution;
//     double m_min2,m_max2;
    double m_value, m_value2;

    QMutex mutex;

    virtual void contextMenuEvent(QContextMenuEvent *event);
    virtual void mousePressEvent(QMouseEvent *event);

    virtual void createPropertiesDialog();
    virtual void applyProperties();

    QList<QAction *> getParentActionList();

  private:
    QAction *propertiesAct;
//     QAction *deleteAct;

    QPushButton *applyButton;
    QPushButton *cancelButton;
    QPushButton *acceptButton;

  public slots:
    void popUpMenu(QPoint pos);

  protected slots:
    void apply();
    void openProperties();
    void deleteWidget();
    void valueChanged(int value);
    void valueChanged(double value);
    void value2Changed(double value);

  signals:
    void newValue(QPair<QString,double> channelValue);
    void newValue(QPair<QString,QString> channelValue);
    void widgetChanged(QuteWidget* widget);
    void deleteThisWidget(QuteWidget *thisWidget);
};

#endif
