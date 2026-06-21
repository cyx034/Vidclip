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

    // 预创建对话框
    Dialogs {
        id: aboutDialog
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

    Content{
        id:contentItem
    }

    //导出设置对话框
    ExportDialog {
        id: exportDialog
        onExportWithSettings: function(settings) {
            console.log("用户选择的导出设置:", JSON.stringify(settings, null, 2))
            var info = "格式: " + settings.format + "\n" +
                       "分辨率: " + settings.resolution + "\n" +
                       "帧率: " + settings.frameRate + "\n" +
                       "码率: " + settings.bitrate + "\n" +
                       "质量: " + settings.quality + "\n" +
                       "编码器: " + settings.encoder + "\n" +
                       "保存路径: " + (settings.savePath || "未指定") + "\n" +
                       "标题: " + (settings.title || "我的视频")
        }
    }

    // 信号连接
    Component.onCompleted: {
        Actions.aboutRequested.connect(function() {
            aboutDialog.open()
        })
        Actions.exportRequested.connect(function() {
            exportCurrentMedia()
        })
    }

    // 导出入口函数：检查媒体是否存在，然后打开导出设置对话框
    function exportCurrentMedia() {
        if (!contentItem.currentMediaUrl) {
            console.log("没有导出的媒体文件！")
            return
        }
        exportDialog.open()
    }

    function performExport(filePath) {
        // 未使用
    }

    function showExportProgress(outputPath) {
        // 未使用
    }

}
