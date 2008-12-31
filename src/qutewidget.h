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
#ifndef QUTEWIDGET_H
#define QUTEWIDGET_H

#include <QtGui>
#include <QHash>

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
    virtual double getValue();
    virtual double getValue2();
    virtual QString getStringValue();

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

    virtual void contextMenuEvent(QContextMenuEvent *event);
    virtual void mousePressEvent(QMouseEvent *event);

    virtual void createPropertiesDialog();
    virtual void applyProperties();

    QList<QAction *> getParentActionList();

  private:
    QAction *propertiesAct;
    QAction *deleteAct;

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
    void newValue(QHash<QString,double> channelValue);
    void widgetChanged(QuteWidget* widget);
    void deleteThisWidget(QuteWidget *thisWidget);
};

#endif
