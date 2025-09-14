import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    width: 800
    height: 700
    visible: true
    id: tableEditor
    // title: "Csound Table Editors"
    color: windowColor
    property string syntaxString: "" // will be updated from children

    // property bool isDarkTheme: isDarkColor(windowColor)

    signal newSyntax(string syntax)

    function isDarkColor(color) {
            // Calculate luminance using standard formula
            var r = color.r
            var g = color.g
            var b = color.b
            var luminance = 0.299 * r + 0.587 * g + 0.114 * b
            return luminance < 0.5
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        ToolBar {
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent
                ToolButton {

                    id: graph2syntaxButton
                    text: qsTr("&Insert to CsoundQt")

                    onClicked:  {
                        let csoundCode = ""
                        if (stack.itemAt(stack.currentIndex)?.name === "gen7" ) {
                            csoundCode = gen7Editor.graph2syntax();
                        } else if (stack.itemAt(stack.currentIndex)?.name === "gen10") {
                            csoundCode = gen10Editor.generateCsoundCode();
                        } else if (stack.itemAt(stack.currentIndex)?.name === "freehand") {
                            csoundCode = freehandEditor.generateCsoundCode();
                        }
                        //console.log("Text to insert: ", csoundCode);
                        if (csoundCode) {
                            newSyntax(csoundCode);
                        } else {
                            console.warn("No Csound code generated.");
                        }
                    }

                }
            }
        }

        TabBar {
            id: tabBar
            currentIndex: stack.currentIndex
            TabButton { implicitWidth: Math.max(80, contentItem.implicitWidth + 20); text: "GEN7" }
            TabButton { implicitWidth: Math.max(80, contentItem.implicitWidth + 20); text: "GEN10" }
            TabButton { implicitWidth: Math.max(80, contentItem.implicitWidth + 20); text: qsTr("Freehand") }
        }

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex


            Gen7Editor { id: gen7Editor}

            Gen10Editor { id: gen10Editor}

            FreehandEditor { id: freehandEditor }

        }

    }
}
