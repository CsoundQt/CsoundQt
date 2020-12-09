'''
Quickly generate widget layouts
in CsoundQt with Python
v 0.2.1

Luís Salgueiro
May 2020
'''

import PythonQt.QtGui as pqt

# default layout values
default_size = 80
gutter = 20
width = default_size + gutter
y = 0

knobs = []
knobs_labels = []
knobs_readout = []

faders = []
faders_labels = []
faders_readout = []

solo = []
mute = []
rec = []


def invalue(name):
    '''
    Inserts an invalue opcode at the cursor position.
    '''
    invalue = 'k%s invalue "%s"\n' % (name, name)
    return q.insertText(invalue)


def knob(x, y):
    '''
    Generates a knob, accompanied by a label and a readout SpinBox. Inserts an invalue at the cursor position.
    Argument x refers not to an absolute x position, but to a column of size w (cf. class constructor).
    '''
    label_y = y
    knob_y = label_y + 20
    readout_y = y + default_size + gutter  # get property instead?

    # convert x_offset to centered property
    knobLabel = q.createNewLabel(width * x + 5, label_y, "" + str(x + 1))
    knobs_labels.append(knobLabel)

    name = "knob" + str(x + 1)
    newKnob = q.createNewKnob(width * x, knob_y, name)
    knobs.append(newKnob)
    invalue(name)

    knobReadout = q.createNewSpinBox(width * x + 5, readout_y, name)
    knobs_readout.append(knobReadout)


def fader(x, y):
    '''
    Generates a fader, accompanied by a label and a readout SpinBox.
    Argument x refers not to an absolute x position, but to a column of size w (cf. class constructor).
    '''
    label_y = y
    fader_y = label_y + 20
    readout_y = fader_y + 100  # get property instead?

    faderLabel = q.createNewLabel(width * x + 5, label_y, "" + str(x + 1))
    faders_labels.append(faderLabel)

    name = "fader" + str(x + 1)
    newFader = q.createNewSlider(width * x + 50, fader_y, name)
    faders.append(newFader)
    invalue(name)

    faderReadout = q.createNewSpinBox(width * x + 5, readout_y, name)
    faders_readout.append(faderReadout)


def buttons(x, y):
    '''
    Generates a group of three buttons, labelled Solo, Mute and Rec.
    Argument x refers not to an absolute x position, but to a column of size w (cf. class constructor).
    '''
    solo_y = y
    mute_y = solo_y + gutter
    rec_y = mute_y + gutter  # get property instead?

    solo_name = "solo" + str(x + 1)
    newSolo = q.createNewButton(100 * x, solo_y, solo_name)
    solo.append(newSolo)
    invalue(solo_name)

    mute_name = "mute" + str(x + 1)
    newMute = q.createNewButton(100 * x, mute_y, mute_name)
    mute.append(newMute)
    invalue(mute_name)

    rec_name = "rec" + str(x + 1)
    newRec = q.createNewButton(100 * x, rec_y, rec_name)
    rec.append(newRec)
    invalue(rec_name)


def column(x, y):
    '''
    Generates a mixer channel-like column of widgets, comprising a knob, fader, and button group, arranged vertically.
    Argument x refers not to an absolute x position, but to a column of size w (cf. class constructor).
    '''
    knob(x, y)

    fader_y = y + width + (gutter * 1.5)
    fader(x, fader_y)

    buttons_y = y + 280  # ToDo
    buttons(x, buttons_y)


def strip():
    '''
    Generates a set of channel strips by iterating the column function.
    ToDo: manual trash collection, deleting the objects stored in the arrays, so the script properly keeps track of the objects it created.
    '''
    # starts the layout afresh; comment out this for-loop to keep widgets
    for widget in q.getWidgetUuids():
        q.destroyWidget(widget)

    for x in range(strip_spinbox.value):
        column(x, y)

    if strip_spinbox.value == 0:
        pass
    elif strip_spinbox.value == 1:
        print('Created %d channel strip!' % strip_spinbox.value)
    else:
        print('Created %d channel strips!' % strip_spinbox.value)


# Qt interface
w = pqt.QWidget()
w.setGeometry(50, 50, 400, 400)
layout = pqt.QGridLayout(w)
w.setLayout(layout)
w.setWindowTitle("Generate widgets")

#title
text = pqt.QTextBrowser(w)
layout.addWidget(text, 2, 2)
text.setText(
    '''This script generates a number of widgets arranged as channel strips, composed of a knob, a slider, and a group of Solo, Mute, and Record Arm buttons, while creating the appropriate software channels in the code at the current cursor position.



 
Quickly generate widget layouts
in CsoundQt with Python
v 0.2.1

Luís Salgueiro
May 2020
''')

# generate Channel strips
strip_label = pqt.QLabel('Generate... :')
layout.addWidget(strip_label, 1, 0)

strip_spinbox = pqt.QSpinBox(w)
strip_spinbox.setRange(0, 99)
layout.addWidget(strip_spinbox, 1, 1)

strip_button = pqt.QPushButton("Channel strips", w)
layout.addWidget(strip_button, 1, 2)
strip_button.connect("clicked()", strip)

# pack window
w.show()
