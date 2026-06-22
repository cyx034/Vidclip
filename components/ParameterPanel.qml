import QtQuick
import style
import QtQuick.Controls
import QtQuick.Layouts

Item {
    Rectangle{
        anchors.fill: parent
        color: Style.p_background
        border.color: Style.border
        border.width: 1
    }

    //默认样式
    /*Item{
        anchors.fill:parent

        Text {
            id:titleTextId
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: "ItemInfomation"
            font.pixelSize: 14
            font.bold: true
            color: Style.textcolor
        }

        Rectangle{
            anchors.top: titleTextId.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 6
            height: 2
            color:Style.border
        }

    }*/

   //剪辑样式
    Item {
        id: labelId
        anchors.fill: parent

        // 当前选中的标签索引（0:Video, 1:Audio, 2:Speed）
        property int currentIndex: 0

        // 三个标签
        Row {
            id: labelRowId
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            spacing: 20

            Repeater {
                model: ["Video", "Audio", "Speed"]
                Text {
                    text: modelData
                    font.pixelSize: 14
                    color: index === labelId.currentIndex ? Style.highlight : Style.textcolor
                    TapHandler{
                        onTapped:labelId.currentIndex = index
                    }
                }
            }
        }

        // 分割线
        Rectangle {
            anchors.top: labelRowId.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: Style.border
        }

        // 页面内容（根据当前索引切换）
        StackLayout {
            anchors.top: parent.top
            anchors.topMargin: 60
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            currentIndex: labelId.currentIndex

            // 页面1：视频
            Item {
                Text {
                    anchors.centerIn: parent
                    text: "视频编辑内容"
                    color: Style.textcolor
                }
            }

            // 页面2：音频
            Item {
                Text {
                    anchors.centerIn: parent
                    text: "音频编辑内容"
                    color: Style.textcolor
                }
            }

            // 页面3：变速
            Item {
                Text {
                    anchors.centerIn: parent
                    text: "变速编辑内容"
                    color: Style.textcolor
                }
            }
        }
    }
}
