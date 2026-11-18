import QtQuick 2.15

Rectangle {
    id: key

    width: root.width/numkeys
    height: root.height
    radius: 1;
    color: !checked ? "white" : "gray"
    border.color: "black"
    border.width: 1

    property bool checked: false
    property bool enabled: true
    property bool blackKey: false
    property int numkeys: root.numOctaves * 7 + 1
    property string label: ""
    property int noteVelocity: root.velocity
    property bool showMidiNumber: false
    property int midiNumber: 0
    // True when a Shift-click left the key on. Such a key is sustained and is
    // not switched off by leaving the key with the mouse.
    property bool sustained: false

    function mouseOn(velocity) {
        key.noteVelocity = velocity
        if (!root.latch) {
            key.checked = !key.checked
        } else {
           key.checked = key.checked
        }
    }

    function mouseOff() {
        if (!root.latch) {
           key.checked = !key.checked
        }
    }

    // Faint computer-key label on the key surface.
    Text {
        id: keyLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: key.blackKey ? 3 : 4
        text: key.label.toUpperCase()
        visible: text !== ""
        color: "#808080"
        opacity: key.blackKey ? 0.95 : 0.65
        font.pixelSize: 11
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: keyLabel.top
        text: key.midiNumber
        visible: key.showMidiNumber
        color: "#808080"
        opacity: 0.75
        font.pixelSize: 8
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: key.enabled
        enabled: key.enabled
        onPressed: function(mouse) {
            // Typing must go to the piano after any mouse interaction, even if
            // a spin box or knob had focus before the click.
            root.forceActiveFocus()
            root.mouseHeld = true
            var velocity = root.velocity
            if (root.clickPositionVelocity)
                velocity = root.velocityAt(mouse.y, key.height)
            if (mouse.modifiers & Qt.ShiftModifier) {
                // Shift-click toggles a sustained note: it stays on after the
                // mouse is released and moved away. Shift-clicking it again
                // turns it off.
                key.noteVelocity = velocity
                key.checked = !key.checked
                key.sustained = key.checked
            } else {
                // A normal click is momentary; it also takes an already
                // sustained key out of its sustained state.
                key.sustained = false
                mouseOn(velocity)
            }
        }
        onReleased: {
            root.mouseHeld = false
            if (key.sustained)
                return
            if (key.checked) {
                mouseOff()
            }
        }
        onEntered: {
//            console.log("Entered")
            if (root.mouseHeld && !key.sustained) {
                mouseOn(root.velocity)
            }
        }
        onExited: {
            if (key.checked && !key.sustained) {
                mouseOff()
            }
        }
    }
    onCheckedChanged: {
        var notenum = blackKey ? index + 0.5:index
        if (checked) {
            root.turnon(notenum, noteVelocity)
        } else {
            root.turnoff(notenum)
        }
    }
}
