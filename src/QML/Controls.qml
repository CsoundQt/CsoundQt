import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

Rectangle {
    property int channel: channelSpinBox.value
    property int velocity: velocitySpinBox.value
    property int octave: octaveSpinBox.value
    property int numOctaves: numOctavesSpinBox.value
    id: controls
    Layout.minimumHeight: channelSpinBox.height
    RowLayout {
        spacing: 10
        anchors.fill: parent
        Text {
            text: qsTr("Channel")
        }
        SpinBox {
            id: channelSpinBox
            Layout.fillWidth: true
            decimals: 0
            maximumValue: 16
            minimumValue: 1
            value: 1
            Keys.forwardTo: controls // to forward them further to keyboard to be able to play wrom computer keys
        }
        Text {
            text: qsTr("Velocity")
        }
        SpinBox {
            id: velocitySpinBox
            Layout.fillWidth: true
            decimals: 0
            maximumValue: 127
            minimumValue: 1
            value: 64
            Keys.forwardTo: controls
        }
        Text {
            text: qsTr("Octave")
        }
        SpinBox {
            id: octaveSpinBox
            Layout.fillWidth: true
            decimals: 0
            maximumValue: 12
            minimumValue: 0
            value: 5
            Keys.forwardTo: controls
        }
        Text {
            text: qsTr("Num Octaves")
        }
        SpinBox {
            id: numOctavesSpinBox
            Layout.fillWidth: true
            decimals: 0
            maximumValue: 8
            minimumValue: 1
            value: 3
            Keys.forwardTo: controls
        }
    }
}
