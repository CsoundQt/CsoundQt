#include "aboutwidget.h"
#include "ui_aboutwidget.h"

AboutWidget::AboutWidget(QWidget *parent) :
	QDialog(parent),
	ui(new Ui::AboutWidget)
{
	ui->setupUi(this);
}

AboutWidget::~AboutWidget()
{
	delete ui;
}

void AboutWidget::setIntroText(QString text)
{
	ui->aboutTextEdit->setHtml(text);
}

void AboutWidget::setInstructions(QString text)
{
	ui->instructionsTextEdit->setHtml(text);
}

void AboutWidget::setStyleSheet(QString sheet)
{
	if (!sheet.isEmpty()) {
		ui->aboutTextEdit->setStyleSheet(sheet);
		ui->instructionsTextEdit->setStyleSheet(sheet);
	}
}

void AboutWidget::changeEvent(QEvent *e)
{
	QDialog::changeEvent(e);
	switch (e->type()) {
	case QEvent::LanguageChange:
		ui->retranslateUi(this);
		break;
	default:
		break;
	}
}

