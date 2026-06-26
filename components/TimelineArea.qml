import QtQuick
import QtQuick.Controls
import style
import QtQuick.Layouts
import action
import Vidclip 1.0
import QtQuick.Shapes

Item {
    id: root

    property real pixelsPerSecond: 50
    property real totalDuration: 0
    property var materialModel: null

    signal mediaReady(var mediaSource)

    signal seekRequested(real timeSeconds)
    property bool _updatingPointer: false

    signal clipInformation(var clip)

    property var clips: []
    signal openTimeLineMedia(real time)

    signal updateDuration(real totalDuration)
    signal updateVideoPreview()

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
                id:trim_leftButton
                action: Actions.trim_left
            }
            MToolButton{
                id:trim_rightButton
                action: Actions.trim_right
            }
            MToolButton{
                id:deleteButton
                action: Actions._delete

            }

        }
        Button {
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            action: Actions._export
            display: Button.TextOnly   // 只显示文字，隐藏图标

            palette.text: Style.textcolor
            palette.buttonText: Style.textcolor
            background: Rectangle {
                color: parent.hovered ? Style.highlight : Style.background
                border.color: Style.border
                border.width: 1
                radius: 4
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
                    currentIndex:-1
                    delegate:Rectangle {
                        id:delegateRectId
                        width:model.source.duration*root.pixelsPerSecond
                        height:3*pixelsPerSecond/16*9+4
                        color: "transparent"
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
                                    clip: true
                                }
                            }
                        }
                        Rectangle{
                            id:broderId
                            anchors.fill:parent
                            border.color: (timeThumbnailViewId.currentIndex === index  || hoverId.hovered) ? "#ffffff" : "transparent"
                            radius: 10
                            border.width: 2
                            color: "transparent"
                        }
                        HoverHandler {
                            id:hoverId
                        }
                        TapHandler{
                            id:tapId
                            onTapped: (event)=> {
                                timeThumbnailViewId.currentIndex = index
                                event.accepted = true
                                clipInformation(model.source)

                                var time = (tapId.point.position.x - 3) / pixelsPerSecond
                                time = Math.max(0, Math.min(time, totalDuration))
                                openTimeLineMedia(time)
                            }
                        }

                    }
                }

                Rectangle{
                    id:timePointerId
                    width: 17
                    height: 326
                    x: 3
                    y: parent.height / 2 - height / 2+10
                    color: "transparent"
                    Rectangle{
                        width: 2
                        height: 312
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#ffffff"

                    }
                    Shape {
                        id: triangle
                        width: 17
                        height: 14
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter

                        ShapePath {
                            fillColor: "#ffffff"
                            strokeColor: "transparent"
                            startX: 0
                            startY: 0
                            PathLine { x: triangle.width; y: 0 }
                            PathLine { x: triangle.width / 2; y: triangle.height }
                            PathLine { x: 0; y: 0 }
                        }
                    }

                    DragHandler {
                        id: dragHandler
                        target: timePointerId
                        xAxis.enabled:true
                        yAxis.enabled: false
                        xAxis.minimum: 3
                        xAxis.maximum: timelineContent.width

                    }
                    onXChanged: {
                        if (!_updatingPointer) {
                            var time = (timePointerId.x - 3) / pixelsPerSecond
                            if (time < 0) time = 0
                            if (time > totalDuration) time = totalDuration
                            seekRequested(time)
                        }

                        var flickable = scrollView.contentItem
                        if (!flickable) return
                        var viewWidth = scrollView.width
                        if (viewWidth <= 0) return

                        var margin = 30
                        var leftBound = flickable.contentX + margin
                        var rightBound = flickable.contentX + viewWidth - margin

                        var newContentX = flickable.contentX
                        if (x < leftBound) {
                            newContentX = Math.max(0, x - margin)
                        } else if (x > rightBound) {
                            var maxContentX = flickable.contentWidth - viewWidth
                            newContentX = Math.min(maxContentX, x - viewWidth + margin)
                        }
                        if (newContentX !== flickable.contentX) {
                            flickable.contentX = newContentX
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
                                updateClips(videoClip)
                                updateTotalDuration()
                            }

                        } else {
                            console.log("拖拽没有包含文件URL")
                        }
                    }
                }
            }

            TapHandler{
                onTapped:(eventPoint)=> {

                    var pos = eventPoint.position
                    timePointerId.x = pos.x
                    var posInListView = pos
                    if (pos.y > videoLineId.y && pos.y<videoLineId.y+timeThumbnailViewId.height) {
                        return
                    }

                    timeThumbnailViewId.currentIndex = -1
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
            updateClips(videoClip)
            updateTotalDuration()

        }
    }

    /*Component.onCompleted: {
        setPointerPosition(0)
    }*/

    function setPointerPosition(timeSeconds) {
        if (timeSeconds < 0) timeSeconds = 0
        if (timeSeconds > totalDuration) timeSeconds = totalDuration
        var newX = timeSeconds * pixelsPerSecond + 3
        _updatingPointer = true
        timePointerId.x = newX
        _updatingPointer = false
    }

    function updateClips(videoClip){
        clips.push({source:"file://" + videoClip.source.filePath,start:videoClip.sourceOffset
                    ,end:videoClip.sourceOffset+videoClip.duration
                    ,timeLineStart:videoClip.timelineStart});
    }

    function updateTotalDuration() {
        var maxEnd = 0
        for (var i = 0; i < clipModel.count; ++i) {
            var c = clipModel.get(i).source
            var end = c.timelineStart + c.duration
            if (end > maxEnd) maxEnd = end
        }
        totalDuration = maxEnd
        updateDuration(totalDuration)
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

    function splitClip() {
        let index = timeThumbnailViewId.currentIndex
        if (index < 0 || index >= clipModel.count) {
            console.warn("没有选中剪辑")
            return
        }

        let clip = clipModel.get(index).source
        if (!clip) {
            console.warn("无效剪辑对象")
            return
        }

        let currentTime = (timePointerId.x - 3) / pixelsPerSecond
        let duration = currentTime - clip.timelineStart

        //创建左片段
        let left = Qt.createQmlObject('import Vidclip 1.0; VideoClip {}', root)
        left.source = clip.source
        left.sourceOffset = clip.sourceOffset
        left.duration = duration
        left.timelineStart = clip.timelineStart
        //left.extractPreview()

        //创建右片段
        var right = Qt.createQmlObject('import Vidclip 1.0; VideoClip {}', root)
        right.source = clip.source
        right.sourceOffset = clip.sourceOffset + duration
        right.duration = clip.duration - duration
        right.timelineStart = clip.timelineStart + duration
        //right.extractPreview()

        clipModel.remove(index)
        clipModel.insert(index, { "source": left })
        clipModel.insert(index + 1, { "source": right })
        setPointerPosition(currentTime)
    }

    function trimLeftCurrent() {
        var idx = timeThumbnailViewId.currentIndex
        if (idx < 0 || idx >= clipModel.count) {
            console.warn("没有选中剪辑")
            return
        }

        var clip = clipModel.get(idx).source
        if (!clip) {
            console.warn("无效剪辑对象")
            return
        }

        var currentTime = (timePointerId.x - 3) / pixelsPerSecond  //指针位置
        var delta = currentTime - clip.timelineStart

        clip.trimLeft(delta)

        for (var i = 0; i < clips.length; ++i) {
            if (Math.abs(clips[i].timeLineStart - clip.timelineStart) < 0.001) {
                clips[i].start = clip.sourceOffset
                clips[i].end = clip.sourceOffset + clip.duration
                clips[i].timeLineStart = clip.timelineStart
                break
            }
        }

        for (var j = idx + 1; j < clipModel.count; ++j) {
           var nextClip = clipModel.get(j).source
           if (!nextClip) continue
           nextClip.timelineStart = nextClip.timelineStart - delta
           for (var k = 0; k < clips.length; ++k) {
               if (Math.abs(clips[k].timeLineStart - (nextClip.timelineStart + delta)) < 0.001) {
                   clips[k].timeLineStart = nextClip.timelineStart
                   break
               }
           }
        }
        updateTotalDuration()
    }

    function trimRightCurrent(){
        var idx = timeThumbnailViewId.currentIndex
        if (idx < 0 || idx >= clipModel.count) {
            console.warn("没有选中剪辑")
            return
        }

        var clip = clipModel.get(idx).source
        if (!clip) {
            console.warn("无效剪辑对象")
            return
        }

        var currentTime = (timePointerId.x - 3) / pixelsPerSecond  //指针位置
        var delta = clip.timelineStart + clip.duration - currentTime

        clip.trimRight(delta)

        for (var i = 0; i < clips.length; ++i) {
            if (Math.abs(clips[i].timeLineStart - clip.timelineStart) < 0.001) {
                clips[i].start = clip.sourceOffset
                clips[i].end = clip.sourceOffset + clip.duration
                clips[i].timeLineStart = clip.timelineStart
                break
            }
        }

        for (var j = idx + 1; j < clipModel.count; ++j) {
           var nextClip = clipModel.get(j).source
           if (!nextClip) continue
           nextClip.timelineStart = nextClip.timelineStart - delta
           for (var k = 0; k < clips.length; ++k) {
               if (Math.abs(clips[k].timeLineStart - (nextClip.timelineStart + delta)) < 0.001) {
                   clips[k].timeLineStart = nextClip.timelineStart
                   break
               }
           }
        }
        updateTotalDuration()
    }
}

