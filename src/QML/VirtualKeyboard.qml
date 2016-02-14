import QtQuick 2.0
import QtQuick.Layouts 1.1

ColumnLayout {
    id: layout
    width: 600
    height: 180
    spacing: 6
    property int octave: controls.octave
    property int channel: controls.channel
    property int velocity: controls.velocity

    signal genNote(variant on, variant note, variant channel, variant velocity);
    signal newCCvalue(int channel, int cc, int value)

    Row {
        spacing: 5
        Repeater {
            model: 3
            ControlSlider {
                width: layout.width/3 //model-2*spacing
                ccNumber: index+1
                onCcValueChanged: {
                    //console.log("CC:", channel, ccNumber, value)
                    newCCvalue(channel, ccNumber, value )
                }
            }
        }
    }

    Controls {
        id: controls
        Layout.fillWidth: true
        anchors.topMargin: 10
    }

    Keyboard {
        Layout.fillWidth: true
        Layout.fillHeight: true
        numOctaves: controls.numOctaves
        onGenNote: {
            layout.genNote(on, note + (12*layout.octave), layout.channel, layout.velocity)
        }
    }
}
