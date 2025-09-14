import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 800
    height: 700
    color: tableEditor.color

    property string name: "gen10"  // important! to let parent know which editor is active in tabView


    property var harmonics: [1.0, 0.5, 0.3, 0.25, 0.2, 0.1667, 0.1429, 0.125, 
                            0.1111, 0.1, 0.0909, 0.0833, 0.0769, 0.0714, 0.0667, 0.0625]
    property int tableSize: 1024

    signal updateRequested()

    onHarmonicsChanged: updateRequested()
    onTableSizeChanged: updateRequested()

    onUpdateRequested: {
        waveform.requestPaint()
        csoundCode.text = generateCsoundCode()
    }

    Row {
        id: controlPanel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 5
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10
        height: 30

        Button {
            text: "Clear All"
            width: 80
            height: 25
            font.pixelSize: 11
            onClicked: clearAllHarmonics()
            ToolTip.visible: hovered
            ToolTip.text: "Reset all harmonics to zero"
        }

        Button {
            text: "Reset"
            width: 80
            height: 25
            font.pixelSize: 11
            onClicked: resetHarmonics()
            ToolTip.visible: hovered
            ToolTip.text: "Reset to default harmonic values"
        }

        Row {
            spacing: 5
            height: 25
            
            Label {
                text: "Table Size:"
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
            
            ComboBox {
                id: sizeComboBox
                width: 90
                height: 25
                font.pixelSize: 11
                model: [256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536]
                currentIndex: 2
                onActivated: {
                    tableSize = model[index]
                    updateRequested()
                }
                delegate: ItemDelegate {
                    width: sizeComboBox.width
                    height: 25
                    text: modelData
                    font.pixelSize: 11
                    highlighted: sizeComboBox.highlightedIndex === index
                }
            }
        }
    }

    WaveformDisplay {
        id: waveform
        anchors.top: controlPanel.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 5
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        height: 250
        harmonics: root.harmonics
    }

    ScrollView {
        id: slidersScroll
        anchors.top: waveform.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 5
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        height: 200
        clip: true

        Row {
            id: slidersRow
            spacing: 5

            Repeater {
                model: 16
                
                Column {
                    spacing: 1
                    width: 40
                    
                    HarmonicSlider {
                        id: slider
                        width: 40
                        height: 180
                        label: (index + 1).toString()
                        value: harmonics[index]
                        onValueChanged: {
                            harmonics[index] = value
                            updateRequested()
                        }
                    }
                    
                    Button {
                        width: 40
                        height: 18
                        text: "0"
                        font.pixelSize: 9
                        onClicked: {
                            harmonics[index] = 0
                            slider.slider.value = 0
                            updateRequested()
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.top: slidersScroll.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 5
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 5
        color: "white"
        border.color: "#ccc"
        clip: true

        Flickable {
            id: flickable
            anchors.fill: parent
            anchors.margins: 3
            contentWidth: csoundCode.width
            contentHeight: csoundCode.height
            clip: true

            TextEdit {
                id: csoundCode
                width: flickable.width - 20 
                height: Math.max(implicitHeight, flickable.height)
                text: generateCsoundCode()
                font.family: "Courier New"
                font.pixelSize: 10
                wrapMode: TextEdit.Wrap
                readOnly: true
                selectByMouse: true
                textFormat: TextEdit.PlainText
            }
        }
    }

    function clearAllHarmonics() {
        for (var i = 0; i < 16; i++) {
            harmonics[i] = 0
            if (slidersRow.children[i] && slidersRow.children[i].children[0] && slidersRow.children[i].children[0].slider) {
                slidersRow.children[i].children[0].slider.value = 0
            }
        }
        updateRequested()
    }

    function resetHarmonics() {
        var defaultValues = [1.0, 0.5, 0.3, 0.25, 0.2, 0.1667, 0.1429, 0.125, 
                            0.1111, 0.1, 0.0909, 0.0833, 0.0769, 0.0714, 0.0667, 0.0625]
        for (var i = 0; i < 16; i++) {
            harmonics[i] = defaultValues[i]
            if (slidersRow.children[i] && slidersRow.children[i].children[0] && slidersRow.children[i].children[0].slider) {
                slidersRow.children[i].children[0].slider.value = defaultValues[i]
            }
        }
        updateRequested()
    }

    function generateCsoundCode() {
        var code = "giWave ftgen 0, 0, " + tableSize + ", 10, "
        for (var i = 0; i < 16; i++) {
            code += harmonics[i].toFixed(4)
            if (i < 15) code += ", "
        }
        return code
    }

    Component.onCompleted: updateRequested()

    component WaveformDisplay: Canvas {
        id: canvas
        property var harmonics: []

        onHarmonicsChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            ctx.strokeStyle = "#999"
            ctx.beginPath()
            ctx.moveTo(0, height/2)
            ctx.lineTo(width, height/2)
            ctx.stroke()

            // Step 1: Calculate all y values and store them
            var yValues = []
            var maxY = 0;
            for (var x = 0; x < width; x++) {
                var t = x / width * 2 * Math.PI
                var y = 0
                for (var h = 0; h < harmonics.length; h++) {
                    var harmonic = h + 1
                    var amplitude = harmonics[h] || 0
                    y += Math.sin(t * harmonic) * amplitude
                }
                yValues.push(y)
                if (Math.abs(y)>maxY) {
                    maxY = Math.abs(y)
                }
            }

            // Normalize, if needed and draw
            ctx.strokeStyle = "#e74c3c"
            ctx.lineWidth = 1.2
            ctx.beginPath()
            for (x = 0; x < width; x++) {
                var normalizedY = maxY>1 ? yValues[x]/maxY : yValues[x]
                var yCanvas = height/2 - normalizedY * (height/2) * 0.95
                if (x === 0)
                    ctx.moveTo(x, yCanvas)
                else
                    ctx.lineTo(x, yCanvas)
            }
            ctx.stroke()
        }
    }

    component HarmonicSlider: Column {
        property string label: ""
        property real value: 0.5
        property alias slider: sliderControl
        spacing: 1
        width: 40
        
        Label {
            text: label
            font.bold: true
            font.pixelSize: 10
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Slider {
            id: sliderControl
            orientation: Qt.Vertical
            width: 30
            height: 150
            from: 0
            to: 1.0
            stepSize: 0.01
            value: parent.value
            
            onMoved: {
                parent.value = value
                if (typeof parent.onValueChanged === "function") {
                    parent.onValueChanged()
                }
            }
            
            background: Rectangle {
                x: sliderControl.leftPadding
                y: sliderControl.topPadding
                width: sliderControl.availableWidth
                height: sliderControl.availableHeight
                radius: 1
                color: "#e74c3c"
                
                Rectangle {
                    width: parent.width
                    height: sliderControl.visualPosition * parent.height
                    color: "#e0e0e0"
                    radius: 1
                }
            }
            
            handle: Rectangle {
                x: sliderControl.leftPadding
                y: sliderControl.topPadding + sliderControl.visualPosition * (sliderControl.availableHeight - height)
                width: sliderControl.availableWidth
                height: 6
                radius: 1
                color: sliderControl.pressed ? "#c0392b" : "#ffffff"
                border.color: "#999"
            }
        }
        
        Label {
            text: sliderControl.value.toFixed(2)
            font.pixelSize: 9
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
