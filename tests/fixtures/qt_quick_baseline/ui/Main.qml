import QtQuick
import QtQuick.Controls
import "pages"

ApplicationWindow {
    id: root

    readonly property bool ready: homePage.ready

    width: 480
    height: 320
    visible: true
    title: qsTr("MyApp")
    font.family: Qt.application.font.family

    AppViewModel {
        id: appViewModel
    }

    HomePage {
        id: homePage
        objectName: "homePage"
        anchors.fill: parent
        statusText: appViewModel.status
    }
}
