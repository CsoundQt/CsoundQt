#include "midihandler.h"

#ifdef QCS_RTMIDI
#include "RtMidi.h"
#endif

#ifdef QCS_RTMIDI
static void midiInMessageCallback(double deltatime,
								std::vector< unsigned char > *message,
								void *userData)
{
	MidiHandler *midiHandler = (MidiHandler *) userData;
	midiHandler->passMidiMessage(message);
	//  if (nBytes > 0) {
	//    qDebug() << "stamp = " << deltatime;
	//  }
}

#endif


MidiHandler::MidiHandler(QObject *parent) :
    QObject(parent)
{
#ifdef QCS_RTMIDI
	m_midiin = new RtMidiIn(RtMidi::UNSPECIFIED, "CsoundQt");
	m_midiout = new RtMidiOut(RtMidi::UNSPECIFIED, "CsoundQt");
	m_midiin->setCallback(&midiInMessageCallback, this);
#endif
}

void MidiHandler::addListener(DocumentPage *page)
{
	if(!m_listeners.contains(page)) {
		m_listeners.append(page);
	}
}

void MidiHandler::removeListener(DocumentPage *page)
{
	if(!m_listeners.contains(page)) {
		m_listeners.append(page);
	}
}

void MidiHandler::setListener(DocumentPage *page)
{
	m_listeners.clear();
	m_listeners.append(page);
}

void MidiHandler::passMidiMessage(std::vector<unsigned char> *message)
{
	foreach(DocumentPage *page, m_listeners) {
		page->queueMidiIn(message);
	}
}


void MidiHandler::setMidiInterface(int number)
{
	if (number >= 0 && number < 9998) {
		openMidiInPort(number);
	}
	else {
		closeMidiInPort();
	}
}

void MidiHandler::openMidiInPort(int port)
{
#ifdef QCS_RTMIDI
	try {
		closeMidiInPort();
	}
	catch ( RtError &error ) {
		error.printMessage();
	}

	try {
		m_midiin->openPort(port);
	}
	catch ( RtError &error ) {
		qDebug() << "Error opening MIDI port " << port;
		error.printMessage();
		return;
	}
	//  qDebug() << "CsoundQt::openMidiPort opened port " << port;
#endif
	//  m_midiin->ignoreTypes(false, false, false);
}

void MidiHandler::openMidiOutPort(int port)
{
#ifdef QCS_RTMIDI
	try {
		closeMidiOutPort();
	}
	catch ( RtError &error ) {
		error.printMessage();
	}

	try {
		m_midiout->openPort(port);
	}
	catch ( RtError &error ) {
		qDebug() << "Error opening MIDI out port " << port;
		error.printMessage();
		return;
	}
	//  qDebug() << "CsoundQt::openMidiPort opened port " << port;
#endif
	//  m_midiin->ignoreTypes(false, false, false);

}

void MidiHandler::closeMidiInPort()
{
#ifdef QCS_RTMIDI
	m_midiin->closePort();
#endif
}

void MidiHandler::closeMidiOutPort()
{
#ifdef QCS_RTMIDI
	m_midiout->closePort();
#endif
}
