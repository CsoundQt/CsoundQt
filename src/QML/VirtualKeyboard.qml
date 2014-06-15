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
