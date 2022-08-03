import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: ccRect
    width: 200
    height: 30

    property int ccNumber: 1

    signal ccValueChanged(int ccNumber, int value);

    Row { // maybe better to do as RowLayout, dynamic sizes
        x: 5
        y: 5
        spacing: 5
        //width: parent.width

        Label {id: ccLabel; text: qsTr("CC"); }
        SpinBox {id: cc;

            from: 1; to: 119; stepSize: 1;
            value: ccNumber;
            width: 55 // to be wide enough for 2 numbers
            onValueChanged: ccNumber = value;
            Keys.forwardTo: ccRect
        }

        Slider {
            id: valueSlider;
            width: ccRect.width - ccLabel.width - cc.width - 25;
            from: 0 ; to: 127; stepSize: 1;
            value: 0
            onValueChanged: ccValueChanged(cc.value, value)
        }
    }
}

