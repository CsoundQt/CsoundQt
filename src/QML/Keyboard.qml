import QtQuick 2.15

Rectangle {
    id: root

    readonly property int minOctaves: 2
    readonly property int maxOctaves: 8
    readonly property int minWhiteKeyWidth: 12
    readonly property int maxWhiteKeyWidth: 26
    property int numOctaves: octavesForWidth(width)
    property bool latch: false
    property int layoutIndex: 0
    property int baseOctave: 5
    property int velocity: 64
    property bool clickPositionVelocity: false

    function octavesForWidth(availableWidth) {
        var count = minOctaves
        while (count < maxOctaves
               && availableWidth / (count * 7 + 1) > maxWhiteKeyWidth) {
            ++count
        }
        while (count > minOctaves
               && availableWidth / (count * 7 + 1) < minWhiteKeyWidth) {
            --count
        }
        return count
    }

    signal turnon(real notenum, int velocity);
    signal turnoff(real notenum);
    signal genNote(variant on, variant note, variant velocity);
    property bool mouseHeld: false

    // Computer-keyboard layouts. The arrays follow the piano-key positions of
    // the US layout; each entry gives the unshifted letter/digit found at the
    // same physical position on that layout. An empty string means unused.
    // White keys: bottom letter row, then top letter row.
    // Black keys: home row, then number row.
    readonly property var layoutDefinitions: [
        { // US American
            white: ["Z","X","C","V","B","N","M",
                    "Q","W","E","R","T","Y","U","I","O","P"],
            black: ["S","D","","G","H","J","",
                    "2","3","","5","6","7","","9","0"]
        },
        { // French
            white: ["W","X","C","V","B","N","M",
                    "A","Z","E","R","T","Y","U","I","O","P"],
            // The unshifted French number row, so the black keys work without
            // having to hold Shift. Labels are shown uppercase.
            black: ["S","D","","G","H","J","",
                    "é","\"","","(","-","è","","ç","à"]
        },
        { // German
            white: ["Y","X","C","V","B","N","M",
                    "Q","W","E","R","T","Z","U","I","O","P"],
            black: ["S","D","","G","H","J","",
                    "2","3","","5","6","7","","9","0"]
        },
        { // Spanish
            white: ["Z","X","C","V","B","N","M",
                    "Q","W","E","R","T","Y","U","I","O","P"],
            black: ["S","D","","G","H","J","",
                    "2","3","","5","6","7","","9","0"]
        },
        { // UK English
            white: ["Z","X","C","V","B","N","M",
                    "Q","W","E","R","T","Y","U","I","O","P"],
            black: ["S","D","","G","H","J","",
                    "2","3","","5","6","7","","9","0"]
        },
        { // Italian
            white: ["Z","X","C","V","B","N","M",
                    "Q","W","E","R","T","Y","U","I","O","P"],
            black: ["S","D","","G","H","J","",
                    "2","3","","5","6","7","","9","0"]
        },
        { // Swiss
            white: ["Y","X","C","V","B","N","M",
                    "Q","W","E","R","T","Z","U","I","O","P"],
            black: ["S","D","","G","H","J","",
                    "2","3","","5","6","7","","9","0"]
        },
        { // Nordic (Swedish/Finnish)
            white: ["Z","X","C","V","B","N","M",
                    "Q","W","E","R","T","Y","U","I","O","P"],
            black: ["S","D","","G","H","J","",
                    "2","3","","5","6","7","","9","0"]
        }
    ]

    readonly property var activeLayout: layoutDefinitions[
        Math.max(0, Math.min(layoutIndex, layoutDefinitions.length - 1))]

    function keyCode(label) {
        if (!label)
            return -1
        var code = label.charCodeAt(0)
        // Qt's letter key codes use the uppercase Latin letter. Other
        // characters (digits, punctuation, accented keys) use their own code.
        if (code >= 97 && code <= 122)
            code -= 32
        return code
    }

    function keyCodes(labels) {
        var codes = []
        for (var i = 0; i < labels.length; ++i)
            codes.push(keyCode(labels[i]))
        return codes
    }

    function velocityAt(y, keyHeight) {
        // Mouse coordinates run from 0 to height - 1 for the inclusive pixel
        // area, so use height - 1 to make the bottommost pixel reach 127.
        var position = Math.max(0, Math.min(1, y / Math.max(1, keyHeight - 1)))
        // Top = 1, bottom = 127; MIDI note velocity is never zero.
        return 1 + Math.round(position * 126)
    }

    property var whiteKeys: keyCodes(activeLayout.white)
    property var blackKeys: keyCodes(activeLayout.black)

    function indextomidi(notenum) {
        var octave = Math.floor(notenum/7)
        var note = (notenum%7)*2
        if (note > 4) { note--}
        return octave*12 + note
    }

    onTurnon: function (notenum, velocity) {
        var midinum = indextomidi(notenum)
        genNote(1, midinum, velocity)
        //console.log("TURNON: ", notenum);
    }
    onTurnoff: function (notenum) {
        var midinum = indextomidi(notenum)
        genNote(0, midinum, 0)
    }

    // Set keyboard mapping to play from computer Keyboard. The arrays above
    // provide the layout-specific key codes and labels.

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
    Keys.onPressed: function (event) {
        if (!event.isAutoRepeat) {
            //console.log("KEYBOARD key down: ", event.key);
            handleKeyEvent(true, event.key);
        }
    }
    Keys.onReleased: function(event) {
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
            Key {
                label: root.activeLayout.white[index] || ""
                // Show the MIDI note number above every visible C key.
                midiNumber: root.baseOctave * 12 + Math.floor(index / 7) * 12
                showMidiNumber: index % 7 === 0
            }
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
                label: root.activeLayout.black[index] || ""
            }
        }
    }
}
