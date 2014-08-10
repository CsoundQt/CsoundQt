#ifndef NEWBREAKPOINTDIALOG_H
#define NEWBREAKPOINTDIALOG_H

#include <QDialog>

namespace Ui {
class NewBreakpointDialog;
}

class NewBreakpointDialog : public QDialog
{
	Q_OBJECT

public:
	explicit NewBreakpointDialog(QWidget *parent = 0);
	~NewBreakpointDialog();

	QString type;
	QString instrline;
	double instr;
	int line;
	int skip;

public slots:
	virtual void accept();

private:
	Ui::NewBreakpointDialog *ui;
};

#endif // NEWBREAKPOINTDIALOG_H
