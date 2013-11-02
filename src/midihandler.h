#ifndef MIDIHANDLER_H
#define MIDIHANDLER_H

#include <QObject>

#include "documentpage.h"

class RtMidiIn;
class RtMidiOut;

class MidiHandler : public QObject
{
    Q_OBJECT
public:
    explicit MidiHandler(QObject *parent = 0);
    void setMidiInterface(int number);
    void openMidiInPort(int port);
    void openMidiOutPort(int port);
    void closeMidiInPort();
    void closeMidiOutPort();

    void addListener(DocumentPage *page);
    void removeListener(DocumentPage *page);
    void setListener(DocumentPage *page); // Unique listener

    void passMidiMessage(std::vector< unsigned char > *message);

signals:

public slots:
private:
	QVector<DocumentPage *> m_listeners;

#ifdef QCS_RTMIDI
	RtMidiIn *m_midiin;
	RtMidiOut *m_midiout;
#endif

};

#endif // MIDIHANDLER_H
