#ifndef MIDILEARNDIALOG_H
#define MIDILEARNDIALOG_H

#include <QDialog>
#include <QCloseEvent>
#include "qutewidget.h"

namespace Ui {
class MidiLearnDialog;
}

class MidiLearnDialog : public QDialog
{
    Q_OBJECT

public:
    explicit MidiLearnDialog(QWidget *parent = 0);
    ~MidiLearnDialog();

public slots:
    void setMidiController(int channel, int cc);
    void setCurrentWidget(QuteWidget *widget);

protected:
//    virtual void closeEvent(QCloseEvent * event);
private slots:
	void on_setButton_clicked();

	void on_cancelButton_clicked();

	void on_closeButton_clicked();

private:
    Ui::MidiLearnDialog *ui;
    QuteWidget *m_widget;
	int m_cc, m_channel;
};

#endif // MIDILEARNDIALOG_H
