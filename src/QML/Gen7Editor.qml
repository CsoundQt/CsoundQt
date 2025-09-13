//qmlTableEditor - helps to graphically create and change Csound Gen7 (straigt lines) type of tables
// (c) Tarmo Johannes 2015 tarmo@otsakool.edu.ee
//Licence: GPL 2

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Dialogs

Rectangle {
    id: gen7Editor
    width: 720
    height: 550
    color: tableEditor.color
    //anchors.fill: parent
    property string name: "gen7"  // important! to let parent know which editor is active in tabView
    property var points: []; // array of endpoints of the segments
    property int pointWidth: 10; // set constant
    property real currentIndex: 0
    property real currentValue: 0


    Item {id: mainArea; anchors.fill: parent}


    function insertPoint(x,y) { // finds right place in the array (sorted by x), insert into array and creates the object
        var index = -1;
        for (var i=1;i<points.length;i++) { // find right index
            if (x>=points[i-1].x && x<=points[i].x ) {
                index = i;
                break;
            }

        }
        if (index!=-1) {
            points.splice(index,0, pointComponent.createObject(drawRect, { "x" : x, "y": y , "index": x2index(x+pointWidth/2), "value" : y2value(y+pointWidth/2) })); // create new point objet
            canvas.requestPaint();
        }

    }

    function getMinimumX(index) { // to not let a point pass its neighbour
        var minX = -1
        if (index===0)
            minX = 0;
        else if (index===points.length-1)
            minX = drawRect.width-pointWidth/2;
        else if (index>0)
            minX = points[index-1].x;
        return minX;
    }

    function getMaximumX(index) { // to not let a point pass its neighbour
        var maxX = -1
        if (index===0)
            maxX = 0;
        else if (index===points.length-1)
            maxX = drawRect.width-pointWidth/2;
        else if (index>0)
            maxX = points[index+1].x;
        //console.log("point no, minx ",index,maxX);
        return maxX;
    }

    function x2index(x) { // converts the x-coordinate to index of the table
        var tabIndex =  (x-pointWidth/2) / (drawRect.width-pointWidth/2); // * tableSizeSpinbox.value) ; // store as 0..1
        //console.log("x, index: ",x,tabIndex);
        return tabIndex;
    }

    function y2value(y) { // converts the y-coordinate to 0..1
        //first 0..maxvalue
        var value =  (1 - (y) / (drawRect.height)) //* maxSpinbox.value ; // store as 0..1
        return value;
    }

    function scaleValue(value) { // converts value 0..1 into 0..max or -max..max if bipolar graph
        return (bipolar.checked) ?  2*value*maxSpinbox.value - maxSpinbox.value: value*maxSpinbox.value;
    }

    function graph2syntax() { // returns table syntax as string according to defined points
        // get first parts from already existing text in Textarea (since may be changed by hand)
        var name = syntaxField.text.split("ftgen")[0]; // table name before "ftgen"
        var parameters = syntaxField.text.split("ftgen")[1].replace("ftgen ","").trim().split(",");

        var syntax = name + "ftgen " + parameters[0]
                + "," + parameters[1] + ","   +  + tableSizeSpinbox.value.toString()+", 7, ";

        var checksum = 0;
        for (var i=0;i<points.length-1;i++) {

            var value = scaleValue(points[i].value);
            var sectionLength = (points[i+1].index - points[i].index)*tableSizeSpinbox.value; // if the tableLength is set to 1, leave decimal values, don't round
            if (tableSizeSpinbox.value>=2) {
                sectionLength = Math.round(sectionLength); // otherwise round to integer values;
            }

            checksum += sectionLength;
            syntax += value.toFixed(6) + ", "+ sectionLength.toString() + ", "; // TODO function  scaleValue () - returns stored value in 0..1 into 0..max or -max..max
        }
        syntax +=  (scaleValue( points[points.length-1].value)).toFixed(6); // add the last value
        syntaxField.text = syntax;
        return syntax;
    }

    function syntax2graph(syntax, maxValue) { // if second argument not given, find max from data
        var parameters = syntax.split("ftgen")[1].replace("ftgen ","").trim().split(","); // parameters after ftgen to array
        var size = parseInt(parameters[2]);
        tableSizeSpinbox.value = size;

        // separate values and sizes of segments into arrays
        var values = [];
        var segments = [];
        var containsNegative = false;
        var max = 0;
        for (var i=4;i<parameters.length;i++) {
            var val = parseFloat(parameters[i]);
            if (val<0) {
                containsNegative = true ; // to be able to scale correctly later
                bipolar.checked = true;
            }
            values[values.length] = val;
            if (Math.abs(val) > max)
                max = Math.abs(val);
            if (i<parameters.length-1)  { // don't find it after last value
                segments[segments.length] = parseInt(parameters[i+1]);
                ++i;
            }
        }

        maxValue = Math.max(max, maxValue)
        for (i=0; i<values.length;i++) {
            values[i] /= maxValue; // to scale 0..1
        }


        if (bipolar.checked )
            for (var k=0; k<values.length;k++) {
                values[k] = values[k]/2.0+0.5; // to scale 0..1
            }

        maxSpinbox.value = maxValue;

        // create points
        // first delete old ones and clear array:
        while (points.length>0) {
            var point = points.pop();
            point.destroy();
        }
        var sum = 0, index=0;
        for (var j=0;j<values.length;j++) { // set only values and indexes, later update point positions and redraw
            if (j==values.length-1)
                index = 1
            else
                index = (sum+0.0) / (size+0.0);
            //console.log("j,index, sum, value: ",j,index, sum ,values[j])
            if (j<values.length-1) // the array of segments is shorter that the one with values
                sum += segments[j];

            points[j] = pointComponent.createObject(drawRect, { "x" : 0, "y":0, "index":index, "value":values[j] }); // value = 0.5 since bipolar view in the begining

        }
        drawRect.updatePointPositions();
    }

    function clear() {
        while (points.length>0) {
            var point = points.pop();
            point.destroy();
        }
        points[0] = pointComponent.createObject(drawRect, { "x" : 0, "y":0, "index":0, "value":0.5 });
        points[1] = pointComponent.createObject(drawRect, { "x" :0, "y":0, "index":1,"value":1});
        maxSpinbox.value = 1;
        tableSizeSpinbox.value = 1024;
        bipolar.checked = true;
        syntaxField.text = "giTable ftgen 0,0,1024, 7, 0.000000, 1024, 1.000000";
        drawRect.updatePointPositions();
    }


    Component {
        id: pointComponent  // create points on the grpah dynamically

        Rectangle {
            id:pointRect
            width: pointWidth; height: width
            color: (pointArea.containsMouse || pointArea.drag.active )?  "blue" : "red"
            radius: width/2
            property real value: 0
            property real index:0


            MouseArea {
                id: pointArea
                anchors.fill: parent
                acceptedButtons:  Qt.LeftButton | Qt.RightButton
                hoverEnabled:  true
                drag.target: parent

                drag.minimumX: -width/2
                drag.maximumX: drawRect.width - width/2
                drag.minimumY: -height/2
                drag.maximumY: drawRect.height - height/2

                onPressed:
                    if (pressedButtons & Qt.RightButton) {
                        var index = points.indexOf(parent);

                        points.splice(index,1)
                        parent.destroy()
                        valueRect.visible = false;
                        canvas.requestPaint();

                    }

                drag.onActiveChanged: { //to detect dragEnd and dragFihised - not fired if not in automiatic mode
                    valueRect.visible  = drag.active
                    if (!drag.active) {
                        parent.index =  x2index(parent.x+pointWidth/2)
                        parent.value = y2value(parent.y+pointWidth/2)
                        graph2syntax()
                    }
                }

                onHoveredChanged: {
                    currentValue = y2value(parent.y + pointWidth/2);
                    currentIndex = x2index(parent.x + pointWidth/2);
                    valueRect.x = parent.x-valueRect.width/2;
                    valueRect.y = parent.y-valueRect.height-10;
                    valueRect.y = Math.max(-drawRect.y +2, valueRect.y)
                    valueRect.visible = containsMouse || drag.active;
                }
            }


            onXChanged: {
                var index =  points.indexOf(this);
                if (index!=-1)
                    pointArea.drag.minimumX = getMinimumX(index);
                if (index!=-1)
                    pointArea.drag.maximumX = getMaximumX(index);
                canvas.requestPaint();

                currentIndex = x2index(this.x+pointWidth/2); // pointWidth/2 since the center of the point marker is the desired point
                valueRect.x = x-valueRect.width/2
            }
            onYChanged: {
                canvas.requestPaint();
                currentValue = y2value(y+pointWidth/2);
                valueRect.y = y-valueRect.height-10;
                valueRect.y = Math.max(-drawRect.y +2, valueRect.y) // not to show outside of window
            }
        }

    }


    Rectangle {
        id: drawRect
        width: parent.width - 200
        height: parent.height - 250
        color:  tableEditor.color.lighter() //"#ffffff"
        anchors.horizontalCenter: parent.horizontalCenter
        y: valueRect.height + 5
        z: 1
        function updatePointPositions() {
            for (var i = 0; i < points.length; i++) {
                points[i].x = points[i].index * (drawRect.width - pointWidth/2);
                points[i].y = (1 - points[i].value) * drawRect.height - pointWidth/2;
            }

            canvas.requestPaint();
        }

        Component.onCompleted: {
            points[0] = pointComponent.createObject(drawRect, { 
                "x": 0, 
                "y": height*0.5 - pointWidth/2, 
                "index": 0, 
                "value": 0.5 
            });
            points[1] = pointComponent.createObject(drawRect, { 
                "x": width - pointWidth/2, 
                "y": 0 - pointWidth/2, 
                "index": 1, 
                "value": 1 
            });
            canvas.requestPaint();
        }

        onWidthChanged: updatePointPositions();
        onHeightChanged:updatePointPositions();

        Rectangle { // displays
            id:valueRect
            width: 150
            height: 50
            z:1
            opacity: 0.8
            color: "#fbfcba"
            radius: 4
            visible: false
            border.width: 1
            border.color: "black"


            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                // use Text here not label, as its color will not be inverten when dark mode
                Text { text: qsTr("Value: ")+(scaleValue(currentValue)).toFixed(3)}
                Text {
                    text: qsTr("Index: ")+  ( (tableSizeSpinbox.value>=2) ? (Math.round(currentIndex*tableSizeSpinbox.value)).toString() : currentIndex.toFixed(6) )   // if table lenght set to 1, so also decimal values, don't scale
                }
            }

        }

        MouseArea {
            anchors.fill: parent
            onDoubleClicked: function(mouse) {
                insertPoint(mouse.x,mouse.y);
                graph2syntax()
            }
        }



        Canvas {
            id:canvas
            anchors.fill: parent
            renderTarget: Canvas.Image  // for easier rendering
            renderStrategy: Canvas.Cooperative  // optimization

            onPaint: {
                var context = canvas.getContext('2d');
                context.reset();
                context.clearRect(0, 0, width, height);
                
                // style
                context.strokeStyle = "black";
                context.lineWidth = 1;  // Тонкие линии
                context.font = "12px sans-serif";
                context.textBaseline = "top";
                
                // axes
                context.beginPath();
                
                context.moveTo(pointWidth/2, 0);
                context.lineTo(pointWidth/2, height);
                
                // x-axes
                var y0 = bipolar.checked ? height/2 : height - 1;
                context.moveTo(0, y0);
                context.lineTo(width, y0);
                
                context.stroke();
                
                context.fillStyle = "black";
                context.fillText(maxSpinbox.value.toFixed(2), 15, 5);
                context.fillText("0", 15, y0 - 15);
                
                if (bipolar.checked) {
                    context.fillText((-maxSpinbox.value).toFixed(2), 15, height - 15);
                }
                
                // graph lines
                if (points.length > 0) {
                    context.beginPath();
                    context.strokeStyle = "red";
                    context.lineWidth = 1.5;
                    var offset = points[0].width / 2;
                    
                    context.moveTo(points[0].x + offset, points[0].y + offset);
                    for (var i = 1; i < points.length; i++) {
                        context.lineTo(points[i].x + offset, points[i].y + offset);
                    }
                    context.stroke();
                }
            }
        }




    }

    Label {
        visible: false
        id: tipLAbel
        x: 271
        y: 74
        text: qsTr("Double-click to add, right-click to remove point")
        anchors.bottom: drawRect.top
        anchors.bottomMargin: 6
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Label {
        id: maxLabel
        anchors.left: maxSpinbox.left
        anchors.bottom: maxSpinbox.top
        anchors.bottomMargin: 5
        text: qsTr("Max value:")
    }

    SpinBox {
        id: maxSpinbox
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.right: drawRect.left
        anchors.rightMargin: 6
        anchors.top: drawRect.top
        anchors.topMargin: 0
        from: 1
        value: 1
        to: 9999999
        editable: true
        onValueChanged: {canvas.requestPaint(); graph2syntax() }// to display new max number
    }

    CheckBox {
        text: qsTr("Bipolar:")
        id: bipolar
        checked: true
        anchors.left: maxSpinbox.left
        anchors.top: maxSpinbox.bottom
        anchors.topMargin: 5
        onCheckedChanged: { canvas.requestPaint() ; graph2syntax()}
    }


    Button {
        id: syntax2graphButton
        text: qsTr("&Update graph")
        anchors.left: drawRect.left
        anchors.top: syntaxRadioButtons.bottom
        anchors.topMargin: 6

        onClicked: syntax2graph(syntaxField.text, maxSpinbox.value)
    }




    TextArea {
        id: syntaxField
        objectName: "syntaxField" // to reach it fro C++
        anchors.left: syntax2graphButton.right
        anchors.leftMargin: 6
        anchors.right: drawRect.right
        anchors.top: syntax2graphButton.top
        anchors.bottom:  mainArea.bottom
        anchors.bottomMargin: 10 // has no influence in some reason

        readOnly: false
        font.family: "Courier New"
        font.pixelSize: 10
        wrapMode: TextArea.Wrap

        text: "giTable ftgen 0,0,1024, 7, 0.000000, 1024, 1.000000" // corresponds to the default position of points
        Keys.onReturnPressed: syntax2graph(syntaxField.text, maxSpinbox.value)

    }


    SpinBox {
        id: tableSizeSpinbox
        value: 1024
        from: 1
        to: 99999
        anchors.right: mainArea.right
        anchors.rightMargin: 10
        anchors.top: drawRect.bottom
        anchors.topMargin: 2
        editable: true
        onValueChanged: {canvas.requestPaint(); graph2syntax() }// to display new max number
    }

    Label {
        id: tableSizeLabel
        height: 22
        text: qsTr("Table size")
        anchors.right: tableSizeSpinbox.left
        anchors.rightMargin: 2
        anchors.verticalCenter: tableSizeSpinbox.verticalCenter
    }

    ButtonGroup { id: syntaxTypeGroup; }

    Row {
        id: syntaxRadioButtons


        width: drawRect.width
        anchors.left: drawRect.left
        anchors.leftMargin: 0
        anchors.top: drawRect.bottom
        anchors.topMargin: 6
        spacing: 5

        Label {text: qsTr("Syntax type: ")}


        RadioButton {
            id: ftgenButton
            text: qsTr("ftgen")
            checked: true
            ButtonGroup.group: syntaxTypeGroup
        }

        RadioButton {
            id: fbutton
            text: qsTr("f statement")
            enabled: false
            ButtonGroup.group: syntaxTypeGroup
        }



    }

    Button {
        id: clearButton
        anchors.left: drawRect.left
        anchors.top: syntax2graphButton.bottom
        anchors.topMargin: 6
        text: qsTr("&Clear")
        onClicked:clear()
    }

    Button {
        id: helpButton
        anchors.right: mainArea.right
        anchors.rightMargin: 10
        anchors.top: mainArea.top
        anchors.topMargin: 10
        text: qsTr("&Help")
        onClicked:helpDialog.visible = true;
    }

    Dialog {
        id: helpDialog
        width: parent.width*0.8
        title: qsTr("Help")
        visible: false


        contentItem: TextEdit {
            wrapMode: TextArea.Wrap
            text: qsTr("Double-click to add a new point.\nDrag to move, right-click to remove\nYou can edit the table definition in textarea. \nThe changes in definition are displayed when you press ENTER or click on button Update Graph\n");
        }
        standardButtons: Dialog.Ok
        onAccepted: visible=false;
    }

}
