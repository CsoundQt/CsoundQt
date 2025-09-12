import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: main
    width: 600
    height: 180
    color: windowColor


    property int octave: controls.octave
    property int channel: controls.channel
    property int velocity: controls.velocity

    signal genNote(variant on, variant note, variant channel, variant velocity);
    signal newCCvalue(int channel, int cc, int value)

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 6

        Row {
            spacing: 5
            Repeater {
                model: 3

                ControlSlider {
                    width: layout.width/3 //model-2*spacing
                    ccNumber: index+1
                    onCcValueChanged: function(value) {
                        //console.log("CC:", channel, ccNumber, value)
                        newCCvalue(channel, ccNumber, value )
                    }
                    Keys.forwardTo: keyboard
                }
            }
        }

        Controls {
            id: controls
            Layout.fillWidth: true
            anchors.topMargin: 10
            Keys.forwardTo: keyboard;
        }

        Keyboard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            numOctaves: controls.numOctaves
            id: keyboard
            onGenNote: function (on, note) {
                main.genNote(on, note + (12*main.octave), main.channel, main.velocity)
            }
        }
    }
}
