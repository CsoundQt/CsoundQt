import QtQuick 2.0
import QtQuick.Controls 2.1 // requires Qt 5.7 or higher


Rectangle {
    width: 600; height: 400;
    anchors.fill: parent
    color: "lightgrey"

    Slider {
        x: 5; y:5 ;
        width: 100; //height: 10;

    }

    Button {
        x: 146; y: 10
        width: 100
        height:  30
        text: "Press"
        checkable: true
        onCheckedChanged: console.log(checked)
    }

    Dial {
        x: 289
        y: 20
        width: 81
        height: 86
        from: 0
        to: 2
        onValueChanged: console.log("Value:" + value)
        onPositionChanged: {
            var v = from + position*(to-from)
            dialvalue.text = v.toFixed(4)
        }

    }

    Label {
        id: dialvalue
        x: 312
        y: 112
        text: qsTr("0")
        font.pointSize: 24
    }

    SpinBox {
        id: spinbox
            from: 0
            value: 110
            to: 100 * 100
            stepSize: 1
            anchors.centerIn: parent

            property int decimals: 2
            property real realValue: value / 100

            validator: DoubleValidator {
                bottom: Math.min(spinbox.from, spinbox.to)
                top:  Math.max(spinbox.from, spinbox.to)
            }

            textFromValue: function(value, locale) {
                return Number(value / 100).toLocaleString(locale, 'f', spinbox.decimals)
            }

            valueFromText: function(text, locale) {
                return Number.fromLocaleString(locale, text) * 100
            }
    }



}
