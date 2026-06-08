import QtQuick
import QtQuick.Controls
import style
import "./components"
import "./content"
import action

ApplicationWindow {
    width: 1400
    height: 1000
    visible: true
    title: qsTr("MediaPlayer")

    component MMenuItem:MenuItem{
        // 设置字体大小
        font.pixelSize: Style.fontSizeNormal
        // 设置文本颜色 (通过palette)
        palette.text: Style.textcolor
        palette.buttonText: Style.textcolor
        background: Rectangle{
            color: parent.highlighted ? Style.highlight : Style.surface
        }
    }

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
            MMenuItem{action:Actions._new}
            MMenuItem{action:Actions._import}
            MMenuItem{action:Actions._export}
            MenuSeparator {
                contentItem: Rectangle {
                    color: Style.border
                }
            }
            MMenuItem{action:Actions.quit}
        }

        /*Menu {
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
        }*/

        Menu {
            title: qsTr("Setting")
            delegate: MenuItem {
                contentItem: Text { text: parent.text; color: Style.textcolor }
                background: Rectangle { color: parent.highlighted ? Style.highlight : Style.surface }
            }
            MMenuItem{action:Actions.language}
        }

        Menu {
            title: qsTr("Help")
            delegate: MenuItem {
                contentItem: Text { text: parent.text; color: Style.textcolor }
                background: Rectangle { color: parent.highlighted ? Style.highlight : Style.surface }

            }
            MMenuItem{action:Actions.about}
        }
    }

    Content{}

}
