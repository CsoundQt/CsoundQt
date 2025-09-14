import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: controls
    Layout.minimumHeight: channelSpinBox.height

    property int channel: channelSpinBox.value
    property int velocity: velocitySpinBox.value
    property int octave: octaveSpinBox.value
    property int numOctaves: numOctavesSpinBox.value


    RowLayout {
        spacing: 10
        anchors.fill: parent
        Label {
            text: qsTr("Channel")
        }
        SpinBox {
            id: channelSpinBox
            Layout.fillWidth: true
            from: 1
            to: 16
            value: 1
            editable: true
            Keys.forwardTo: controls // to forward them further to keyboard to be able to play wrom computer keys
        }
        Label {
            text: qsTr("Velocity")
        }
        SpinBox {
            id: velocitySpinBox
            Layout.fillWidth: true
            editable: true
            from: 1
            to: 127
            value: 64
            Keys.forwardTo: controls
        }
        Label {
            text: qsTr("Octave")
        }
        SpinBox {
            id: octaveSpinBox
            Layout.fillWidth: true
            editable: true
            from: 0
            to: 12
            value: 5
            Keys.forwardTo: controls
        }
        Label {
            text: qsTr("Num Octaves")
        }
        SpinBox {
            id: numOctavesSpinBox
            Layout.fillWidth: true
            editable: true
            from: 1
            to: 8
            value: 3
            Keys.forwardTo: controls
        }
    }
}
