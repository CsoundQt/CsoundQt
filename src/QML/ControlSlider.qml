import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

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
            minimumValue: 1; maximumValue: 119; stepSize: 1;
            value: ccNumber;
            width: 55 // to be wide enough for 2 numbers
            onValueChanged: ccNumber = value;
        }
        Slider {
            id: valueSlider;
            width: ccRect.width - ccLabel.width - cc.width - 25;
            minimumValue: 0 ; maximumValue: 127; stepSize: 1;
            value: 0
            onValueChanged: ccValueChanged(cc.value, value)
        }
    }
}

