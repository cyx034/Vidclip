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

    signal mediaReady(var mediaSource)

    Rectangle{
        anchors.fill:parent
        color: Style.t_background
        border.color: Style.border
        border.width: 1
    }
    ListModel {
        id: clipModel
    }


    component MToolButton:ToolButton{
        checkable: true
        // 设置字体大小
        font.pixelSize: Style.fontSizeNormal
        // 设置文本颜色 (通过palette)
        palette.text: Style.textcolor
        palette.buttonText: Style.textcolor
        icon.width: 28
        icon.height: 28
        background: Rectangle{
            color: hoverId.hovered?Style.highlight : Style.surface
        }

        HoverHandler{
            id:hoverId
        }
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
            spacing: 7
            MToolButton {
                id:undoButton
                action: Actions._undo
            }
            MToolButton{
                id:redoButton
                action: Actions._redo
            }
            MToolButton{
                id:splitButton
                action: Actions._split
            }
            MToolButton{
                id:trim_rightButton
                action: Actions.trim_right
            }
            MToolButton{
                id:trim_leftButton
                action: Actions.trim_left
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

            Rectangle{
                id:videoLineId
                y:root.height/2-height
                width: timelineContent.width+100
                height: 3*pixelsPerSecond/16*9+4
                color: Style.t_shaft

                ListView{
                    id: timeThumbnailViewId
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    orientation: ListView.Horizontal
                    model: clipModel
                    delegate:Rectangle {
                        width:model.source.duration*root.pixelsPerSecond
                        height:3*pixelsPerSecond/16*9+4
                        color: "transparent"
                        border.color: hoverId.hovered?"#ffffff":"transparent"
                        border.width: 2
                        property var urls: model.source.urls
                        Row{
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            Repeater{
                                model:urls
                                Image{
                                    width: 3*pixelsPerSecond
                                    height:width/16*9
                                    source:modelData
                                    fillMode: Image.PreserveAspectCrop
                                    //clip: true
                                }
                            }
                        }

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


                            if (mediaSource.urls.length <= 0) {
                                timeLinePreview(mediaSource)
                            }else{

                                console.log(mediaSource.m_urls)

                                var helper = Qt.createQmlObject('import Vidclip 1.0; VideoClip {}', root)
                                var videoClip = helper.fromMediaSource(mediaSource)
                                helper.destroy()

                                videoClip.timelineStart = totalDuration
                                clipModel.append({
                                    "source":videoClip
                                })
                                updateTotalDuration()
                            }

                        } else {
                            console.log("拖拽没有包含文件URL")
                        }
                    }
                }
            }
        }
    }

    Connections{
        target: root
        function onMediaReady(mediaSource){
            var helper = Qt.createQmlObject('import Vidclip 1.0; VideoClip {}', root)
            var videoClip = helper.fromMediaSource(mediaSource)
            helper.destroy()

            videoClip.timelineStart = totalDuration
            clipModel.append({
                "source":videoClip
            })
            updateTotalDuration()

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

    function timeLinePreview(mediaSource){
        var totalImage = parseInt(mediaSource.duration / 3);
        if (mediaSource.fileType === "video") {

            let thumbnailer = Qt.createQmlObject('import Vidclip 1.0; VideoThumbnailer {}', root)
            if (thumbnailer === null) {
                console.error("创建 VideoThumbnailer 失败，请检查注册");
                return;
            }
            thumbnailer.thumbnailsReady.connect(function(filePath,urls) {
                mediaSource.urls = urls
                console.log(mediaSource.urls)
                thumbnailer.destroy()
                mediaReady(mediaSource)
            });

            thumbnailer.thumbnailsFailed.connect(function(path, error) {
                console.error("缩略图生成失败:", filePath, error);
                thumbnailer.destroy()
            });
            thumbnailer.generateThumbnails(mediaSource.filePath,totalImage)
        }
        if (mediaSource.fileType === "image") {
            mediaSource.urls = fileUrl.toString()
            mediaReady(mediaSource)
        }else if(mediaSource.fileType === "audio"){
            mediaSource.urls = "qrc:/image/music.png"
            mediaReady(mediaSource)
        }
    }

}

