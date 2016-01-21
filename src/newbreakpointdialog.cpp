#include "newbreakpointdialog.h"
#include "ui_newbreakpointdialog.h"

#include <QDebug>

NewBreakpointDialog::NewBreakpointDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::NewBreakpointDialog)
{
	ui->setupUi(this);
}

NewBreakpointDialog::~NewBreakpointDialog()
{
	delete ui;
}

void NewBreakpointDialog::accept()
{
	type = ui->typeComboBox->currentIndex() == 0 ? "instr" : "line";
	instr = ui->instrumentSpinBox->value();
	line = ui->lineSpinBox->value();
	if (type == "instr") {
		instrline = QString::number(instr);
	} else {
		instrline = QString("%1:%2").arg(int(instr)).arg(line);
	}
	skip = ui->skipSpinBox->value();
	QDialog::accept();
}

