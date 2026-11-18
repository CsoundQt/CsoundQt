import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: controls
    Layout.minimumHeight: channelSpinBox.height

    property int initialChannel: 1
    property int initialVelocity: 64
    property int initialOctave: 5
    property bool initialClickPositionVelocity: false

    property int channel: channelSpinBox.value
    property int velocity: velocitySpinBox.value
    property int octave: octaveSpinBox.value
    property bool clickPositionVelocity: clickPositionVelocityCheckBox.checked


    RowLayout {
        spacing: 12
        anchors.fill: parent

        // Each label stays attached to its spin box; the outer spacing only
        // separates the groups.
        RowLayout {
            spacing: 4
            Label {
                text: qsTr("Chan")
            }
            SpinBox {
                id: channelSpinBox
                Layout.preferredWidth: 50
                Layout.maximumWidth: 50
                from: 1
                to: 16
                value: initialChannel
                editable: true
                Keys.forwardTo: controls // to forward them further to keyboard to be able to play wrom computer keys
            }
        }

        RowLayout {
            spacing: 4
            Label {
                text: qsTr("Vel")
            }
            SpinBox {
                id: velocitySpinBox
                Layout.preferredWidth: 50
                Layout.maximumWidth: 50
                editable: true
                from: 1
                to: 127
                value: initialVelocity
                Keys.forwardTo: controls
            }
        }

        RowLayout {
            spacing: 4
            Label {
                text: qsTr("Octave")
            }
            SpinBox {
                id: octaveSpinBox
                Layout.preferredWidth: 50
                Layout.maximumWidth: 50
                editable: true
                from: 0
                to: 12
                value: initialOctave
                Keys.forwardTo: controls
            }
        }

        // Keep the controls left-aligned when the window is widened.
        Item { Layout.fillWidth: true }

        CheckBox {
            id: clickPositionVelocityCheckBox
            text: qsTr("Click→Velocity")
            ToolTip.text: qsTr("The vertical position of the mouse click determines the velocity of the key")
            ToolTip.visible: hovered
            ToolTip.delay: 500
            checked: controls.initialClickPositionVelocity
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Keys.forwardTo: controls
        }
    }
}
