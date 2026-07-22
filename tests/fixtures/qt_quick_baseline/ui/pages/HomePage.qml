import QtQuick
import QtQuick.Layouts
import "../components"
import "../theme"

Item {
    id: root

    required property string statusText
    readonly property bool ready: statusPanel.text === "ready"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.spacing

        StatusPanel {
            id: statusPanel
            objectName: "statusPanel"
            text: root.statusText
        }

        PrimaryActionButton {
            objectName: "primaryAction"
            text: qsTr("Continue")
        }
    }
}
