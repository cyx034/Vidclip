import QtQuick
import QtQuick.Controls
import style

Item {
    id: root
    Rectangle{
        anchors.fill:parent
        color: Style.t_background
        //border.color: Style.border
        //border.width: 1
    }
    ListModel {
        id: clipModel
        // 每个元素：{ trackId, startSec, durationSec, type, sourceUrl }
    }


    ScrollView {
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOn

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