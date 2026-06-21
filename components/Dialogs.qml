import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import style

Item{
    property alias _aboutDialog: aboutDialog
    property alias _exportDialog: exportDialog

    Dialog {
        id: exportDialog
        modal: true
        width: 680
        height: 600
        anchors.centerIn: parent
        padding: 0
        background: Rectangle {
            color: Style.background
        }

        component MButton:Button{
            background: Rectangle {
                color: parent.hovered ? Style.highlight : Style.d_button
                border.color: Style.border
                border.width: 1
                radius: 4
            }
            contentItem: Text {
                text: parent.text
                color: Style.textcolor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        component MComboBox:ComboBox{
            id:combox
            background: Rectangle {
                color: parent.hovered ? Style.highlight : Style.d_button
                border.color: Style.border
                border.width: 1
                radius: 4
            }
            contentItem: Text {
                text: parent.displayText
                color: Style.textcolor
                font.pixelSize: 12
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: 4
            }
            popup: Popup {
                y: parent.height
                width: parent.width
                background: Rectangle {
                    color: Style.surface
                    border.color: Style.border
                    border.width: 1
                }
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: combox.model          // 使用 id 引用
                    currentIndex: combox.currentIndex
                    delegate: ItemDelegate {
                        width: parent.width
                        text: modelData
                        font.pixelSize: 12
                        contentItem: Text {
                            text: modelData
                            color: Style.textcolor
                            font: parent.font
                        }
                        highlighted: parent.ListView.isCurrentItem
                        background: Rectangle {
                            color: highlighted ? Style.highlight : Style.surface
                        }
                    }
                }
            }
        }

        //默认设置
        property string exportFormat: "mp4"
        property string resolution: "original"
        property int frameRate: 30
        property int bitrate: 5000
        property string quality: "middle"
        property string encoder: "H.264"
        property bool saveToCloud: false
        property string coverPath: ""
        property string savePath: ""

        signal exportWithSettings(var settings)

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 自定义标题栏
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                height: 40
                color: Style.surface
                border.color: Style.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 10

                    Text {
                        text: "Export"
                        font.pixelSize: 14
                        font.bold: true
                        color: Style.textcolor
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            // 内容区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15
                anchors.margins: 20

                // 左列：封面编辑
                ColumnLayout {
                    Layout.preferredWidth:200
                    Layout.fillHeight: true
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 160
                        Layout.alignment: Qt.AlignHCenter
                        border.color: Style.border
                        border.width: 1
                        radius: 8
                        color: Style.surface

                        Image {
                            id: coverPreview
                            anchors.fill: parent
                            anchors.margins: 5
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    MButton {
                        text: "Edit cover"  //编辑封面
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: coverSelector.open()
                    }
                }


                // 右列：导出设置
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    Text {
                        text: qsTr("Export Settings")  //导出设置
                        font.pixelSize: 18
                        font.bold: true
                        color: Style.textcolor
                    }

                    Text {
                        text: qsTr("Title")   //标题
                        font.pixelSize: 14
                        font.bold: true
                        color: Style.textcolor
                        Layout.topMargin: 10
                    }

                    TextField {
                        id: titleField
                        Layout.fillWidth: true
                        placeholderText: "My Videos"
                        text: "My Videos"
                        color: Style.textcolor
                        background: Rectangle {
                            color: Style.d_button
                            border.color: Style.border
                            border.width: 1
                            radius: 4
                        }
                    }

                    // 保存位置
                    GroupBox {
                        Layout.fillWidth: true
                        label: Text {
                            text: qsTr("Save As")   //保存至
                            color: Style.textcolor
                            font.pixelSize: 14
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                TextField {
                                    id: savePathField
                                    Layout.fillWidth: true
                                    placeholderText: "Select The Storage Location"   //选择保存的位置
                                    color: Style.textcolor
                                    placeholderTextColor: Style.textcolor  //占位符颜色
                                    background: Rectangle {
                                        color: Style.d_button
                                        border.color: Style.border
                                        border.width: 1
                                        radius: 4
                                    }
                                }

                                MButton {
                                    text: "Browse"  //浏览
                                    onClicked: folderDialog.open()
                                }
                            }
                        }
                    }

                    // 视频导出设置
                    GroupBox {
                        Layout.fillWidth: true
                        label: Text {
                            text: qsTr("Video Export")
                            color: Style.textcolor
                            font.pixelSize: 14
                        }

                        GridLayout {
                            anchors.fill: parent
                            columns: 2
                            rowSpacing: 10
                            columnSpacing: 15

                            Text { text: "Format:"; color: Style.textcolor }  //格式
                            MComboBox {
                                id: formatCombo
                                model: ["MP4", "MOV", "AVI", "MKV"]
                                currentIndex: 0
                                onCurrentTextChanged: exportDialog.exportFormat = currentText.toLowerCase()
                            }

                            Text { text: "Resolution Ratio:"; color: Style.textcolor }   //分辨率
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 5

                                MComboBox {
                                    id: resolutionWidth
                                    model: ["640", "720", "854", "1280", "1920", "2560"]
                                    currentIndex: 4
                                    onCurrentTextChanged: {
                                        exportDialog.resolution = currentText + "x" + resolutionHeight.currentText
                                    }
                                }

                                Text { text: "×"; color: Style.textcolor }

                                MComboBox {
                                    id: resolutionHeight
                                    model: ["360", "480", "720", "1080", "1440"]
                                    currentIndex: 3
                                    onCurrentTextChanged: {
                                        exportDialog.resolution = resolutionWidth.currentText + "x" + currentText
                                    }
                                }
                            }

                            Text { text: "Encoder:"; color: Style.textcolor }  //编码器
                            MComboBox {
                                id: encoderCombo
                                model: ["H.264", "H.265", "VP9"]
                                currentIndex: 0
                                onCurrentTextChanged: exportDialog.encoder = currentText
                            }

                            Text { text: "Quality:"; color: Style.textcolor }  //质量
                            RowLayout {
                                Layout.fillWidth: true
                                MComboBox {
                                    id: qualityCombo
                                    model: ["low", "medium", "high"]
                                    currentIndex: 1
                                    onCurrentTextChanged: {
                                        exportDialog.quality = currentText
                                        if (currentText === "低") bitrate = 2000
                                        else if (currentText === "中") bitrate = 5000
                                        else if (currentText === "高") bitrate = 8000
                                    }
                                }
                            }

                            Text { text: "Frame Rate:"; color: Style.textcolor }  //帧率
                            RowLayout {
                                Layout.fillWidth: true
                                MComboBox {
                                    id: fpsCombo
                                    model: ["24", "25", "29.97", "30", "50", "60"]
                                    currentIndex: 2
                                    onCurrentTextChanged: exportDialog.frameRate = parseFloat(currentText)
                                }
                                Text { text: "fps"; color: Style.textcolor }
                            }

                            Text { text: "Code Rate:"; color: Style.textcolor }  //码率
                            RowLayout {
                                Layout.fillWidth: true
                                Slider {
                                    id: bitrateSlider
                                    from: 1000
                                    to: 50000
                                    stepSize: 500
                                    value: exportDialog.bitrate
                                    Layout.fillWidth: true
                                    onValueChanged: exportDialog.bitrate = value
                                }
                                Text {
                                    text: Math.round(bitrateSlider.value) + " kbps"
                                    color: Style.textcolor
                                    Layout.preferredWidth: 70
                                }
                            }
                        }
                    }

                    // 预估信息
                    Rectangle {
                        Layout.fillWidth: true
                        height: 50
                        color: Style.background
                        border.color: Style.border
                        border.width: 1
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 15

                            Text {
                                text: "Duration:"   //时长
                                color: Style.textcolor
                                font.pixelSize: 12
                            }
                            Text {
                                text: "Size：about " + Math.round(exportDialog.bitrate * 12 / 8 / 1024) + " MB"
                                color: Style.textcolor
                                font.pixelSize: 12
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        Item { Layout.fillWidth: true }

                        MButton {
                            text: qsTr("CANCEL")
                            onClicked: exportDialog.reject()
                        }
                        MButton {
                            text: qsTr("OK")
                            onClicked: exportDialog.accept()
                        }
                    }
                }
            }
        }

        //子对话框
        Dialog {
            id: coverSelector
            title: "Select Cover"   //选择封面
            modal: true
            width: 400
            height: 300
            standardButtons: Dialog.Ok | Dialog.Cancel

            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                anchors.margins: 15

                MButton {
                    text: "Import From The Local Area"   //从本地导入
                    Layout.fillWidth: true
                    onClicked: imageDialog.open()
                }

                MButton {
                    text: "From The Video Clip"   //从视频截取
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    border.color: Style.border
                    border.width: 1
                    color: Style.surface

                    Image {
                        id: coverPreviewSmall
                        anchors.fill: parent
                        anchors.margins: 5
                        fillMode: Image.PreserveAspectFit
                        source: exportDialog.coverPath
                    }
                }
            }
        }

        FileDialog {
            id: imageDialog
            title: "Select The Cover Image"   //选择封面图片
            fileMode: FileDialog.OpenFile
            nameFilters: ["图片文件 (*.jpg *.png *.jpeg)", "所有文件 (*)"]

            onAccepted: {
                if (selectedFile) {
                    coverPath = selectedFile.toString()
                    coverPreview.source = coverPath
                    coverPreviewSmall.source = coverPath
                }
            }
        }

        FileDialog {
            id: folderDialog
            title: "Select The Storage Location"   //选择保存位置
            fileMode: FileDialog.Directory
            onAccepted: {
                if (selectedFile) {
                    savePath = selectedFile.toString()
                    savePathField.text = savePath
                }
            }
        }

        //确认逻辑
        onAccepted: {
            let settings = {
                format: exportDialog.exportFormat,
                resolution: exportDialog.resolution,
                frameRate: exportDialog.frameRate,
                bitrate: exportDialog.bitrate,
                quality: exportDialog.quality,
                encoder: exportDialog.encoder,
                saveToCloud: exportDialog.saveToCloud,
                coverPath: exportDialog.coverPath,
                savePath: savePathField.text,
                title: titleField.text
            }
            exportWithSettings(settings)
        }
    }



    Dialog {
        id: aboutDialog
        modal: true
        //standardButtons: Dialog.Ok
        width: 500
        height: 380
        anchors.centerIn: parent
        padding: 0
        background: Rectangle {
            color: Style.background
        }

        // 自定义标题栏
        Rectangle {
            id: titleId
            width: parent.width
            height: 40
            color: Style.surface
            border.color: Style.border
            border.width: 1   // 仅底部边框

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 10

                Text {
                    text: "About Vidclip"
                    font.pixelSize: 14
                    font.bold: true
                    color: Style.textcolor
                }

                Item { Layout.fillWidth: true }
            }
        }

        // 主内容区域
        ColumnLayout {
            anchors.top: titleId.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
            spacing: 15

            // 软件图标 + 版本
            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                Image {
                    source: "qrc:/image/icon.jpg"
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    fillMode: Image.PreserveAspectFit
                    clip: true
                }

                ColumnLayout {
                    Text {
                        text: qsTr("Vidclip")
                        font.pixelSize: 48
                        font.bold: true
                        color: Style.textcolor
                    }
                    Text {
                        text: qsTr("Version: 1.0.0")
                        font.pixelSize: 14
                        color: Style.textcolor
                    }
                }
            }

            // 技术栈信息
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 8
                columnSpacing: 30

                Text { text: qsTr("Qt: %1").arg(Qt.version); color: Style.textcolor }
                Text { text: qsTr("FFmpeg: 7.1.3"); color: Style.textcolor }
                Text { text: qsTr("OS: %1").arg(Qt.platform.os); color: Style.textcolor }
                Text { text: qsTr("Build: Desktop"); color: Style.textcolor }
            }

            Text {
                text: qsTr("Copyright © 2026 Twelve Groups")
                font.pixelSize: 13
                color: Style.textcolor
            }

            Text {
                text: "<a href='https://github.com/yourname/vidclip'>https://github.com/yourname/vidclip</a>"
                font.pixelSize: 13
                color: Style.textcolor
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Text {
                text: qsTr("A simple video editor built with Qt.\nThis software uses qml,c++,and FFmpeg for media processing.")
                font.pixelSize: 13
                color: Style.textcolor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("OK")
                Layout.alignment: Qt.AlignRight
                Layout.topMargin: 10
                Layout.rightMargin: 10
                onClicked: aboutDialog.accept()

                background: Rectangle {
                    color:Style.d_button
                    border.color: Style.border
                    border.width: 2
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: Style.textcolor
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}