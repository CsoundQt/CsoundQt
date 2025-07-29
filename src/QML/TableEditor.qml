import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    width: 800
    height: 700
    visible: true
    title: "Csound Table Editors"

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        TabBar {
            id: tabBar
            currentIndex: stack.currentIndex
            TabButton { implicitWidth: Math.max(80, contentItem.implicitWidth + 20); text: "GEN7" }
            TabButton { implicitWidth: Math.max(80, contentItem.implicitWidth + 20); text: "GEN10" }
        }

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            Item {
                Loader {
                    anchors.fill: parent
                    anchors.margins: 10
                    source: "Gen7Editor.qml"
                }
            }

            Item {
                Loader {
                    anchors.fill: parent
                    anchors.margins: 10
                    source: "Gen10Editor.qml"
                }
            }


        }
    }
}
