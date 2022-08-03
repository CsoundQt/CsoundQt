import QtQuick 2.15

Rectangle {
    id: root

    property int numOctaves: 2
    property bool latch: false

    signal turnon(real notenum);
    signal turnoff(real notenum);
    signal genNote(variant on, variant note);
    property bool mouseHeld: false

    function indextomidi(notenum) {
        var octave = Math.floor(notenum/7)
        var note = (notenum%7)*2
        if (note > 4) { note--}
        return octave*12 + note
    }

    onTurnon: {
        var midinum = indextomidi(notenum)
        genNote(1, midinum)
        //console.log("TURNON: ", notenum);
    }
    onTurnoff: {
        var midinum = indextomidi(notenum)
        genNote(0, midinum)
    }

    // Set keyboard mapping to play from computer Keyboard
    property var whiteKeys : [Qt.Key_Z, Qt.Key_X,Qt.Key_C,Qt.Key_V,Qt.Key_B,Qt.Key_N,Qt.Key_M, // first octava
        Qt.Key_Q,Qt.Key_W,Qt.Key_E,Qt.Key_R,Qt.Key_T,Qt.Key_Y,Qt.Key_U, Qt.Key_I,Qt.Key_O,Qt.Key_P]; // second and third until E
    property var blackKeys : [ Qt.Key_S,Qt.Key_D,'none',Qt.Key_G,Qt.Key_H,Qt.Key_J,'none', //first
        Qt.Key_2,Qt.Key_3,'none',Qt.Key_5,Qt.Key_6,Qt.Key_7,'none',Qt.Key_9,Qt.Key_0 ]; // sedond and third cis, dis

    function handleKeyEvent(pressed, key) {
        var whiteIndex = whiteKeys.indexOf(key); // -1 if not found;
        var blackIndex = blackKeys.indexOf(key);
        if (whiteIndex>=0) {
            keyDrawer.itemAt(whiteIndex).checked =  pressed;
        }
        if (blackIndex>=0) {
            blackkeyDrawer.itemAt(blackIndex).checked =  pressed;
        }
    }

    focus:true
    Keys.onPressed: {
        if (!event.isAutoRepeat) {
            //console.log("KEYBOARD key down: ", event.key);
            handleKeyEvent(true, event.key);
        }
    }
    Keys.onReleased: {
        if (!event.isAutoRepeat) {
            //console.log("KEYBOARD key up: ", event.key);
            handleKeyEvent(false, event.key);
        }
    }

    Row {
        id: keyRow
        anchors.fill: parent
        property int numKeys: root.numOctaves * 7 + 1
        Repeater {
            id: keyDrawer
            model: keyRow.numKeys
            Key {}
        }
    }
    Row {
        id: blackkeyRow
        anchors.fill: parent
        property int numKeys: root.numOctaves * 7 + 1
        anchors.leftMargin: (2.0/3.0) *root.width/(numKeys)
        spacing: (1.0/3.0) *root.width/(numKeys)
        Repeater {
            id: blackkeyDrawer
            model: blackkeyRow.numKeys
            Key {
                enabled: (index% 7)!=2 && (index% 7)!=6
                width: (2.0/3.0) * root.width/(blackkeyRow.numKeys)
                height: root.height*0.6
                color: enabled ? (!checked ? "black" : "grey"):" transparent"
                border.color: !enabled ? "transparent" :"grey"
                border.width: 0
                blackKey: true
            }
        }
    }
}
