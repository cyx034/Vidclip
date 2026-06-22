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

    component MText:Text{
        color: Style.textcolor
        font.pixelSize: 15
    }

    //默认样式
    /*Item{
        id:infoItemId
        anchors.fill:parent

        // 内部属性（存储显示数据，并设置默认值）
        property string _projectName: "UnnamedProject"
        property string _projectFileLocation: "/"
        property string _resolution: "1920x1080"
        property string _frameRate: "25fps"
        property string _colorSpace: "SDR-Rec.709"
        property string _sampleRate: "44100Hz"
        property string _duration: "00:00:00:00"

        Text {
            id:titleTextId
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top:parent.top
            anchors.topMargin: 6
            text: "ItemInfomation"
            font.pixelSize: 16
            font.bold: true
            color: Style.textcolor
        }

        Rectangle{
            id:rectId
            anchors.top: titleTextId.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 6
            height: 2
            color:Style.border
        }

        GridLayout {
            anchors.top: rectId.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            columns: 2
            columnSpacing: 10
            rowSpacing: 2

            MText { text: "ProjectName: ";  }
            MText { text: infoItemId._projectName;}

            MText { text: "ProjectFileLocation: ";}
            MText { text: infoItemId._projectFileLocation;}

            MText { text: "Resolution: ";}
            MText { text: infoItemId._resolution;}

            MText { text: "FrameRate: ";}
            MText { text: infoItemId._frameRate;}

            MText { text: "ColorSpace: ";}     //色彩空间
            MText { text: infoItemId._colorSpace;}

            MText { text: "SampleRate: ";}   //采样率
            MText { text: infoItemId._sampleRate;}

            MText { text: "Duration: ";}
            MText { text: infoItemId._duration;}
        }

        // 更新函数
        function updateInfo(info) {
            if (info.projectName !== undefined) _projectName = info.projectName
            if (info.projectFileLocation !== undefined) _projectFileLocation = info.projectFileLocation
            if (info.resolution !== undefined) _resolution = info.resolution
            if (info.frameRate !== undefined) _frameRate = info.frameRate
            if (info.colorSpace !== undefined) _colorSpace = info.colorSpace
            if (info.sampleRate !== undefined) _sampleRate = info.sampleRate
            if (info.duration !== undefined) _duration = info.duration
        }

        Connections{
            //连接信号
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
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top:parent.top
            anchors.topMargin: 6
            spacing: 20

            Repeater {
                model: ["Video", "Audio", "Speed"]
                Text {
                    text: modelData
                    font.pixelSize: 16
                    color: index === labelId.currentIndex ? Style.textcolor : Style.highlight
                    TapHandler{
                        onTapped:labelId.currentIndex = index
                    }
                }
            }
        }

        // 分割线
        Rectangle {
            id:rect2Id
            anchors.top: labelRowId.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: Style.border
        }

        // 页面内容（根据当前索引切换）
        StackLayout {
            anchors.top: rect2Id.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 10
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
                MText{
                    text:"volume"
                }
            }

            // 页面3：变速
            Item {
                ColumnLayout{
                    MText {
                        text: "Mulitiple"
                    }
                    MText{
                        text:"Duration"
                    }
                }
            }
        }
    }
}
