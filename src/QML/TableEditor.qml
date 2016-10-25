//qmlTableEditor - helps to graphically create and change Csound Gen7 (straigt lines) type of tables
// (c) Tarmo Johannes 2015 tarmo@otsakool.edu.ee
//Licence: GPL 2

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.1

Rectangle {
    id: mainWindow
    width: 720
    height: 500
    // TODO: resize to parent window
    //minimumWidth: 640 // TODO - find good values
    //minimumHeight: 440
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
        //console.log("New index: ",index);
        if (index!=-1) {
            points.splice(index,0, pointComponent.createObject(drawRect, { "x" : x, "y": y , "index": x2index(x+pointWidth/2), "value" : y2value(y+pointWidth/2) })); // create new point objet
            canvas.requestPaint();
        }

    }

    function getMinimumX(index) { // to not let a point pass its neighbour
        var minX = -1
        if (index==0)
            minX = 0;
        else if (index===points.length-1)
            minX = drawRect.width-pointWidth/2;
        else if (index>0)
            minX = points[index-1].x;
        //console.log("point no, minx ",index,minX);
        return minX;
    }

    function getMaximumX(index) { // to not let a point pass its neighbour
        var maxX = -1
        if (index==0)
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
        //console.log("name,parameters:",name, parameters)

        var syntax = name + "ftgen " + parameters[0]
                + "," + parameters[1] + ","   +  + tableSizeSpinbox.value.toString()+", 7, ";

        var checksum = 0;
        for (var i=0;i<points.length-1;i++) {

            var value = scaleValue(points[i].value);
            var sectionLength = Math.round((points[i+1].index - points[i].index)*tableSizeSpinbox.value);
            checksum += sectionLength;
            console.log("value, sectionLength",value, sectionLength)
            syntax += value.toFixed(6) + ", "+ sectionLength.toString() + ", "; // TODO function  scaleValue () - returns stored value in 0..1 into 0..max or -max..max
        }
        syntax +=  (scaleValue( points[points.length-1].value)).toFixed(6); // add the last value
        console.log("Last point index, value: ",points[points.length-1].value, points[points.length-1].index)
        console.log("Checksum: ", checksum);
        console.log("New table definition: ", syntax);
        syntaxField.text = syntax;
        return syntax;
    }

    function syntax2graph(syntax, maxValue) { // if second argument not given, find max from data
        var parameters = syntax.split("ftgen")[1].replace("ftgen ","").trim().split(","); // parameters after ftgen to array
        var size = parseInt(parameters[2]);
        //var segmentScale = (size + 0.0)/  (tableSizeSpinbox.value +  0.0)
        tableSizeSpinbox.value = size;

        // separate values and sizes of segments into arrays
        var values = [];
        var segments = [];
        //var max = (typeof maxValue === 'undefined') ? 0 : maxValue; // 0 signals, that find max from data, otherwise use given value
        var containsNegative = false;
        var max = 0;
        for (var i=4;i<parameters.length;i++) {
            console.log("i, value",i,parameters[i])
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
        console.log("MAX: ",maxValue);
        for (var i=0; i<values.length;i++) {
            values[i] /= maxValue; // to scale 0..1
            console.log("SCALED VALUE , i, value", i, values[i] )
        }


        if (bipolar.checked )
            for (var k=0; k<values.length;k++) {
                values[k] = values[k]/2.0+0.5; // to scale 0..1
                //console.log("NEGATIVE , i, value", i, values[k] )
            }


        console.log("Values: ",values, "segments: ", segments );
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
            console.log("j,index, sum, value: ",j,index, sum ,values[j])
            if (j<values.length-1) // the array of segments is shorter that the one with values
                sum += segments[j];

            points[j] = pointComponent.createObject(drawRect, { "x" : 0, "y":0, "index":index, "value":values[j] }); // value = 0.5 since bipolar view in the begining

        }
        drawRect.updatePointPositions();
        //canvas.requestPaint()

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
            property real value: 0 // TODO: keep as 0..1 and the scale to -max..max
            property real index:0  //TODO: keep as 0..1 and then scale to int(0..tableSize)


            MouseArea {
                id: pointArea
                anchors.fill: parent
                acceptedButtons:  Qt.LeftButton | Qt.RightButton
                hoverEnabled:  true
                drag.target: parent

                drag.minimumX: -width/2 //TODO :  make it fit with getMaximumX
                drag.maximumX: drawRect.width - width/2
                drag.minimumY: -height/2
                drag.maximumY: drawRect.height - height/2

                onPressed:
                    if (pressedButtons & Qt.RightButton) {
                        var index = points.indexOf(parent);
                        console.log("Deleting point with index: ", index)

                        points.splice(index,1) // remove from array
                        parent.destroy() // remove pointRect
                        valueRect.visible = false; // hide valueRect
                        canvas.requestPaint();

                    }

                drag.onActiveChanged: { //to detect dragEnd and dragFihised - not fired if not in automiatic mode
                    valueRect.visible  = drag.active // show the valuebox on drag
                    if (!drag.active) { // on dragEnd update index of the pointArea
                        parent.index =  x2index(parent.x+pointWidth/2)
                        parent.value = y2value(parent.y+pointWidth/2)
                        graph2syntax() // update syntax
                    }
                }



                onHoveredChanged: {
                    currentValue = y2value(parent.y + pointWidth/2);
                    currentIndex = x2index(parent.x + pointWidth/2);
                    valueRect.x = parent.x-valueRect.width/2;
                    valueRect.y = parent.y-valueRect.height-10;
                    valueRect.y = Math.max(-drawRect.y +2, valueRect.y) // not to show outside of window
                    valueRect.visible = containsMouse || drag.active; // show the valuebox while hovered
                }


            }



            onXChanged: {
                var index =  points.indexOf(this);
                //console.log("MOVING: ",index);
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
        width: parent.width*0.75; height: parent.height*0.6
        color: "#ffffff"
        anchors.horizontalCenter: parent.horizontalCenter
        y: valueRect.height + 5
        id: drawRect
        z: 1
        function updatePointPositions() {

            //points[0].x = 0;
            //points[0].y= drawRect.height/2-pointWidth/2;
            //points[points.length-1].x= drawRect.width-pointWidth/2;
            //points[points.length-1].y= 0-pointWidth/2;

            // update all points: -  lisa value ja index iga punkti juurde
            for (var i=0;i<points.length;i++) {

                points[i].x = points[i].index *  (drawRect.width-pointWidth/2);
                var helper = 1-(points[i].value+maxSpinbox.value)/2; // to 0..1 inversed
                //onsole.log("HElper 0..1",helper);
                points[i].y= (1-points[i].value)*drawRect.height-pointWidth/2;
                console.log("point, inedx,value,newX, newY",i,points[i].index,points[i].value, points[i].x, points[i].y);


            }

            canvas.requestPaint();

        }

        Component.onCompleted: {
            points[0] = pointComponent.createObject(drawRect, { "x" : 0, "y":mainWindow.height*0.6*0.5-pointWidth/2, "index":0, "value":0.5 }); // value = 0.5 since bipolar view in the begining
            points[1] = pointComponent.createObject(drawRect, { "x" :mainWindow.width*0.75-pointWidth/2, "y":0-pointWidth/2, "index":1,"value":1}); // cannot use this.heigth since probably not created yet...
            canvas.requestPaint();
        }

        onWidthChanged: updatePointPositions();
        onHeightChanged:updatePointPositions();

        Rectangle { // displays
            id:valueRect
            //y: (y<-drawRect.y + 2) ? -drawRect.y + 2 : y // don't let to go up from upper window border
            width: 150
            height: 50
            // TODO: how to rise above labels and other objects
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
                Label {text: qsTr("Value: ")+(scaleValue(currentValue)).toFixed(3)}
                Label {text: qsTr("Index: ")+(Math.round(currentIndex*tableSizeSpinbox.value)).toString()} // was: toString
            }

        }

        //TODO: set firt element 0
        MouseArea {
            anchors.fill: parent
            onDoubleClicked: {
                //console.log(mouse.x,mouse.y);
                insertPoint(mouse.x,mouse.y);
                graph2syntax()
            }
        }



        Canvas {
            id:canvas


            //width:155; height: 118
            anchors.fill: parent

            onPaint:{
                var context = canvas.getContext('2d');
                var offset = points[0].width / 2 ; // to move to the centre of circle

                context.beginPath();
                context.clearRect(0, 0, width, height);
                context.fill();

                //axis and numbers
                context.beginPath();
                context.lindeWidth = 4;
                context.moveTo(pointWidth/2,0) ;
                context.strokeStyle = "black";
                context.lineTo(pointWidth/2,drawRect.height);
                //context.stroke();
                var y0 = (bipolar.checked) ? drawRect.height/2 : drawRect.height-context.lindeWidth/2
                //y0 -= 10;
                context.moveTo(0,y0);
                context.lineTo(drawRect.width,y0);
                context.stroke();
                context.font ="12px sans-serif";
                context.strokeText(maxSpinbox.value.toString() ,10,10);
                context.strokeText("0",10,y0-5);
                if (bipolar.checked)
                    context.strokeText(-maxSpinbox.value.toString() ,10,drawRect.height-5);



                // lines between points
                context.beginPath();
                context.lineWidth = 1;

                //console.log("points.length: ", points.length)
                for (var i=1;i<points.length;i++) {
                    context.moveTo(points[i-1].x + offset, points[i-1].y+ offset) ;
                    context.strokeStyle = "red"
                    context.lineTo(points[i].x + offset, points[i].y + offset);
                    context.stroke();
                    //console.log("i-1, x, y:",i-1,points[i-1].x,points[i-1].y);
                    //console.log("i, x, y:",i,points[i].x,points[i].y);
                }

            }
        }




    }

    Label { // TODO: leia koht, võibolla messagedialog
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
        horizontalAlignment: 1
        anchors.left: parent.left
        anchors.leftMargin: 6
        stepSize: 0.01
        anchors.right: drawRect.left
        anchors.rightMargin: 6
        anchors.top: drawRect.top
        anchors.topMargin: 0
        value: 1
        maximumValue: 9999999
        decimals: 2
        onEditingFinished: {canvas.requestPaint(); graph2syntax() }// to display new max number
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
        id: graph2syntaxButton
        text: qsTr("&Graph2syntax")
        anchors.left: drawRect.left
        anchors.top: syntaxRadioButtons.bottom
        anchors.topMargin: 6

        onClicked:  {
            graph2syntax();
        }
    }


    Button {
        id: syntax2graphButton
        text: qsTr("&Synatx2Graph")
        anchors.left: drawRect.left
        anchors.top: graph2syntaxButton.bottom
        anchors.topMargin: 6


        onClicked: syntax2graph(syntaxField.text, maxSpinbox.value)
    }




    TextArea {
        id: syntaxField
        anchors.left: graph2syntaxButton.right
        anchors.leftMargin: 6
        anchors.right: drawRect.right
        anchors.top: graph2syntaxButton.top
        anchors.bottom:  mainArea.bottom
        anchors.bottomMargin: 10 // has no influence in some reason
        //height: mainWindow.height * 0.15
        readOnly: false
        //wrapMode: TextInput.WordWrap
        text: "giTable ftgen 0,0,1024, 7, 0.000000, 1024, 1.000000" // corresponds to the default position of points
        Keys.onReturnPressed: syntax2graph(syntaxField.text, maxSpinbox.value)

    }







    SpinBox {
        id: tableSizeSpinbox
        y: 362
        value: 1024
        minimumValue: 8
        maximumValue: 99999
        anchors.left: drawRect.right
        anchors.leftMargin: 6
        anchors.bottom: drawRect.bottom
        anchors.bottomMargin: 0
        onEditingFinished: {canvas.requestPaint(); graph2syntax() }// to display new max number


    }

    Label {
        id: tableSizeLabel
        x: 583
        y: 334
        height: 22
        text: qsTr("Table size")
        anchors.horizontalCenterOffset: 0
        anchors.bottom: tableSizeSpinbox.top
        anchors.bottomMargin: 6
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: tableSizeSpinbox.horizontalCenter
    }


    Row {


        id: syntaxRadioButtons
        ExclusiveGroup { id: syntaxTypeGroup }

        width: drawRect.width
        //height: 40
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
            exclusiveGroup: syntaxTypeGroup
        }

        RadioButton {
            id: fbutton
            text: qsTr("f statement")
            enabled: false
            exclusiveGroup: syntaxTypeGroup
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

    MessageDialog {
        id: helpDialog
        title: qsTr("Help")
        visible: false
        text: qsTr("Double-click to add a new point.\nDrag to move, right-click to remove\nYou can edit the table definition in textarea. \nThe changes in definition are displayed when you press ENTER or click on button Syntax2Table\n");
        onAccepted: visible=false;



    }


}
