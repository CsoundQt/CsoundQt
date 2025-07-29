import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 800
    height: 700
    visible: true
    title: "Csound Table Editors"

    TabView {
        id: tabView
        anchors.fill: parent

        Tab {
            title: "GEN7"
            Loader {
                anchors.fill: parent
                anchors.margins: 10
                source: "Gen7Editor.qml"
            }
        }

        Tab {
            title: "GEN10"
            Loader {
                anchors.fill: parent
                anchors.margins: 10
                source: "Gen10Editor.qml"
            }
        }
        
        // Add more GEN tabs here
    }
}
