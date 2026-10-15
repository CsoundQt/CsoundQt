import QtQuick 2.15
import QtQuick.Controls 2.15
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

    // A Pane carrying the application palette. Qt Quick Controls do not pick up
    // the application palette themselves, so without this their text stays black
    // (unreadable on a dark background). Child controls inherit this palette.
    Pane {
        anchors.fill: parent
        padding: 0
        palette.window: windowColor
        palette.windowText: windowTextColor
        palette.text: textColor
        palette.base: baseColor
        palette.button: buttonColor
        palette.buttonText: buttonTextColor
        palette.highlight: highlightColor
        palette.highlightedText: highlightedTextColor

        ColumnLayout {
            id: layout
            anchors.fill: parent
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                Layout.rightMargin: 10
                Layout.leftMargin: 5
                spacing: 5
                Repeater {
                    model: 3

                    ControlSlider {
                        //Layout.preferredWidth: layout.width/3 - 10 //model-2*spacing
                        Layout.fillWidth: true
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
                Layout.rightMargin: 10
                Layout.leftMargin: 10
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
}
