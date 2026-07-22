import QtQuick
import QtQuick.Controls

Button {
    id: control

    background: Rectangle {
        color: control.down ? "#2457c5" : "#2f6feb"
        radius: 8
    }
}
