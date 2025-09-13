import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: drawTab
    width: 800
    height: 800
    color: "darkGrey"// tableEditor.color

    property string name: "freehand"
    property var drawnWaveform: []
    property int tableSize: 256
    property bool isDrawing: false
    property bool isShifting: false
    property int lastDrawnIndex: -1
    property int lastShiftX: -1

    onTableSizeChanged: {
        if (drawnWaveform.length > 0) {
            resizeWaveform();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Первая строка кнопок
        RowLayout {
            Layout.preferredHeight: 30
            spacing: 10

            Button {
                text: "Clear"
                Layout.preferredWidth: 80
                Layout.preferredHeight: 25
                font.pixelSize: 11
                onClicked: clearDrawing()
                ToolTip.visible: hovered
                ToolTip.text: "Clear the drawn waveform"
            }

            Button {
                text: "Smooth"
                Layout.preferredWidth: 80
                Layout.preferredHeight: 25
                font.pixelSize: 11
                onClicked: smoothWaveform()
                ToolTip.visible: hovered
                ToolTip.text: "Apply smoothing filter to waveform"
            }

            Button {
                text: "Normalize"
                Layout.preferredWidth: 80
                Layout.preferredHeight: 25
                font.pixelSize: 11
                onClicked: normalizeWaveform()
                ToolTip.visible: hovered
                ToolTip.text: "Normalize waveform to maximum amplitude"
            }

            Button {
                text: "Invert"
                Layout.preferredWidth: 80
                Layout.preferredHeight: 25
                font.pixelSize: 11
                onClicked: invertWaveform()
                ToolTip.visible: hovered
                ToolTip.text: "Invert waveform vertically"
            }

            Button {
                text: "Reverse"
                Layout.preferredWidth: 80
                Layout.preferredHeight: 25
                font.pixelSize: 11
                onClicked: reverseWaveform()
                ToolTip.visible: hovered
                ToolTip.text: "Reverse waveform"
            }

            Item { Layout.fillWidth: true }
        }


        RowLayout {
            id: secondRow
            Layout.preferredHeight: 30
            spacing: 10

            RowLayout {
                spacing: 5
                Layout.alignment: Qt.AlignLeft
                
                Label {
                    text: "Generate:"
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignVCenter
                }
                
                ComboBox {
                    id: waveTypeComboBox
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 25
                    font.pixelSize: 11
                    model: ["Sine", "Saw", "Square", "Triangle"]
                    onActivated: {
                        switch (currentIndex) {
                            case 0: generateSine(); break;
                            case 1: generateSaw(); break;
                            case 2: generateSquare(); break;
                            case 3: generateTriangle(); break;
                        }
                    }
                    delegate: ItemDelegate {
                        width: waveTypeComboBox.width
                        height: 25
                        text: modelData
                        font.pixelSize: 11
                        highlighted: waveTypeComboBox.highlightedIndex === index
                    }
                }
            }

            RowLayout {
                spacing: 5
                Layout.alignment: Qt.AlignLeft
                
                Label {
                    text: "Size:"
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignVCenter
                }
                
                ComboBox {
                    id: sizeComboBox
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 25
                    font.pixelSize: 11
                    model: [4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384]
                    currentIndex: 6 // default to 256
                    onActivated: {
                        tableSize = model[index]
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

            RowLayout {
                spacing: 5
                Layout.alignment: Qt.AlignLeft
                
                Label {
                    text: "Scale:"
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignVCenter
                }
                
                TextField {
                    id: scaleField
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    font.pixelSize: 11
                    placeholderText: "1.0"
                    validator: RegularExpressionValidator { regularExpression: /^[0-9]*\.?[0-9]*$/ } // allow dot
                    onTextChanged: {
                        // comma to dot
                        if (text.includes(",")) {
                            var cursorPos = cursorPosition
                            text = text.replace(",", ".")
                            cursorPosition = cursorPos
                        }
                    }
                    onEditingFinished: {
                        if (text !== "") {
                            scaleWaveform(parseFloat(text))
                        }
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: "Multiply waveform by scale factor (0.001 - 1000)"
                }
                
                Button {
                    text: "Apply"
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    font.pixelSize: 11
                    onClicked: {
                        if (scaleField.text !== "") {
                            scaleWaveform(parseFloat(scaleField.text))
                        }
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: "Apply scale factor"
                }
            }

            RowLayout {
                spacing: 5
                Layout.alignment: Qt.AlignLeft
                
                Label {
                    text: "Phase:"
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignVCenter
                }
                
                TextField {
                    id: phaseField
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    font.pixelSize: 11
                    placeholderText: "0.0"
                    validator: RegularExpressionValidator { regularExpression: /^-?[0-1]\.?[0-9]*$/ }
                    onTextChanged: {
                        // Автоматически заменяем запятую на точку
                        if (text.includes(",")) {
                            var cursorPos = cursorPosition
                            text = text.replace(",", ".")
                            cursorPosition = cursorPos
                        }
                        if (text !== "" && text !== "-" && text !== ".") {
                            var value = parseFloat(text)
                            if (value < -1) {
                                const cursorPos = cursorPosition
                                text = "-1.0"
                                cursorPosition = Math.min(cursorPos, 3)
                            } else if (value > 1) {
                                const cursorPos = cursorPosition
                                text = "1.0"
                                cursorPosition = Math.min(cursorPos, 2)
                            }
                        }
                    }
                    onEditingFinished: {
                        if (text !== "") {
                            var phase = parseFloat(text)
                            if (phase >= -1 && phase <= 1) {
                                phaseWaveform(phase)
                            }
                        }
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: "Rotate waveform phase (-1.0 - 1.0)"
                }
                
                Button {
                    text: "Apply"
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    font.pixelSize: 11
                    onClicked: {
                        if (phaseField.text !== "") {
                            var phase = parseFloat(phaseField.text)
                            if (phase >= -1 && phase <= 1) {
                                phaseWaveform(phase)
                            }
                        }
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: "Apply phase rotation (-1.0 - 1.0)"
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "To Csound Code"
                Layout.preferredWidth: 100
                Layout.preferredHeight: 25
                font.pixelSize: 11
                onClicked: generateCsoundCode() //saveFileDialog.open()
                ToolTip.visible: hovered
                ToolTip.text: "Save waveform as text file"
            }
        }

        // Область waveform
        Rectangle {
            id: waveformArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"
            border.color: "#ccc"

            Label {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 5
                text: "Waveform (" + tableSize + " points)"
                font.pixelSize: 12
                font.bold: true
                color: "#333"
                //Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            }
                
            Label {
                id: coordinatesText
                anchors.top: parent.top
                anchors.right: parent.right
                font.pixelSize: 12
                color: "#333"
                text: "X: -, Y: -"
               // Layout.alignment: Qt.AlignTop | Qt.AlignRight
            }

            Label {
                id: zeroLabel
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -8
                text: "0"
                font.pixelSize: 10
                color: "grey"
                z: 1 // above the canvas
            }

            Canvas {
                id: waveformCanvas
                anchors.fill: parent
                anchors.margins: 1
               // anchors.topMargin: 40

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    
                    // Draw center line (0 line)
                    var centerY = height / 2
                    ctx.strokeStyle = "lightgrey"
                    ctx.lineWidth = 1
                    ctx.globalAlpha = 0.7
                    ctx.beginPath()
                    ctx.moveTo(0, centerY)
                    ctx.lineTo(width, centerY)
                    ctx.stroke()
                    ctx.globalAlpha = 1.0 // Reset alpha


                    if (drawnWaveform.length === 0) return
                    
                    ctx.strokeStyle = "#e74c3c"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    
                    for (var i = 0; i < drawnWaveform.length; i++) {
                        var x = i * width / (drawnWaveform.length - 1)
                        var y = (1 - (drawnWaveform[i] + 1) / 2) * height
                        
                        if (i === 0) {
                            ctx.moveTo(x, y)
                        } else {
                            ctx.lineTo(x, y)
                        }
                    }
                    
                    ctx.stroke()
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        updateCoordinates(mouseX, mouseY)
                    }
                    onPressed: {
                        isDrawing = true
                        isShifting = mouse.modifiers & Qt.ShiftModifier
                        lastDrawnIndex = -1
                        lastShiftX = mouseX
                        updateCoordinates(mouseX, mouseY)
                        if (isShifting) {
                            shiftWaveform(mouseX)
                        } else {
                            drawWaveform(mouseX, mouseY)
                        }
                    }
                    onPositionChanged: {
                        updateCoordinates(mouseX, mouseY)
                        if (isShifting) {
                            shiftWaveform(mouseX)
                        } else if (isDrawing) {
                            drawWaveform(mouseX, mouseY)
                        }
                    }
                    onReleased: {
                        isDrawing = false
                        isShifting = false
                        lastDrawnIndex = -1
                        lastShiftX = -1
                    }
                    onExited: {
                        coordinatesText.text = "X: -, Y: -"
                    }
                }
            }
        }
    }

    // FileDialog {
    //     id: saveFileDialog
    //     title: "Save Waveform Table"
    //     //selectExisting: false
    //     nameFilters: ["Text files (*.txt)", "All files (*)"]
    //     onAccepted: {
    //         saveTable(fileUrl)
    //     }
    // }

    function updateCoordinates(x, y) {
        var xIndex = Math.floor(x / waveformArea.width * tableSize)
        xIndex = Math.max(0, Math.min(tableSize - 1, xIndex))
        
        var normalizedY = 1 - (2 * y / waveformArea.height)
        normalizedY = Math.max(-1, Math.min(1, normalizedY))
        
        coordinatesText.text = "X: " + xIndex + ", Y: " + normalizedY.toFixed(3)
    }

    function scaleWaveform(scaleFactor) {
        if (drawnWaveform.length === 0) return
        
        for (var i = 0; i < tableSize; i++) {
            drawnWaveform[i] *= scaleFactor
            // Ограничиваем значения от -1 до 1 после масштабирования
            drawnWaveform[i] = Math.max(-1, Math.min(1, drawnWaveform[i]))
        }
        
        waveformCanvas.requestPaint()
        scaleField.text = ""
        scaleField.text = ""
    }

    function drawWaveform(x, y) {
        if (drawnWaveform.length === 0) {
            initializeWaveform()
        }

        var currentIndex = Math.floor(x / waveformArea.width * tableSize)
        currentIndex = Math.max(0, Math.min(tableSize - 1, currentIndex))
        
        var normalizedY = 1 - (2 * y / waveformArea.height)
        normalizedY = Math.max(-1, Math.min(1, normalizedY))
        
        if (lastDrawnIndex !== -1 && lastDrawnIndex !== currentIndex) {
            var start = Math.min(lastDrawnIndex, currentIndex)
            var end = Math.max(lastDrawnIndex, currentIndex)
            
            for (var i = start + 1; i < end; i++) {
                var ratio = (i - lastDrawnIndex) / (currentIndex - lastDrawnIndex)
                drawnWaveform[i] = drawnWaveform[lastDrawnIndex] + (normalizedY - drawnWaveform[lastDrawnIndex]) * ratio
            }
        }
        
        drawnWaveform[currentIndex] = normalizedY
        lastDrawnIndex = currentIndex
        
        waveformCanvas.requestPaint()
    }

    function shiftWaveform(currentX) {
        if (lastShiftX === -1 || drawnWaveform.length === 0) return
        
        var deltaX = currentX - lastShiftX
        var shiftAmount = Math.round(deltaX / waveformArea.width * tableSize)
        
        if (shiftAmount === 0) return
        
        // Круговая ротация
        var tempWaveform = drawnWaveform.slice()
        
        for (var i = 0; i < tableSize; i++) {
            var newIndex = (i - shiftAmount) % tableSize
            if (newIndex < 0) {
                newIndex += tableSize // Корректируем отрицательный индекс
            }
            drawnWaveform[i] = tempWaveform[newIndex]
        }
        
        lastShiftX = currentX
        waveformCanvas.requestPaint()
    }

    function initializeWaveform() {
        drawnWaveform = new Array(tableSize)
        for (var i = 0; i < tableSize; i++) {
            drawnWaveform[i] = 0
        }
    }

    function clearDrawing() {
        drawnWaveform = []
        lastDrawnIndex = -1
        waveformCanvas.requestPaint()
        phaseField.text = ""
    }

    function smoothWaveform() {
        if (drawnWaveform.length === 0) return
        
        var smoothed = new Array(tableSize)
        var kernel = [0.25, 0.5, 0.25]
        
        for (var i = 0; i < tableSize; i++) {
            var sum = 0
            var weight = 0
            
            for (var j = -1; j <= 1; j++) {
                var index = i + j
                if (index >= 0 && index < tableSize) {
                    sum += drawnWaveform[index] * kernel[j + 1]
                    weight += kernel[j + 1]
                }
            }
            
            smoothed[i] = sum / weight
        }
        
        drawnWaveform = smoothed
        waveformCanvas.requestPaint()
    }

    function phaseWaveform(phase) {
        if (drawnWaveform.length === 0) return
        
        // Вычисляем количество точек для сдвига
        var shiftPoints = Math.round(phase * tableSize)
        
        if (shiftPoints === 0) return // Нет изменений
        
        // Круговая ротация волны (работает для положительных и отрицательных значений)
        var tempWaveform = drawnWaveform.slice()
        
        for (var i = 0; i < tableSize; i++) {
            var newIndex = (i - shiftPoints) % tableSize
            if (newIndex < 0) {
                newIndex += tableSize // Корректируем отрицательный индекс
            }
            drawnWaveform[i] = tempWaveform[newIndex]
        }
        
        waveformCanvas.requestPaint()
        // phaseField.text = "" // uncomment to clear the value.
    }

    function normalizeWaveform() {
        if (drawnWaveform.length === 0) return
        
        var maxAmplitude = 0
        for (var i = 0; i < tableSize; i++) {
            maxAmplitude = Math.max(maxAmplitude, Math.abs(drawnWaveform[i]))
        }
        
        if (maxAmplitude > 0) {
            for (var j = 0; j < tableSize; j++) {
                drawnWaveform[j] /= maxAmplitude
            }
            waveformCanvas.requestPaint()
        }
    }

    function invertWaveform() {
        if (drawnWaveform.length === 0) return
        
        for (var i = 0; i < tableSize; i++) {
            drawnWaveform[i] = -drawnWaveform[i]
        }
        waveformCanvas.requestPaint()
    }

    function reverseWaveform() {
        if (drawnWaveform.length === 0) return
        
        var reversed = []
        for (var i = drawnWaveform.length - 1; i >= 0; i--) {
            reversed.push(drawnWaveform[i])
        }
        drawnWaveform = reversed
        waveformCanvas.requestPaint()
    }

    function generateSine() {
        initializeWaveform()
        for (var i = 0; i < tableSize; i++) {
            drawnWaveform[i] = Math.sin(2 * Math.PI * i / tableSize)
        }
        waveformCanvas.requestPaint()
    }

    function generateSaw() {
        initializeWaveform()
        for (var i = 0; i < tableSize; i++) {
            drawnWaveform[i] = 2 * (i / tableSize) - 1
        }
        waveformCanvas.requestPaint()
    }

    function generateSquare() {
        initializeWaveform()
        for (var i = 0; i < tableSize; i++) {
            drawnWaveform[i] = i < tableSize / 2 ? 1 : -1
        }
        waveformCanvas.requestPaint()
    }

    function generateTriangle() {
        initializeWaveform()
        for (var i = 0; i < tableSize; i++) {
            if (i < tableSize / 2) {
                drawnWaveform[i] = 4 * i / tableSize - 1
            } else {
                drawnWaveform[i] = 3 - 4 * i / tableSize
            }
        }
        waveformCanvas.requestPaint()
    }

    function resizeWaveform() {
        if (drawnWaveform.length === 0) return
        
        var newWaveform = new Array(tableSize)
        var scale = (drawnWaveform.length - 1) / (tableSize - 1)
        
        for (var i = 0; i < tableSize; i++) {
            var oldIndex = i * scale
            var index1 = Math.floor(oldIndex)
            var index2 = Math.min(index1 + 1, drawnWaveform.length - 1)
            var fraction = oldIndex - index1
            
            if (index1 >= 0 && index2 < drawnWaveform.length) {
                newWaveform[i] = drawnWaveform[index1] * (1 - fraction) + drawnWaveform[index2] * fraction
            } else {
                newWaveform[i] = 0
            }
        }
        
        drawnWaveform = newWaveform
        waveformCanvas.requestPaint()
    }

    // function saveTable(fileUrl) {
    //     if (drawnWaveform.length === 0) {
    //         console.log("No waveform to save")
    //         return
    //     }

    //     var filePath = fileUrl.toString();
    //     if (filePath.startsWith("file:///")) {
    //         filePath = filePath.substring(7);
    //     }
        
    //     var content = "";
    //     for (var i = 0; i < drawnWaveform.length; i++) {
    //         content += drawnWaveform[i].toFixed(8);
    //         if (i < drawnWaveform.length - 1) {
    //             content += " ";
    //         }
    //     }
        
    //     var xhr = new XMLHttpRequest();
    //     xhr.open("PUT", fileUrl);
    //     xhr.setRequestHeader("Content-Type", "text/plain");
    //     xhr.send(content);
        
    //     console.log("Table saved to:", filePath);
    // }

    function generateCsoundCode() {
        let csoundCode = "giTable ftgen 0, 0, " + tableSize + ", 2"
        for (let i = 0; i < drawnWaveform.length; i++) {
            csoundCode += ", " + drawnWaveform[i].toFixed(8);
        }
        console.log("Table definition: ", csoundCode);
        return csoundCode;
    }

    Component.onCompleted: {
        drawnWaveform = []
        waveformCanvas.requestPaint()
        coordinatesText.text = "X: -, Y: -"
    }
}
