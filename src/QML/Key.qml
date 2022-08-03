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

    function mouseOn() {
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

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: key.enabled
        enabled: key.enabled
        onPressed: {
            root.mouseHeld = true
            mouseOn()
        }
        onReleased: {
            root.mouseHeld = false
            if (key.checked) {
                mouseOff()
            }
        }
        onEntered: {
//            console.log("Entered")
            if (root.mouseHeld) {
                mouseOn()
            }
        }
        onExited: {
            if (key.checked) {
                mouseOff()
            }
        }
    }
    onCheckedChanged: {
        var notenum = blackKey ? index + 0.5:index
        if (checked) {
            root.turnon(notenum)
        } else {
            root.turnoff(notenum)
        }
    }
}
