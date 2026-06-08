import QtQuick
import QtQuick.Controls
import style
import QtQuick.Layouts
import action

Item {
    id: root
    Rectangle{
        anchors.fill:parent
        color: Style.t_background
        border.color: Style.border
        border.width: 1
    }
    ListModel {
        id: clipModel
        // 每个元素：{ trackId, startSec, durationSec, type, sourceUrl }
    }

    ToolBar{
        id:toolBarId
        anchors.top:parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: 40
        background: Rectangle{color:Style.surface}
        RowLayout {
            anchors.fill: parent
            ToolButton {
            }
        }
    }


    ScrollView {
        anchors.top: toolBarId.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
        anchors.margins: 1

        /*Row{
            id:rulerRow
            anchors.top:parent.top
            anchors.left: parent.left
            height: 100
            spacing: 0

            Repeater{
                id:rulerRepeater
                model: timeData.totalSecond
                Rectangle{
                    property int second
                    width: 50
                    height:parent.height
                    Text{
                        text:second
                        anchors.bottom: parent.bottom
                        color: Style.textcolor
                    }
                    Rectangle{
                        width: 1
                        height: 15
                        color: Style.textcolor
                        anchors.top: parent.top
                    }
                }

            }
        }*/

        Rectangle{
            y:root.height/2
            width: Math.max(root.width, 2000)
            height: 100
            color: Style.t_shaft
            DropArea {
                anchors.fill: parent
                onDropped: function(drag) {
                    if (drag.hasUrls) {
                        var url = drag.urls[0]
                        console.log("时间轴接收到拖拽文件:", url)
                    } else {
                        console.log("拖拽没有包含文件URL")
                    }
                }
            }
        }
    }


}