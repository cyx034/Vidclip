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

    Component.onCompleted: {
        Qt.uiLanguage = "en_Us"
        Actions.aboutRequested.connect(function() {
            dialogs._aboutDialog.open()
        })
        Actions.exportRequested.connect(function() {
            exportCurrentMedia()
        })

        dialogs._exportDialog.exportWithSettings.connect(function(settings) {
            if (contentItem.clipCount <= 0) {
                dialogs._noExportDialog.open()
                return
            }

            var timeline = contentItem.timelineArea
            if (!timeline) {
                console.error("无法获取时间轴对象")
                return
            }

            var clipList = timeline.buildClipsFromModel()
            if (!clipList || clipList.length === 0) {
                console.warn("无剪辑数据")
                return
            }

            var clipsData = []
            for (var i = 0; i < clipList.length; i++) {
                var c = clipList[i]
                var clip = c.videoClip
                if (!clip) continue
                clipsData.push({
                    "source": clip.source.filePath,
                    "start": clip.sourceOffset,
                    "end": clip.sourceOffset + clip.duration,
                    "timeLineStart": clip.timelineStart,
                    "speed": clip.speed,
                    "volume": clip.volume,
                    "scaleX": clip.scaleX,
                    "scaleY": clip.scaleY,
                    "rotation": clip.rotation,
                    "offsetX": clip.offsetX,
                    "offsetY": clip.offsetY
                })
            }

            //直接使用 settings.savePath 作为完整输出路径
            var outputPath = settings.savePath
            if (outputPath.startsWith("file://")) outputPath = outputPath.substring(7)

            var exporter = Qt.createQmlObject(
                'import Vidclip 1.0; VideoExporter {}',
                contentItem,
                "dynamicExporter"
            )
            if (!exporter) {
                console.error("创建 VideoExporter 失败")
                return
            }

            exporter.progressChanged.connect(function(percent) {
                console.log("导出进度:", percent + "%")
            })
            exporter.exportFinished.connect(function(path) {
                console.log("导出成功:", path)
                exporter.destroy()
            })
            exporter.exportFailed.connect(function(error) {
                console.error("导出失败:", error)
                exporter.destroy()
            })

            exporter.exportTimeline(clipsData, settings, outputPath)
        })
    }

    function exportCurrentMedia() {
        if (contentItem.clipCount > 0) {
            dialogs._exportDialog.open()
        } else {
            dialogs._noExportDialog.open()
        }
    }
}

