import QtQuick
import QtQuick.Controls
import style
import "./components"
import "./content"
import action

ApplicationWindow {
    width: 1700
    height: 1000
    visible: true
    title: qsTr("MediaPlayer")

    // 预创建对话框
    Dialogs {
        id: dialogs
        anchors.fill: parent
    }

    component MMenuItem:MenuItem{
        font.pixelSize: Style.fontSizeNormal
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

    Connections {
        target: Actions
        function onImportRequested() {
            if (contentItem && contentItem.materialBin) {
                contentItem.materialBin.medioDialogId.open()
            }
        }
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
            MMenuItem{action:Actions._import}
            MMenuItem{action:Actions._export}
            MenuSeparator {
                contentItem: Rectangle {
                    color: Style.border
                }
            }
            MMenuItem{action:Actions.quit}
        }

        Menu {
            title: qsTr("Language")
            delegate: MenuItem {
                contentItem: Text { text: parent.text; color: Style.textcolor }
                background: Rectangle { color: parent.highlighted ? Style.highlight : Style.surface }
            }
            MMenuItem{
                text:"Chinese(中文)"
                onTriggered:{
                    Qt.uiLanguage = "zh_CN"
                }
            }
            MMenuItem{
                text: "English(英文)"
                onTriggered:{
                    Qt.uiLanguage = "en_Us"
                }
            }
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

    Content{
        id:contentItem
    }

    //全局右键菜单
    Menu {
        id: globalRightMenu

        MMenuItem {
            contentItem: Text { text:"Import"; color: Style.textcolor }
            onTriggered: {
                if (contentItem && contentItem.materialBin) {
                    contentItem.materialBin.medioDialogId.open()
                }
            }
        }
        MMenuItem {
            contentItem: Text{text: "Export"; color:Style.textcolor}
            onTriggered: {
                Actions._export.trigger()
            }
        }
        Menu {
            title: qsTr("Language")
            delegate: MenuItem {
                contentItem: Text { text: parent.text; color: Style.textcolor }
                background: Rectangle { color: parent.highlighted ? Style.highlight : Style.surface }
            }
            MMenuItem{
                text:"Chinese(中文)"
                onTriggered:{
                    Qt.uiLanguage = "zh_CN"
                }
            }
            MMenuItem{
                text: "English(英文)"
                onTriggered:{
                    Qt.uiLanguage = "en_Us"
                }
            }
        }
        MMenuItem {
            contentItem: Text{text: "About"; color:Style.textcolor}
            onTriggered: {
                dialogs._aboutDialog.open()
            }
        }
        MMenuItem {
            contentItem: Text{text: "Quit"; color:Style.textcolor}
            onTriggered: {
                Qt.quit()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: function(eventPoint) {
                globalRightMenu.popup()
                eventPoint.accepted = false
            }
        }
    }

    // 信号连接
    Component.onCompleted: {
        Actions.aboutRequested.connect(function() {
            dialogs._aboutDialog.open()
        })
        Actions.exportRequested.connect(function() {
            exportCurrentMedia()
        })
        Qt.uiLanguage = "en_US"
    }

    // 导出入口函数：检查媒体是否存在，然后打开导出设置对话框
    function exportCurrentMedia() {
        if (contentItem.clipCount > 0) {
            dialogs._exportDialog.open()
        } else {
            dialogs._noExportDialog.open()
        }
    }

}
