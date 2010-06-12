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
    QWidget(parent, f), m_csdName(csdName),
    m_ui(new Ui::LiveEventFrame)
{
  m_ui->setupUi(this);

  setWindowTitle(m_csdName);
//  setWindowFlags(windowFlags() | Qt::WindowStaysOnTopHint);
  m_sheet = new EventSheet(this);
//  m_sheet->show();
  m_sheet->setTempo(60.0);
  m_sheet->setLoopLength(8.0);
  m_sheet->hide();
  connect(m_sheet,SIGNAL(modified()), this, SLOT(setModified()));
  connect(m_sheet,SIGNAL(setLoopRangeFromSheet(double,double)), this, SLOT(markLoop(double,double)));

  m_ui->scrollArea->setWidget(m_sheet);

  m_editor = new QTextEdit(this);
  m_editor->hide();

  m_modified = false;
  m_mode = 0; // Sheet mode by default

  connect(m_ui->actionComboBox,SIGNAL(activated(int)), this, SLOT(doAction(int)));
  connect(m_ui->tempoSpinBox,SIGNAL(valueChanged(double)), this, SLOT(setTempo(double)));
  connect(m_ui->modeComboBox,SIGNAL(activated(int)), this, SLOT(setMode(int)));
  connect(m_ui->loopLengthSpinBox,SIGNAL(valueChanged(double)), this, SLOT(setLoopLength(double)));

//  setVisibleEnabled(true);
//  this->setVisible(false);
//  m_ui->hide();
}

LiveEventFrame::~LiveEventFrame()
{
//  qDebug() << "LiveEventFrame::~LiveEventFrame()";
  disconnect(m_ui->actionComboBox, 0,0,0);
  disconnect(m_ui->tempoSpinBox, 0,0,0);
  disconnect(m_ui->modeComboBox, 0,0,0);
  disconnect(m_ui->loopLengthSpinBox, 0,0,0);
  disconnect(m_sheet, 0,0,0);
  delete m_sheet;
  delete m_editor;
  delete m_ui;
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
    m_editor = static_cast<QTextEdit *>(m_ui->scrollArea->takeWidget());
    m_sheet->setFromText(m_editor->toPlainText(), 0,0, -1, -1);
    m_ui->scrollArea->setWidget(m_sheet);
    m_sheet->show();
  }
  else if (mode == 1) {
    m_sheet->stopAllEvents();
    m_sheet->hide();
    m_sheet = static_cast<EventSheet *>(m_ui->scrollArea->takeWidget());
    m_editor->setText(m_sheet->getPlainText());
    m_ui->scrollArea->setWidget(m_editor);
    m_editor->show();
  }
  m_mode = mode;
}

void LiveEventFrame::setTempo(double tempo)
{
//  qDebug() << "LiveEventFrame::setTempo";
  m_ui->tempoSpinBox->setValue(tempo);
  m_sheet->setTempo(tempo);
  emit setTempoFromPanel(this, tempo);  // Signal from sheet must go a long way to do this line...
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
  m_ui->loopLengthSpinBox->setValue(length);
  m_sheet->setLoopLength(length);
  emit setLoopLengthFromPanel(this, length);  // Signal from sheet must go a long way to do this line...
  //TODO add sending length to other modes here too
}

void LiveEventFrame::setLoopRange(double start, double end)
{
  m_sheet->markLoop(start,end);
  m_loopStart = start;
  m_loopEnd = end;
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
    renameDialog();
  }
  else if (action == 5) {
    markLoop();
  }
  m_ui->actionComboBox->setCurrentIndex(0);
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
  int ret = QMessageBox::Ok;
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
  return m_ui->tempoSpinBox->value();
}

QString LiveEventFrame::getName()
{
  return m_name;
}

double LiveEventFrame::getLoopLength()
{
  return m_ui->loopLengthSpinBox->value();
}

QString LiveEventFrame::getPlainText()
{
  QString panel = "<EventPanel name=\"";
  panel += getName() + "\" tempo=\"";
  panel += QString::number(getTempo(), 'f', 8) + "\" loop=\"";
  panel += QString::number(getLoopLength(), 'f', 8) + "\" x=\"";
  panel += QString::number(x()) + "\" y=\"";
  panel += QString::number(y()) + "\" width=\"";
  panel += QString::number(width()) + "\" height=\"";
  panel += QString::number(height()) + "\" visible=\"";
  panel += QString(getVisibleEnabled()? "true":"false") + "\" loopStart=\"";
  panel += QString::number(m_loopStart) + "\" loopEnd=\"";
  panel += QString::number(m_loopEnd) + "\">";
  panel += m_sheet->getPlainText();
  panel += "</EventPanel>\n";
  return panel;
}

void LiveEventFrame::getEvents(unsigned long /*ksmps*/, QStringList */*eventText*/)
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

void LiveEventFrame::renameDialog()
{
  QDialog d;
  QVBoxLayout l(&d);
  QLabel label(tr("Enter new name", "New name for Live Event panel"));
  QLineEdit line;
//  d.resize(300, d.height());
//  line.resize(300, line.height());
  line.setText(m_name);
  l.addWidget(&label);
  l.addWidget(&line);
  connect(&line, SIGNAL(editingFinished()), &d, SLOT(accept ()) );
  int ret = d.exec();
  if (ret == QDialog::Accepted) {
    emit renamePanel(this, line.text());
  }
}

void LiveEventFrame::markLoop(double start, double end)
{
  m_loopStart = start;
  m_loopEnd = end;
  m_sheet->markLoop(start, end);
  emit setLoopRangeFromPanel(this, start, end);  // Signal from sheet must go a long way to do this line...
}

void LiveEventFrame::loopPanel(bool loop)
{
  m_sheet->setLoopActive(loop);
}

//void LiveEventFrame::changeEvent(QEvent *e)
//{
//  QFrame::changeEvent(e);
//  switch (e->type()) {
//  case QEvent::LanguageChange:
//    retranslateUi(this);
//    break;
//  default:
//    break;
//  }
//}

void LiveEventFrame::closeEvent (QCloseEvent * event)
{
  emit closed();
  event->accept();
}

//void LiveEventFrame::hideEvent (QHideEvent * event)
//{
//  qDebug() << "LiveEventFrame::hideEvent";
//  setVisibleEnabled(false);
//  QFrame::hideEvent(event);
//}
//
//void LiveEventFrame::showEvent (QShowEvent * event)
//{
//  qDebug() << "LiveEventFrame::showEvent";
//  setVisibleEnabled(true);
//  QFrame::showEvent(event);
//}

