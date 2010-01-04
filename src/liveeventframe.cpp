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

#include "liveeventframe.h"
#include "eventsheet.h"

#include <QTextEdit>
#include <QLabel>
#include <QVBoxLayout>
#include <QLineEdit>
#include <QDialog>
#include <QDoubleSpinBox>
#include <QResizeEvent>

//Only for debug
#include <QtCore>

LiveEventFrame::LiveEventFrame(QString csdName, QWidget *parent, Qt::WindowFlags f) :
    QFrame(parent, f), m_csdName(csdName)
{
  setupUi(this);

  setWindowTitle(m_csdName);
  m_sheet = new EventSheet(this);
  m_sheet->show();
  m_sheet->setTempo(60.0);
  m_sheet->setLoopLength(8.0);
  scrollArea->setWidget(m_sheet);

  m_editor = new QTextEdit(this);
  m_editor->hide();

  m_mode = 0; // Sheet mode by default

  connect(tempoSpinBox,SIGNAL(valueChanged(double)), this, SLOT(setTempo(double)));
  connect(loopLengthSpinBox,SIGNAL(valueChanged(double)), this, SLOT(setLoopLength(double)));
}

EventSheet * LiveEventFrame::getSheet()
{
  return m_sheet;
}

void LiveEventFrame::setTempo(double tempo)
{
  qDebug() << "LiveEventFrame::setTempo";
  tempoSpinBox->setValue(tempo);
  m_sheet->setTempo(tempo);
  //TODO add sending tempo to other modes here too
}

void LiveEventFrame::setName(QString name)
{
  m_name = name;
}

void LiveEventFrame::setLoopLength(double length)
{
  qDebug() << "LiveEventFrame::setLoopLength";
  loopLengthSpinBox->setValue(length);
  m_sheet->setLoopLength(length);
  //TODO add sending length to other modes here too
}

void LiveEventFrame::setFromText(QString text)
{
  if (m_mode == 0) { // Sheet mode
    m_sheet->setFromText(text);
    m_sheet->clearHistory();
    m_sheet->markHistory();
  }
  else if (m_mode == 1) { // text mode

  }
}

double LiveEventFrame::getTempo()
{
  return tempoSpinBox->value();
}

QString LiveEventFrame::getName()
{
  return m_name;
}

double LiveEventFrame::getLoopLength()
{
  return loopLengthSpinBox->value();
}

QString LiveEventFrame::getPlainText()
{
  if (m_mode == 0) { // Sheet mode
    return m_sheet->getPlainText();
  }
  else if (m_mode == 1) { // text mode
    return "";  //FIXME implement
  }
  return QString();
}

void LiveEventFrame::rename()
{
  QDialog d;
  QVBoxLayout l(&d);
  QLabel label("Enter new name");
  QLineEdit line;
//  d.resize(300, d.height());
//  line.resize(300, line.height());
  line.setText(m_name);
  l.addWidget(&label);
  l.addWidget(&line);
  connect(&line, SIGNAL(editingFinished()), &d, SLOT(accept ()) );
  int ret = d.exec();
  if (ret == QDialog::Accepted) {
    m_name = line.text();
  }
}

void LiveEventFrame::changeEvent(QEvent *e)
{
    QFrame::changeEvent(e);
    switch (e->type()) {
    case QEvent::LanguageChange:
        retranslateUi(this);
        break;
    default:
        break;
    }
}

void LiveEventFrame::resizeEvent (QResizeEvent * event)
{
  QSize s = event->size();
  s.setHeight(s.height() - 30);
  scrollArea->resize(s);
}

void LiveEventFrame::closeEvent (QCloseEvent * event)
{
  emit closed();
}
