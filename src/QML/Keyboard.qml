import QtQuick 2.0

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
    }
    onTurnoff: {
        var midinum = indextomidi(notenum)
        genNote(0, midinum)
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
