import QtQuick
import QtQuick.Controls
import style
import QtQuick.Layouts
import action
import Vidclip 1.0

Item {
    id: root

    property real pixelsPerSecond: 50
    property real totalDuration: 0
    property var materialModel: null

    Rectangle{
        anchors.fill:parent
        color: Style.t_background
        border.color: Style.border
        border.width: 1
    }
    ListModel {
        id: clipModel
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
        id:scrollView
        anchors.top: toolBarId.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
        anchors.margins: 1

        contentWidth: timelineContent.width+100
        contentHeight: timelineContent.height

        Item{
            id: timelineContent
            width: Math.max(root.width, root.totalDuration * root.pixelsPerSecond)
            height: scrollView.height

            Repeater{
                model: root.totalDuration === 0?root.totalDuration:root.totalDuration + 1
                Rectangle{
                    y:timeTextId.height
                    x:index*root.pixelsPerSecond + 10
                    width: 1

                    height: index%5 === 0?14:6
                    color: Style.textcolor

                    Text{
                        id:timeTextId
                        anchors.bottom:parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:index
                        visible: parent.height===14?true:false
                        color: Style.textcolor
                    }
                }
            }

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



            /*ListView {
                id: timeThumbnailViewId
                anchors.fill: parent
                orientation: ListView.Horizontal
                model: clipModel
                spacing: 4

                delegate: Rectangle {
                    width: 200
                    height: 100
                    clip: true

                    Row {
                        anchors.fill: parent
                        spacing: 0

                        // 只有缩略图数组非空时才显示
                        visible: model.thumbnailUrls && model.thumbnailUrls.length > 0

                        Repeater {
                            model: model.thumbnailUrls
                            delegate: Image {
                                required property int index
                                width: parent.width / model.length
                                height: parent.height
                                source:        // 数组元素就是缩略图 URL
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: false
                            }
                        }
                    }
                }
            }*/



            Rectangle{
                id:videoLineId
                y:root.height/2-height
                width: timelineContent.width+100
                height: 100
                color: Style.t_shaft

                ListView{
                    id: timeThumbnailViewId
                    anchors.fill: parent
                    orientation: ListView.Horizontal
                    model: clipModel
                    delegate:Rectangle {
                        width:model.source.duration*root.pixelsPerSecond
                        height:100
                        color: hoverId.hovered?"#8191c7":"#525c7e"
                        HoverHandler {
                            id:hoverId
                        }

                    }
                }


                DropArea {
                    anchors.fill: parent
                    onDropped: function(drag) {
                        if (drag.hasUrls) {
                            var url = drag.urls[0]
                            console.log("时间轴接收到拖拽文件:", url)
                            var filePath = url.toString()
                            if (filePath.startsWith("file://")){
                                filePath = filePath.substring(7)
                            }
                            var mediaSource = null
                            if (materialModel) {
                                for (var i = 0; i < materialModel.count; ++i) {
                                    var item = materialModel.get(i)
                                    if (item.source && item.source.filePath === filePath) {
                                        mediaSource = item.source
                                        break
                                    }
                                }
                            }
                            if (!mediaSource) {
                                console.warn("未在素材库中找到:", filePath)
                                return
                            }
                            var helper = Qt.createQmlObject('import Vidclip 1.0; VideoClip {}', root)
                            var videoClip = helper.fromMediaSource(mediaSource)
                            helper.destroy()

                            videoClip.timelineStart = totalDuration
                            clipModel.append({
                                "source":videoClip
                            })
                            updateTotalDuration()

                        } else {
                            console.log("拖拽没有包含文件URL")
                        }
                    }
                }
            }
        }
    }

    function updateTotalDuration() {
        var maxEnd = 0
        for (var i = 0; i < clipModel.count; ++i) {
            var c = clipModel.get(i).source
            var end = c.timelineStart + c.duration
            if (end > maxEnd) maxEnd = end
        }
        totalDuration = maxEnd
    }

/*    function addMediaItem(fileUrl,count) {
        let filePath = fileUrl.toString()
        if (filePath.startsWith("file://"))
            filePath = filePath.substring(7)
        let parts = filePath.split('/')
        let fileName = parts[parts.length - 1]

        let fileType = getFileType(fileName)   // 返回 "video", "audio", "image"

        if (fileType === "video") {

            let thumbnailer = Qt.createQmlObject('import Vidclip 1.0; VideoThumbnailer {}', root)
            if (thumbnailer === null) {
                console.error("创建 VideoThumbnailer 失败，请检查注册");
                return;
            }
            thumbnailer.thumbnailsReady.connect(function(path, urls) {
                clipModel.append({
                    trackId: 0,
                    startSec: 0,        // 起始时间可根据鼠标位置计算，此处先设为0
                    durationSec: 2.0,   // 默认时长2秒，可后期改为真实时长
                    sourceUrl: fileUrl,
                    name: fileName,
                    thumbnailUrls: urls  // 存储缩略图列表，供委托使用
                })
                //clipModel.append(0, 0.0, 2.0, fileUrl, fileName, urls)
                console.log(urls)
                console.log(clipModel.thumbnailUrls)
                thumbnailer.destroy()
            });

            thumbnailer.thumbnailsFailed.connect(function(path, error) {
                console.error("缩略图生成失败:", filePath, error);

                thumbnailer.destroy()
            });
            thumbnailer.generateThumbnails(filePath,count)
        }
        /*if (fileType === "image") {
            materialModel.append({
                name: fileName,
                path: filePath,
                type: fileType,
                thumbnail: fileUrl.toString()
            })
        }else if(fileType === "audio"){
            materialModel.append({
                name: fileName,
                path: filePath,
                type: fileType,
                thumbnail: "../image/music.png"
            })
        }
    }

    function getFileType(fileName) {
        let ext = fileName.split('.').pop().toLowerCase()
        if (["mp4", "mov", "mkv", "avi", "flv"].includes(ext)) return "video"
        if (["mp3", "wav", "flac", "aac", "ogg"].includes(ext)) return "audio"
        if (["jpg", "jpeg", "png", "gif", "bmp", "svg"].includes(ext)) return "image"
        return "unknown}
*/
}

