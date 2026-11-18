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

    // Initial values from the saved settings. The controls below bind to these
    // until the user changes them.
    property int initialLayout: 0
    property int initialChannel: 1
    property int initialVelocity: 64
    property int initialOctave: 5
    property bool initialClickPositionVelocity: false

    signal genNote(variant on, variant note, variant channel, variant velocity);
    signal newCCvalue(int channel, int cc, int value)
    signal keyboardSettingsChanged(int layout, int channel, int velocity,
                                   int octave, bool clickPositionVelocity)

    function emitKeyboardSettings() {
        keyboardSettingsChanged(layoutComboBox.currentIndex, controls.channel,
                                controls.velocity, controls.octave,
                                controls.clickPositionVelocity)
    }

    Connections {
        target: controls
        function onChannelChanged() { main.emitKeyboardSettings() }
        function onVelocityChanged() { main.emitKeyboardSettings() }
        function onOctaveChanged() { main.emitKeyboardSettings() }
        function onClickPositionVelocityChanged() { main.emitKeyboardSettings() }
    }

    // Escape returns focus to the piano from any control in this window, so the
    // computer keyboard plays notes again.
    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        onActivated: keyboard.forceActiveFocus()
    }

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
                        // Keep the controls their natural size and left-aligned;
                        // the trailing spacer absorbs extra window width.
                        Layout.preferredWidth: 130
                        Layout.maximumWidth: 130
                        ccNumber: index+1
                        showLabel: index === 0
                        darkMode: windowColor.hslLightness < 0.5
                        onCcValueChanged: function(controller, value) {
                            //console.log("CC:", channel, controller, value)
                            newCCvalue(channel, controller, value)
                        }
                        Keys.forwardTo: keyboard
                    }
                }

                ComboBox {
                    id: layoutComboBox
                    Layout.preferredWidth: 112
                    Layout.maximumWidth: 112
                    Layout.alignment: Qt.AlignVCenter
                    model: [
                        qsTr("US (QWERTY)"),
                        qsTr("FR (AZERTY)"),
                        qsTr("DE (QWERTZ)"),
                        qsTr("ES (QWERTY)"),
                        qsTr("UK (QWERTY)"),
                        qsTr("IT (QWERTY)"),
                        qsTr("CH (QWERTZ)"),
                        qsTr("Nordic (QWERTY)")
                    ]
                    currentIndex: main.initialLayout
                    onCurrentIndexChanged: main.emitKeyboardSettings()
                    Keys.forwardTo: keyboard
                }

                Item { Layout.fillWidth: true }
            }

            Controls {
                id: controls
                Layout.fillWidth: true
                Layout.rightMargin: 10
                Layout.leftMargin: 10
                initialChannel: main.initialChannel
                initialVelocity: main.initialVelocity
                initialOctave: main.initialOctave
                initialClickPositionVelocity: main.initialClickPositionVelocity
                Keys.forwardTo: keyboard;
            }

            Keyboard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                layoutIndex: layoutComboBox.currentIndex
                baseOctave: main.octave
                velocity: controls.velocity
                clickPositionVelocity: controls.clickPositionVelocity
                id: keyboard
                onGenNote: function (on, note, velocity) {
                    main.genNote(on, note + (12*main.octave), main.channel, velocity)
                }
            }
        }
    }
}
