/*
    Copyright (C) 2010 Andres Cabrera
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

#include "liveeventcontrol.h"
#include "ui_liveeventcontrol.h"

LiveEventControl::LiveEventControl(QWidget *parent) :
    QWidget(parent),
    m_ui(new Ui::LiveEventControl)
{
  this->setWindowFlags(Qt::Window);
  m_ui->setupUi(this);
  m_ui->panelTableWidget->setColumnWidth(0,40);
  m_ui->panelTableWidget->setColumnWidth(1,40);
  m_ui->panelTableWidget->setColumnWidth(2,40);
  m_ui->panelTableWidget->setColumnWidth(3,40);
  m_ui->panelTableWidget->setColumnWidth(4,280);
  m_ui->panelTableWidget->setColumnWidth(5,80);
  m_ui->panelTableWidget->setColumnWidth(6,80);
  m_ui->panelTableWidget->setColumnWidth(7,50);
  m_ui->stopAllButton->hide(); // TODO implement stop all
  connect(m_ui->newButton,SIGNAL(released()), this, SLOT(newButtonReleased()));
  connect(m_ui->panelTableWidget, SIGNAL(cellChanged ( int , int  )), this, SLOT(cellChangedSlot( int , int  )));
  connect(m_ui->panelTableWidget, SIGNAL(cellClicked ( int , int  )), this, SLOT(cellClickedSlot( int , int  )));
}

LiveEventControl::~LiveEventControl()
{
  delete m_ui;
}

void LiveEventControl::renamePanel(int index, QString newName)
{
  QTableWidgetItem * item = getItem(index, 4);
  item->setText(newName);
}

void LiveEventControl::setPanelLoopRange(int index, double start, double end)
{
  QTableWidgetItem * item = getItem(index, 6);
  item->setText(QString::number(start + 1) + "-" + QString::number(end + 1));
}

void LiveEventControl::setPanelLoopLength(int index, double length)
{
  QTableWidgetItem * item = getItem(index, 5);
  item->setText(QString::number(length));
}

void LiveEventControl::setPanelLoopEnabled(int index, bool enabled)
{
	QTableWidgetItem * item = getItem(index, 2);
	item->setCheckState(enabled ? Qt::Checked : Qt::Unchecked);
}

void LiveEventControl::setPanelTempo(int index, double tempo)
{
  QTableWidgetItem * item = getItem(index, 7);
  item->setText(QString::number(tempo));
}

void LiveEventControl::removePanel(int index)
{
  qDebug() << "LiveEventControl::removePanel " << index;
  m_ui->panelTableWidget->removeRow(index);
}

void LiveEventControl::appendPanel(LiveEventFrame *e)
{
  this->blockSignals(true);  // To avoid showing the panels when adding them (e.g. when starting up)
  int newRow = m_ui->panelTableWidget->rowCount();
//  qDebug() << "LiveEventControl::appendPanel " << newRow;
  m_ui->panelTableWidget->insertRow(newRow);
  m_ui->panelTableWidget->setRowHeight(newRow, 20);
  QTableWidgetItem *visibleItem = getItem(newRow, 0);
//  visibleItem->setFlags(Qt::ItemIsEnabled | Qt::ItemIsUserCheckable);
  visibleItem->setCheckState(e->getVisibleEnabled() ? Qt::Checked : Qt::Unchecked);
  connect(e, SIGNAL(closed(LiveEventFrame *)), this, SLOT(frameClosed(LiveEventFrame *)) );
  QTableWidgetItem *playItem = getItem(newRow, 1);
  playItem->setIcon(QIcon(":/images/gtk-media-play-ltr.png"));
//  playItem->setCheckState(visible ? Qt::Checked : Qt::Unchecked);
  QTableWidgetItem *loopItem = getItem(newRow, 2);
  loopItem->setCheckState(Qt::Unchecked);
  QTableWidgetItem *syncItem = getItem(newRow, 3);
//  loopItem->setCheckState(visible ? Qt::Checked : Qt::Unchecked);
  QTableWidgetItem *nameItem = getItem(newRow, 4);
  nameItem->setData(Qt::DisplayRole, QVariant(e->getName()));
  QTableWidgetItem *loopLengthItem = getItem(newRow, 5);
  loopLengthItem->setData(Qt::DisplayRole, QVariant(e->getLoopLength()));

  QTableWidgetItem *loopRangeItem = getItem(newRow, 6);
  loopRangeItem->setText(QString::number(e->getLoopStart() + 1) + "-"
                         + QString::number(e->getLoopEnd() + 1) );
//  loopRangeItem->setCheckState(visible ? Qt::Checked : Qt::Unchecked);
  QTableWidgetItem *tempoItem = getItem(newRow, 7);
  tempoItem->setData(Qt::DisplayRole, QVariant(e->getTempo()));

  this->blockSignals(false);
//  setPanelProperty(newRow, "LE_visible", visible);
//  setPanelProperty(newRow, "LE_play", play);
//  setPanelProperty(newRow, "LE_loop", loop);
//  setPanelProperty(newRow, "LE_sync", sync);
//  setPanelProperty(newRow, "LE_name", name);
//  setPanelProperty(newRow, "LE_loopLength", loopLength);
//  setPanelProperty(newRow, "LE_loopRange", loopRange);
//  setPanelProperty(newRow, "LE_tempo", tempo);
}

void LiveEventControl::setPanelProperty(int index, QString property, QVariant value)
{
  if (index < 0 || index >= m_ui->panelTableWidget->rowCount()) {
    qDebug() << "LiveEventControl::setPanelProperty invalid index " << index;
    return;
  }
  if (property == "LE_visible") {
    emit setPanelVisible(index, value.toBool());
  }
//  else if (property == "LE_play") {
//    if (value.toBool()) {
//      emit playPanel(index);
//    }
//    else {
//      emit stopPanel(index);
//    }
//  }
//  else if (property == "LE_loop") {
//    emit loopPanel(index, value.toBool());
//  }
  else if (property == "LE_sync") {
    emit setPanelSync(index, value.toInt());
  }
  else if (property == "LE_name") {
    emit setPanelNameSignal(index, value.toString());
  }
  else {
    qDebug() << "LiveEventControl::setPanelProperty unknown property " << property;
  }
}

QTableWidgetItem * LiveEventControl::getItem(int row, int column)
{
  QTableWidgetItem * item = m_ui->panelTableWidget->item(row, column);
  if (item == 0) {
    item = new QTableWidgetItem(QTableWidgetItem::Type);
    m_ui->panelTableWidget->setItem(row, column, item);
  }
  if (column == 0 || column == 2) {
    item->setFlags(Qt::ItemIsUserCheckable |Qt::ItemIsEnabled);
  }
  else if (column == 4) {
    item->setFlags(Qt::ItemIsEditable | Qt::ItemIsEnabled);
  }
  else {
    item->setFlags(Qt::ItemIsEnabled);
  }
  return item;
}

void LiveEventControl::openLoopRangeDialog(int row)
{
  QDialog d;
  QVBoxLayout l(&d);
  QLabel ls(tr("Loop start"),&d);
  QSpinBox ss(&d);
  QLabel le(tr("Loop end"),&d);
  QSpinBox se(&d);
  QPushButton okButton(tr("Ok"), &d);
  QPushButton cancelButton(tr("Cancel"), &d);
  connect(&okButton,SIGNAL(released()),&d,SLOT(accept()));
  connect(&cancelButton,SIGNAL(released()),&d,SLOT(reject()));
  l.addWidget(&ls);
  l.addWidget(&ss);
  l.addWidget(&le);
  l.addWidget(&se);
  l.addWidget(&okButton);
  l.addWidget(&cancelButton);
  QTableWidgetItem *item = getItem(row,6);
  QStringList bounds(item->text().split("-"));
  if (bounds.size() > 1) {
    if (bounds[0].toInt() >= 0) {
      ss.setValue(bounds[0].toInt());
    }
    if (bounds[1].toInt() >= 0) {
      se.setValue(bounds[1].toInt());
    }
  }
  int ret = d.exec();
  if (ret == QDialog::Accepted) {
    QString range = QString::number(ss.value()) + "-" + QString::number(se.value());
    qDebug() << "LiveEventControl::openLoopRangeDialog " << row << range;
    QTableWidgetItem *item = m_ui->panelTableWidget->item(row,6);
    item->setText(range);
    emit setPanelLoopRangeSignal(row, ss.value() - 1,se.value() - 1);
  }
}

void LiveEventControl::closeEvent(QCloseEvent * event)
{
  qDebug() << "LiveEventControl::closeEvent";
//  emit hidePanels(false);
  emit closed();
  event->accept();
}

void LiveEventControl::changeEvent(QEvent *e)
{
  QWidget::changeEvent(e);
  switch (e->type()) {
  case QEvent::LanguageChange:
    m_ui->retranslateUi(this);
    break;
  default:
    break;
  }
}

void  LiveEventControl::newButtonReleased()
{
  emit newPanel();
}

void  LiveEventControl::cellChangedSlot(int row, int column)
{
  QTableWidgetItem *item = m_ui->panelTableWidget->item(row, column);
  if (column == 0) { // Visible
    emit setPanelVisible(row, item->checkState() == Qt::Checked);
  }
  else if (column == 2) { // Loop
    emit loopPanel(row, item->checkState() == Qt::Checked);
  }
  else if (column == 4) { // Name
    emit setPanelNameSignal(row, item->data(Qt::DisplayRole).toString());
  }
}

void  LiveEventControl::cellClickedSlot(int row, int column)
{
  if (column == 1) { // Play
    qDebug() << "LiveEventControl::cellChangedSlot play";
    emit playPanel(row);
  }
  else if (column == 3) { // Sync
    qDebug() << "LiveEventControl::cellChangedSlot sync not implemented yet.";
  }
  else if (column == 6) { // Loop Range
    openLoopRangeDialog(row);
  }
}

void LiveEventControl::frameClosed(LiveEventFrame *e)
{

    qDebug() << "LiveEventControl::frameClosed not implemented...";
}
