import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    width: 800
    height: 700
    visible: true
    id: tableEditor
    // title: "Csound Table Editors"

    signal newSyntax(string syntax)

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

            Gen7Editor {}


            Gen10Editor {}

        }

    }
}
