#include "debugpanel.h"
#include "ui_debugpanel.h"

#include <QInputDialog>
#include <QModelIndex>
#include <QTableWidget>

DebugPanel::DebugPanel(QWidget *parent) :
    QDockWidget(parent),
    ui(new Ui::DebugPanel)
{
    ui->setupUi(this);

    ui->breakpointTableWidget->setShowGrid(false);

    connect(ui->runButton, SIGNAL(pressed()),
            this, SLOT(run()));
    connect(ui->runButton, SIGNAL(released()),
            this, SLOT(stop()));
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
//    connect(ui->)
}

DebugPanel::~DebugPanel()
{
    delete ui;
}

QVector<double> DebugPanel::breakpoints()
{
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

void DebugPanel::stop()
{
    ui->statusLabel->setText(QString("Debugger stopped"));
    ui->runButton->setChecked(false);
    QTableWidget *table = ui->stackTableWidget;
    table->setRowCount(0);
}

void DebugPanel::run()
{
    emit runSignal();
}

void DebugPanel::pause()
{
    emit pauseSignal();
}

void DebugPanel::continueDebug()
{
    QTableWidget *table = ui->stackTableWidget;
    table->setEnabled(false);
    emit continueSignal();
}

void DebugPanel::next()
{
    emit nextSignal();
}

void DebugPanel::newBreakpoint()
{
    bool ok;
    double d = QInputDialog::getDouble(this, tr("New Instrument Breakpoint"),
                                       tr("Instrument"), 1.0, 1, 9999999, 2, &ok);
    if (ok) {
        int row = ui->breakpointTableWidget->rowCount();
        ui->breakpointTableWidget->insertRow(row);
        QTableWidgetItem *item = new QTableWidgetItem;
        item->setData(Qt::DisplayRole, "instr");
        ui->breakpointTableWidget->setItem(row, 0, item);
        item = new QTableWidgetItem;
        item->setData(Qt::DisplayRole, d);
        ui->breakpointTableWidget->setItem(row, 1, item);
//        QModelIndex i  = ui->breakpointTableWidget->index(row, 0);
//        item  = ui->breakpointTableWidget->item(row, 1);
//        item->setData(Qt::DisplayRole, QVariant(d));
        emit addInstrumentBreakpoint(d);
    }
}

void DebugPanel::deleteBreakpoint()
{
    int row = ui->breakpointTableWidget->currentRow();
    if (row < 0) {
        return;
    }
    if (ui->breakpointTableWidget->item(row, 0)->data(Qt::DisplayRole).toString() == "instr") {
        double d = ui->breakpointTableWidget->item(row, 1)->data(Qt::DisplayRole).toDouble();
        emit removeInstrumentBreakpoint(d);

    }
    ui->breakpointTableWidget->removeRow(row);
}
