import QtQuick
import QtQuick.Controls
import style
import "./components"
import "./content"

ApplicationWindow {
    width: 1400
    height: 1000
    visible: true
    title: qsTr("MediaPlayer")

    background:Rectangle {
        anchors.fill:parent
        color: Style.background
    }

    menuBar:MenuBar {
        background: Rectangle {

            color: Style.surface
            border.color: Style.border
            border.width: 1
        }
        delegate:MenuBarItem{
            contentItem: Text {
                text: parent.text
                color: Style.textcolor
                font.pixelSize:Style.fontSizeNormal
            }
            background: Rectangle{
                color: parent.highlighted ? Style.highlight : "transparent"
            }
        }
        Menu {
            id:m
            title: qsTr("File")
            delegate: MenuItem {
                contentItem: Text {
                    text: parent.text
                    color: Style.textcolor
                    font.pixelSize:Style.fontSizeNormal
                }
                background: Rectangle {
                    color: parent.highlighted ? Style.highlight : Style.surface
                }
            }
            Action { text: qsTr("New");icon.name:"document-new"}
            Action { text: qsTr("import") }
            Action { text: qsTr("export") }

            /*Component.onCompleted: {
                m.addAction(Actions.open)
            }

            MenuItem{action:Actions.save}*/

            MenuSeparator {
                contentItem: Rectangle {
                    color: Style.border
                }
            }
            /*Action{ text:qsTr("exit") }*/
        }

        Menu {
            title: qsTr("Edit")
            delegate: MenuItem {
                contentItem: Text { text: parent.text; color: Style.textcolor}
                background: Rectangle { color: parent.highlighted ? Style.highlight :  Style.surface}
            }
            Action { text: qsTr("revocation") }
            Action { text: qsTr("recover") }
            Action { text: qsTr("copy") }
            Action { text: qsTr("shear") }
            Action { text: qsTr("paste") }
            Action { text: qsTr("delete") }
        }

        Menu {
            title: qsTr("Setting")
            delegate: MenuItem {
                contentItem: Text { text: parent.text; color: Style.textcolor }
                background: Rectangle { color: parent.highlighted ? Style.highlight : Style.surface }
            }
            Action { text: qsTr("language") }
        }

        Menu {
            title: qsTr("Help")
            delegate: MenuItem {
                contentItem: Text { text: parent.text; color: Style.textcolor }
                background: Rectangle { color: parent.highlighted ? Style.highlight : Style.surface }

            }
            Action { text: qsTr("about") }
        }
    }

    Content{}

}
