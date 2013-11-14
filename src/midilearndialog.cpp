#include "midilearndialog.h"
#include "ui_midilearndialog.h"

#include <QDebug>

MidiLearnDialog::MidiLearnDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::MidiLearnDialog)
{
    ui->setupUi(this);
    m_widget = 0;
}

MidiLearnDialog::~MidiLearnDialog()
{
    delete ui;
}

void MidiLearnDialog::setCurrentWidget(QuteWidget *widget)
{
    m_widget = widget;
    if (widget) {
        if (widget->acceptsMidi()) {
            int cc = m_widget->property("QCS_midicc").toInt();
            int channel = m_widget->property("QCS_midichan").toInt();
            if (channel <= 0) {
                ui->channelLabel->setText(QString::number(channel));
                ui->ccLabel->setText(QString::number(cc));
            } else {
                ui->channelLabel->setText(tr("(None)"));
                ui->ccLabel->setText(tr("(None)"));
            }
        } else {
            ui->channelLabel->setText(tr("(No MIDI)"));
            ui->ccLabel->setText(tr("(No MIDI)"));
        }
        qDebug() << "MidiLearnDialog::setCurrentWidget";
    } else {
            ui->channelLabel->setText(tr("(None)"));
            ui->ccLabel->setText(tr("(None)"));
    }
}

//void MidiLearnDialog::closeEvent(QCloseEvent *event)
//{
//    qDebug() << "MIDI learn closed";

//}

void MidiLearnDialog::setMidiController(int channel, int cc)
{
    if (this->isVisible()) {
        ui->channelLabel->setText(QString::number(channel));
        ui->ccLabel->setText(QString::number(cc));
        if (m_widget && m_widget->acceptsMidi()) {
            m_widget->setProperty("QCS_midicc", cc);
            m_widget->setProperty("QCS_midichan", channel);
            m_widget->applyInternalProperties();
            m_widget->markChanged();
        }
    }
}
