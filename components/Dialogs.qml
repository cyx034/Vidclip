import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import style

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
        id: titleBar
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
        anchors.top: titleBar.bottom
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