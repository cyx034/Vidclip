import QtQuick
import QtQuick.Controls
import style
import components
import pages

ApplicationWindow {
    width: 1400
    height: 1000
    visible: true
    title: qsTr("MediaPlayer")

    background:Rectangle {
        anchors.fill:parent
        color: Style.background
    }

    menuBar:AppMenuBar{}

    EditorPage{}

}
