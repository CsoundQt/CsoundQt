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
    }

}
