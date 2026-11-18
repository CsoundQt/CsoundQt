import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: ccRect
    width: 200
    height: 40

    property int ccNumber: 1
    // Only the first CC control needs the shared "CC" caption.
    property bool showLabel: true
    // Set by the virtual keyboard: the flat ring track needs a lighter grey on
    // dark backgrounds.
    property bool darkMode: false
    // Colours of the flat knob ring: filled arc and remaining track.
    property string knobColor: "#f57c00"
    property string knobTrackColor: darkMode ? "#43484d" : "#4a2600"

    signal ccValueChanged(int ccNumber, int value);

    // Draw an annular sector (the flat knob's ring segment).
    function drawKnobSector(ctx, cx, cy, inner, outer, start, sweep, color) {
        if (sweep <= 0)
            return;
        const end = start + sweep;
        ctx.beginPath();
        ctx.arc(cx, cy, outer, start, end, false);
        ctx.lineTo(cx + inner * Math.cos(end), cy + inner * Math.sin(end));
        ctx.arc(cx, cy, inner, end, start, true);
        ctx.closePath();
        ctx.fillStyle = color;
        ctx.fill();
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Label {id: ccLabel; text: qsTr("CC"); opacity: ccRect.showLabel ? 1 : 0 }
        SpinBox {id: cc;

            from: 1; to: 119; stepSize: 1;
            value: ccNumber;
            Layout.preferredWidth: 50
            Layout.maximumWidth: 50
            editable: true
            onValueChanged: ccNumber = value;
            Keys.forwardTo: ccRect
        }

        Dial {
            id: valueKnob;
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            from: 0; to: 127; stepSize: 1
            snapMode: Dial.SnapAlways
            inputMode: Dial.Vertical
            live: true
            value: 0
            // Use our own flat ring instead of the platform dial.
            background: Item {}
            handle: Item {}
            onValueChanged: {
                ccValueChanged(cc.value, value)
                knobCanvas.requestPaint()
            }

            Canvas {
                id: knobCanvas
                anchors.fill: parent
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                Connections {
                    target: ccRect
                    function onKnobTrackColorChanged() {
                        knobCanvas.requestPaint()
                    }
                }
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    const cx = width / 2;
                    const cy = height / 2;
                    const outer = Math.min(width, height) / 2 - 1;
                    const inner = outer * 0.67;
                    const start = Math.PI * 0.75; // bottom-left
                    const total = Math.PI * 1.5;  // 270 degrees
                    let fraction = (valueKnob.value - valueKnob.from)
                            / (valueKnob.to - valueKnob.from);
                    fraction = Math.max(0, Math.min(1, fraction));
                    ccRect.drawKnobSector(ctx, cx, cy, inner, outer,
                                          start, total,
                                          ccRect.knobTrackColor);
                    ccRect.drawKnobSector(ctx, cx, cy, inner, outer,
                                          start, total * fraction,
                                          ccRect.knobColor);
                }
            }

            // Keep the current value visible in the middle of the knob.
            Text {
                anchors.centerIn: parent
                text: Math.round(valueKnob.value)
                color: ccLabel.color
                font.pixelSize: 11
            }
        }
    }
}

