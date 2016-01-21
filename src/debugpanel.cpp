/*
	Copyright (C) 2013 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "debugpanel.h"
#include "ui_debugpanel.h"

#include <QInputDialog>
#include <QModelIndex>
#include <QTableWidget>
#include <QCheckBox>

#include <QDebug>

#include "newbreakpointdialog.h"

DebugPanel::DebugPanel(QWidget *parent) :
    QDockWidget(parent),
    ui(new Ui::DebugPanel)
{
    ui->setupUi(this);

    ui->breakpointTableWidget->setShowGrid(false);

    connect(ui->runButton, SIGNAL(toggled(bool)),
            this, SLOT(runToggle(bool)));
    connect(ui->pauseButton, SIGNAL(released()),
            this, SLOT(pause()));
    connect(ui->continueButton, SIGNAL(released()),
            this, SLOT(continueDebug()));
    connect(ui->nextButton, SIGNAL(released()),
            this, SLOT(next()));
    connect(ui->newBreakpointToolButton, SIGNAL(released()),
            this, SLOT(newBreakpoint()));
    connect(ui->deleteBreakpointToolButton, SIGNAL(released()),
            this, SLOT(deleteBreakpoint()));

    connect(ui->breakpointTableWidget, SIGNAL(cellChanged(int,int)),
            this, SLOT(cellChanged(int,int)));
    connect(ui->breakpointTableWidget, SIGNAL(currentCellChanged(int,int,int,int)),
            this, SLOT(currentCellChanged(int,int,int,int)));
}

DebugPanel::~DebugPanel()
{
    delete ui;
}

QVector<QVariantList> DebugPanel::getBreakpoints()
{
    QTableWidget *table = ui->breakpointTableWidget;
    QVector<QVariantList> breakpoints;
    for (int row = 0; row < table->rowCount(); row++) {
        QVariantList bp;
        QCheckBox *cb = static_cast<QCheckBox *>(table->cellWidget(row,0));
        if (cb->isChecked()) {
            QTableWidgetItem *item = table->item(row,1);
            bp << item->data(Qt::DisplayRole).toString();
			if (bp.back().toString() == "instr" ) {
				item = table->item(row,2);
				bp << item->data(Qt::DisplayRole).toDouble();
				item = table->item(row,3);
				bp << item->data(Qt::DisplayRole).toInt();
				breakpoints.append(bp);
			} else {
				item = table->item(row,2);
				QStringList parts = item->data(Qt::DisplayRole).toString().split(":");
				Q_ASSERT(parts.size() == 2);
				bp << parts[0].toInt();
				bp << parts[1].toInt();
				item = table->item(row,3);
				bp << item->data(Qt::DisplayRole).toInt();
				breakpoints.append(bp);
			}
        }
    }
    return breakpoints;
}

void DebugPanel::setDebugFilename(QString filename)
{
    ui->statusLabel->setText(QString("File: %1").arg(filename));
}

void DebugPanel::setVariableList(QVector<QVariantList> varList)
{
    QTableWidget *table = ui->stackTableWidget;
    table->setRowCount(0);
    int row = 0, column = 0;
    foreach(QVariantList var, varList) {
        table->insertRow(table->rowCount());
        column = 0;
        foreach(QVariant part, var) {
            QTableWidgetItem *item = new QTableWidgetItem(part.toString());
            table->setItem(row, column, item);
            column++;
        }
        row++;
    }
    table->setEnabled(true);
}

void DebugPanel::setInstrumentList(QVector<QVariantList> instrumentList)
{
    QTableWidget *table = ui->instrumentTableWidget;
    table->setRowCount(0);
    int row = 0, column = 0;
    foreach(QVariantList var, instrumentList) {
        if (var[0].toDouble() == 0) {
            continue;
        }
        table->insertRow(table->rowCount());
        column = 0;
        foreach(QVariant part, var) {
            QTableWidgetItem *item = new QTableWidgetItem(part.toString());
            table->setItem(row, column, item);
            column++;
        }
        row++;
    }
    table->setEnabled(true);
}

void DebugPanel::stopDebug()
{
    ui->statusLabel->setText(QString("Debugger stopped"));
    ui->runButton->setChecked(false);
    ui->stackTableWidget->setRowCount(0);
    ui->instrumentTableWidget->setRowCount(0);
    emit stopSignal();
}

void DebugPanel::runToggle(bool run_)
{
    if (run_) {
        run();
    } else {
        stopDebug();
    }
}

void DebugPanel::run()
{
    ui->stackTableWidget->setEnabled(false);
    ui->instrumentTableWidget->setEnabled(false);
    emit runSignal();
}

void DebugPanel::pause()
{
    emit pauseSignal();
}

void DebugPanel::continueDebug()
{
    ui->stackTableWidget->setEnabled(false);
    ui->instrumentTableWidget->setEnabled(false);
    emit continueSignal();
}

void DebugPanel::next()
{
    emit nextSignal();
}

void DebugPanel::newBreakpoint()
{
	NewBreakpointDialog newbp(this);
	newbp.setModal(true);
	newbp.exec();

	if (newbp.result() == QDialog::Accepted) {
		ui->breakpointTableWidget->blockSignals(true); // To avoid triggering the changed slots
		int row = ui->breakpointTableWidget->rowCount();
		ui->breakpointTableWidget->insertRow(row);
		QCheckBox *checkbox = new QCheckBox;
		checkbox->setChecked(true);
		checkbox->setEnabled(false);
		ui->breakpointTableWidget->setCellWidget(row, 0, checkbox);
		QTableWidgetItem *item = new QTableWidgetItem;
		item->setData(Qt::DisplayRole, newbp.type);
		item->setFlags(Qt::ItemIsEnabled | Qt::ItemIsSelectable); // not editable
		ui->breakpointTableWidget->setItem(row, 1, item);
		item = new QTableWidgetItem;
		item->setData(Qt::DisplayRole, newbp.instrline);
		ui->breakpointTableWidget->setItem(row, 2, item);
		item = new QTableWidgetItem;
		item->setData(Qt::DisplayRole, newbp.skip);
		ui->breakpointTableWidget->setItem(row, 3, item);
		ui->breakpointTableWidget->blockSignals(false);
		if (newbp.type == "instr") {
			emit addInstrumentBreakpoint(newbp.instr, newbp.skip);
		} else {
			emit addBreakpoint(newbp.line, newbp.instr, newbp.skip);
		}
	}
}

void DebugPanel::deleteBreakpoint()
{
    int row = ui->breakpointTableWidget->currentRow();
    if (row < 0) {
        return;
    }
    if (ui->breakpointTableWidget->item(row, 1)->data(Qt::DisplayRole).toString() == "instr") {
        double d = ui->breakpointTableWidget->item(row, 2)->data(Qt::DisplayRole).toDouble();
        emit removeInstrumentBreakpoint(d);
    }
	if (ui->breakpointTableWidget->item(row, 1)->data(Qt::DisplayRole).toString() == "line") {
		QString line = ui->breakpointTableWidget->item(row, 2)->data(Qt::DisplayRole).toString();
		int linenum = 0, instr = 0;
		if (line.contains(":")) {
			QStringList parts = line.split(":");
			Q_ASSERT(parts.size()==2);
			instr = parts[0].toInt();
			linenum = parts[1].toInt();
			Q_ASSERT(linenum >= 0);
			Q_ASSERT(instr >= 0);
		}
		emit removeBreakpoint(linenum, instr);
	}
    ui->breakpointTableWidget->removeRow(row);
}

void DebugPanel::cellChanged(int row, int column)
{
    switch(column) {
    case 0:
        // TODO enable/disable toggle
        break;
    case 2:
	case 3:
		if (ui->breakpointTableWidget->item(row, 1)->data(Qt::DisplayRole).toString() == "instr") {
			QTableWidgetItem *item = ui->breakpointTableWidget->item(row, 2);
			double d = item->data(Qt::DisplayRole).toDouble();
			int skip = item->data(Qt::DisplayRole).toInt();
			emit removeInstrumentBreakpoint(item->data(Qt::UserRole).toDouble());
            emit addInstrumentBreakpoint(d, skip);
		} else if (ui->breakpointTableWidget->item(row, 1)->data(Qt::DisplayRole).toString() == "line") {
			// Remove existing breakpoint
			QTableWidgetItem *item = ui->breakpointTableWidget->item(row, 2);
			QString oldInstrline = item->data(Qt::UserRole).toString();
			int line = 0, instr = 0;
			if (oldInstrline.contains(":")) {
				QStringList parts = oldInstrline.split(":");
				Q_ASSERT(parts.size() == 2);
				line = parts[1].toInt();
				instr = parts[0].toInt();
			} else {
				line = oldInstrline.toInt();
			}
			emit removeBreakpoint(line, instr);
			// Register new breakpoint
			QString instrline = item->data(Qt::DisplayRole).toString();
			line = 0; instr = 0;
			if (instrline.contains(":")) {
				QStringList parts = instrline.split(":");
				Q_ASSERT(parts.size() == 2);
				line = parts[1].toInt();
				instr = parts[0].toInt();
			} else {
				line = instrline.toInt();
			}
			int skip = item->data(Qt::DisplayRole).toInt();
			emit addBreakpoint(line, instr, skip);
		} else {
            qDebug() << "DebugPanel::cellChanged Other breakpoint types not supported.";
        }
		break;

    default:
    case 1:
        // Do nothing
        break;
    }
}

void DebugPanel::currentCellChanged(int currentRow, int currentColumn, int previousRow, int previousColumn)
{
    Q_UNUSED(previousRow);
    Q_UNUSED(previousColumn);
	QTableWidgetItem *item;
    switch(currentColumn) {
    case 2:
    case 3:
		item = ui->breakpointTableWidget->item(currentRow, currentColumn);
		item->setData(Qt::UserRole, item->text()); // Store old value in UserRole of cell
        break;
    default:
    case 0:
    case 1:
        // Do nothing here
        break;
    }
}

