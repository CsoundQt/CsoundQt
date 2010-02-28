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
#include <QMessageBox>

//Only for debug
#include <QtCore>

LiveEventFrame::LiveEventFrame(QString csdName, QWidget *parent, Qt::WindowFlags f) :
    QFrame(parent, f), m_csdName(csdName)
{
  setupUi(this);

  setWindowTitle(m_csdName);
//  setWindowFlags(windowFlags() | Qt::WindowStaysOnTopHint);
  m_sheet = new EventSheet(this);
  m_sheet->show();
  m_sheet->setTempo(60.0);
  m_sheet->setLoopLength(8.0);
  connect(m_sheet,SIGNAL(modified()), this, SLOT(setModified()));
  scrollArea->setWidget(m_sheet);

  m_editor = new QTextEdit(this);
  m_editor->hide();

  m_modified = false;
  m_mode = 0; // Sheet mode by default

  connect(actionComboBox,SIGNAL(activated(int)), this, SLOT(doAction(int)));
  connect(tempoSpinBox,SIGNAL(valueChanged(double)), this, SLOT(setTempo(double)));
  connect(modeComboBox,SIGNAL(activated(int)), this, SLOT(setMode(int)));
  connect(loopLengthSpinBox,SIGNAL(valueChanged(double)), this, SLOT(setLoopLength(double)));
}

LiveEventFrame::~LiveEventFrame()
{
//  qDebug() << "LiveEventFrame::~LiveEventFrame()";
  disconnect(actionComboBox, 0,0,0);
  disconnect(tempoSpinBox, 0,0,0);
  disconnect(modeComboBox, 0,0,0);
  disconnect(loopLengthSpinBox, 0,0,0);
  disconnect(m_sheet, 0,0,0);
  delete m_sheet;
  delete m_editor;
}

EventSheet * LiveEventFrame::getSheet()
{
  return m_sheet;
}

void LiveEventFrame::setMode(int mode)
{
  if (m_mode == mode)
    return;
  if (mode == 0) {
    m_editor->hide();
    m_editor = static_cast<QTextEdit *>(scrollArea->takeWidget());
    m_sheet->setFromText(m_editor->toPlainText(), 0,0, -1, -1);
    scrollArea->setWidget(m_sheet);
    m_sheet->show();
  }
  else if (mode == 1) {
    m_sheet->stopAllEvents();
    m_sheet->hide();
    m_sheet = static_cast<EventSheet *>(scrollArea->takeWidget());
    m_editor->setText(m_sheet->getPlainText());
    scrollArea->setWidget(m_editor);
    m_editor->show();
  }
  m_mode = mode;
}

void LiveEventFrame::setTempo(double tempo)
{
//  qDebug() << "LiveEventFrame::setTempo";
  tempoSpinBox->setValue(tempo);
  m_sheet->setTempo(tempo);
  //TODO add sending tempo to other modes here too
}

void LiveEventFrame::setName(QString name)
{
  m_name = name;
  setWindowTitle(m_csdName + " -- " + m_name);
}

void LiveEventFrame::setLoopLength(double length)
{
//  qDebug() << "LiveEventFrame::setLoopLength";
  loopLengthSpinBox->setValue(length);
  m_sheet->setLoopLength(length);
  //TODO add sending length to other modes here too
}

void LiveEventFrame::setModified(bool mod)
{
  m_modified = mod;
}

void LiveEventFrame::doAction(int action)
{
  // TODO This really should be done with QActions
  if (action == 1) {
    newFrame();
  }
  else if (action == 2) {
    cloneFrame();
  }
  else if (action == 3) {
    deleteFrame(true);
    return;
  }
  else if (action == 4) {
    rename();
  }
  actionComboBox->setCurrentIndex(0);
}

void LiveEventFrame::newFrame()
{
  emit(newFrameSignal(QString()));
}

void LiveEventFrame::cloneFrame()
{
  emit(newFrameSignal(getPlainText()));
}

void LiveEventFrame::deleteFrame(bool ask)
{
  int ret;
  if (ask) {
    ret = QMessageBox::question(this,
                                    tr("Delete Frame"),
                                    tr("Are you sure you want to delete this frame?"),
                                    QMessageBox::Ok | QMessageBox::Cancel,
                                    QMessageBox::Cancel);
  }
  if (ret == QMessageBox::Ok || !ask)
    emit(deleteFrameSignal(this));
}

void LiveEventFrame::setFromText(QString text)
{
  if (m_mode == 0) { // Sheet mode
    m_sheet->setFromText(text,0,0,0,0,true);
    m_sheet->clearHistory();
    m_sheet->markHistory();
    m_modified = false;
  }
  else if (m_mode == 1) { // text mode

    m_modified = false;
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
  return m_sheet->getPlainText();
}

void LiveEventFrame::getEvents(unsigned long ksmps, QStringList *eventText)
{
  // TODO: implement
}

bool LiveEventFrame::isModified()
{
  return m_modified;
}

//void LiveEventFrame::forceDestroy()
//{
//  this->destroy();
//}

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
    setName(line.text());
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

//void LiveEventFrame::moveEvent (QResizeEvent * event)
//{
//  QSize s = event->size();
//  s.setHeight(s.height() - 30);
//  scrollArea->resize(s);
//}

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
