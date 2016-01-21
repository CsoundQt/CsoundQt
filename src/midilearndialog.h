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
private:
    Ui::MidiLearnDialog *ui;
    QuteWidget *m_widget;
};

#endif // MIDILEARNDIALOG_H
