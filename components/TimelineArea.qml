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
    signal timelineDataUpdated(var updatedClips, real duration, real seekTime)

    signal seekPause()
    property int maxUndoStack: 20
    property var undoStack: []
    property var redoStack: []

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
        //设置字体大小
        font.pixelSize: Style.fontSizeNormal
        //设置文本颜色 (通过palette)
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
            MToolButton{
                id:copyButton
                action: Actions._copy
            }
        }
        Button {
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            action: Actions._export
            display: Button.TextOnly   //只显示文字，隐藏图标

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

                //移动位置指示线
                Rectangle {
                    id: dropIndicator
                    visible: false
                    width: 3
                    height: parent.height
                    color: "#4CAF50"  //绿色
                    radius: 2
                    x: 0
                    z: 10
                }

                Rectangle {
                    id: dragClone
                    visible: false
                    z: 100
                    color: "transparent"
                    property int sourceIndex: -1

                    Row {
                        anchors.fill: parent
                        Repeater {
                            model: dragClone.visible ? clipModel.get(dragClone.sourceIndex)?.source?.urls || [] : []
                            Image {
                                width: dragClone.height / 16 * 9
                                height: dragClone.height
                                source: modelData
                                fillMode: Image.PreserveAspectCrop
                                clip: true
                            }
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        border.color: "#FFFFFF"
                        radius: 10
                        border.width: 4
                        color: Qt.rgba(255,255, 255, 0.2)
                    }
                }

                ListView{
                    id: timeThumbnailViewId
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    orientation: ListView.Horizontal
                    model: clipModel
                    currentIndex:-1
                    spacing: 0

                    property var dropIndicatorRef: dropIndicator
                    property var dragCloneRef: dragClone
                    property int dragFromIndex: -1
                    property int dragToIndex: -1
                    property real dragStartX: 0

                    delegate: Rectangle {
                        id: delegateRectId
                        width: model.source.duration * root.pixelsPerSecond
                        height: 3 * pixelsPerSecond / 16 * 9 + 4
                        color: "transparent"
                        property var urls: model.source.urls
                        property bool isDragging: false
                        property real originalX: 0
                        property real pressX: 0
                        property real pressY: 0

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            Repeater {
                                model: urls
                                Image {
                                    width: 3 * pixelsPerSecond
                                    height: width / 16 * 9
                                    source: modelData
                                    fillMode: Image.PreserveAspectCrop
                                    clip: true
                                }
                            }
                        }

                        Rectangle {
                            id: borderId
                            anchors.fill: parent
                            border.color: (timeThumbnailViewId.currentIndex === index || hoverId.hovered) ? "#ffffff" : "transparent"
                            radius: 10
                            border.width: 2
                            color: "transparent"
                        }

                        DragHandler {
                            id: dragHandler
                            target: null
                            xAxis.enabled: true
                            yAxis.enabled: false
                            grabPermissions: PointerHandler.CanTakeOverFromHandlersOfDifferentType |
                                             PointerHandler.CanTakeOverFromItems

                            property real dragStartX: 0
                            property int fromIndex: index
                            property bool hasMoved: false
                            property real startX: 0

                            onActiveChanged: {
                                if (active) {
                                    //开始拖拽
                                    hasMoved = false
                                    fromIndex = index
                                    startX = delegateRectId.x
                                    delegateRectId.isDragging = true
                                    delegateRectId.originalX = delegateRectId.x
                                    timeThumbnailViewId.currentIndex = index
                                    clipInformation(model.source)

                                    timeThumbnailViewId.dragFromIndex = index
                                    timeThumbnailViewId.dragStartX = delegateRectId.x

                                    timeThumbnailViewId.dragCloneRef.visible = true
                                    timeThumbnailViewId.dragCloneRef.sourceIndex = index
                                    timeThumbnailViewId.dragCloneRef.x = delegateRectId.x
                                    timeThumbnailViewId.dragCloneRef.y = delegateRectId.y
                                    timeThumbnailViewId.dragCloneRef.width = delegateRectId.width
                                    timeThumbnailViewId.dragCloneRef.height = delegateRectId.height

                                    delegateRectId.opacity = 0.4

                                    pushUndoState()
                                    console.log("开始拖拽:", index)
                                } else {
                                    finishDrag()
                                }
                            }

                            onTranslationChanged: {
                                let deltaX = translation.x
                                let distance = Math.abs(deltaX)

                                if (distance > 5) {
                                    hasMoved = true
                                }

                                if (!hasMoved) return

                                let newX = startX + deltaX
                                if (newX < 0) newX = 0

                                timeThumbnailViewId.dragCloneRef.x = newX

                                let centerX = newX + delegateRectId.width / 2
                                let targetIndex = timeThumbnailViewId.indexAt(centerX + 10, 0)

                                if (targetIndex < 0 || targetIndex === index) {
                                    let lastItem = timeThumbnailViewId.itemAtIndex(clipModel.count - 1)
                                    if (lastItem && newX > lastItem.x + lastItem.width) {
                                        targetIndex = clipModel.count
                                    } else {
                                        targetIndex = index
                                    }
                                }

                                //更新移动显示线
                                if (targetIndex >= 0 && targetIndex !== index) {
                                    let targetX = 10
                                    if (targetIndex < clipModel.count) {
                                        let targetItem = timeThumbnailViewId.itemAtIndex(targetIndex)
                                        if (targetItem) {
                                            targetX = targetItem.x + 10
                                        }
                                    } else {
                                        let lastItem = timeThumbnailViewId.itemAtIndex(clipModel.count - 1)
                                        if (lastItem) {
                                            targetX = lastItem.x + 10 + lastItem.width
                                        }
                                    }
                                    timeThumbnailViewId.dropIndicatorRef.visible = true
                                    timeThumbnailViewId.dropIndicatorRef.x = targetX - 1
                                    timeThumbnailViewId.dragToIndex = targetIndex
                                } else {
                                    timeThumbnailViewId.dropIndicatorRef.visible = false
                                    timeThumbnailViewId.dragToIndex = -1
                                }
                            }

                            function finishDrag() {
                                timeThumbnailViewId.dragCloneRef.visible = false
                                delegateRectId.opacity = 1.0
                                delegateRectId.isDragging = false
                                timeThumbnailViewId.dropIndicatorRef.visible = false

                                if (hasMoved) {
                                    let fromIndex = timeThumbnailViewId.dragFromIndex
                                    let toIndex = timeThumbnailViewId.dragToIndex

                                    if (fromIndex >= 0 && toIndex >= 0 && fromIndex !== toIndex) {
                                        clipModel.move(fromIndex, toIndex, 1)
                                        updateClipsTimeline()
                                        updateTotalDuration()

                                        let seekTime = (delegateRectId.originalX + dragHandler.translation.x) / pixelsPerSecond
                                        if (seekTime < 0) seekTime = 0
                                        if (seekTime > totalDuration) seekTime = totalDuration

                                        syncDataToPreview(seekTime)
                                        setPointerPosition(seekTime)
                                        timeThumbnailViewId.currentIndex = toIndex
                                        seekRequested(seekTime)
                                        console.log("片段从", fromIndex, "移动到", toIndex)
                                    } else {
                                        //拖拽无效，取消undo
                                        if (undoStack.length > 0) {
                                            undoStack.pop()
                                            updateUndoButtons()
                                        }
                                        delegateRectId.x = delegateRectId.originalX
                                    }
                                } else {
                                    if (undoStack.length > 0) {
                                        undoStack.pop()
                                        updateUndoButtons()
                                    }
                                    delegateRectId.x = delegateRectId.originalX
                                }

                                timeThumbnailViewId.dragFromIndex = -1
                                timeThumbnailViewId.dragToIndex = -1
                                console.log("释放完成")
                            }
                        }


                        TapHandler {
                            id: tapHandler
                            acceptedButtons: Qt.LeftButton
                            grabPermissions: PointerHandler.CanTakeOverFromHandlersOfDifferentType |
                                             PointerHandler.CanTakeOverFromItems

                            onTapped: function(eventPoint) {
                                if (dragHandler.active || delegateRectId.isDragging) return

                                console.log("点击片段:", index)

                                //选中片段
                                timeThumbnailViewId.currentIndex = index
                                clipInformation(model.source)

                                //计算点击位置
                                let localX = eventPoint.position.x
                                let absoluteX = delegateRectId.x + 10 + localX

                                //计算时间
                                let time = (absoluteX - 3) / pixelsPerSecond
                                time = Math.max(0, Math.min(time, totalDuration))

                                //移动指针
                                timePointerId.x = absoluteX

                                console.log("点击位置:", "absoluteX:", absoluteX, "time:", time)

                                openTimeLineMedia(time)
                                setPointerPosition(time)
                                seekRequested(time)

                                //确保undo被取消（如果之前有保存的话）
                                if (undoStack.length > 0) {
                                    undoStack.pop()
                                    updateUndoButtons()
                                }
                            }
                        }

                        HoverHandler {
                            id: hoverId
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
                        id: dragHandlerId
                        target: timePointerId
                        xAxis.enabled:true
                        yAxis.enabled: false
                        xAxis.minimum: 3
                        xAxis.maximum: timelineContent.width

                    }
                    onXChanged: {
                        if (!_updatingPointer) {
                            let time = (timePointerId.x - 3) / pixelsPerSecond
                            if (time < 0) time = 0
                            if (time > totalDuration) time = totalDuration
                            seekRequested(time)
                        }

                        let flickable = scrollView.contentItem
                        if (!flickable) return
                        let viewWidth = scrollView.width
                        if (viewWidth <= 0) return

                        let margin = 30
                        let leftBound = flickable.contentX + margin
                        let rightBound = flickable.contentX + viewWidth - margin

                        let newContentX = flickable.contentX
                        if (x < leftBound) {
                            newContentX = Math.max(0, x - margin)
                        } else if (x > rightBound) {
                            let maxContentX = flickable.contentWidth - viewWidth
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
                            let url = drag.urls[0]
                            let filePath = url.toString()
                            if (filePath.startsWith("file://"))
                                filePath = filePath.substring(7)
                            let mediaSource = null
                            if (materialModel) {
                                for (let i = 0; i < materialModel.count; ++i) {
                                    let item = materialModel.get(i)
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
                                return
                            } else {
                                let helper = Qt.createQmlObject('import Vidclip 1.0; VideoClip {}', root)
                                let videoClip = helper.fromMediaSource(mediaSource)
                                helper.destroy()
                                var oldTotal = totalDuration
                                videoClip.timelineStart = oldTotal
                                clipModel.append({ "source": videoClip })
                                updateTotalDuration()
                                setPointerPosition(oldTotal)
                                syncDataToPreview(oldTotal)
                            }
                        } else {
                            console.log("拖拽没有包含文件URL")
                        }
                    }
                }

            }

            TapHandler {
                id: timelineTapHandler
                acceptedButtons: Qt.LeftButton
                onTapped: (eventPoint)=> {
                    let pos = eventPoint.position
                    let time = (pos.x - 3) / pixelsPerSecond
                    time = Math.max(0, Math.min(time, totalDuration))

                    //检查是否点击在视频轨道上的片段区域
                    if (pos.y > videoLineId.y && pos.y < videoLineId.y + timeThumbnailViewId.height) {
                        //检查是否点击在某个片段上
                        let clickedIndex = timeThumbnailViewId.indexAt(pos.x - 10, 0)
                        if (clickedIndex >= 0 && clickedIndex < clipModel.count) {
                            //由 delegate 的 TapHandler 处理
                            return
                        }
                    }

                    //点击在空白区域，移动指针并跳转
                    timePointerId.x = pos.x
                    timeThumbnailViewId.currentIndex = -1
                    pushUndoState()
                    //确保时间不超出范围
                    time = (pos.x - 3) / pixelsPerSecond
                    time = Math.max(0, Math.min(time, totalDuration))

                    openTimeLineMedia(time)
                    setPointerPosition(time)
                    seekRequested(time)
                }
            }
        }
    }

    //更新所有片段的时间轴位置（按顺序排列）
    function updateClipsTimeline() {
        let currentTime = 0
        for (let i = 0; i < clipModel.count; i++) {
            let clip = clipModel.get(i).source
            clip.timelineStart = currentTime
            currentTime += clip.duration / clip.speed
        }
    }

    //从 clipModel 重建 clips 数组
    function buildClipsFromModel() {
        var newClips = []
        for (var i = 0; i < clipModel.count; ++i) {
            var c = clipModel.get(i).source
            newClips.push({
                source: "file://" + c.source.filePath,
                start: c.sourceOffset,
                end: c.sourceOffset + c.duration,
                timeLineStart: c.timelineStart,
                videoClip: c
            })
        }
        return newClips
    }

    //同步数据到预览组件，同时更新 root.clips
    function syncDataToPreview(seekTime) {
        var newClips = buildClipsFromModel()
        root.clips = newClips
        timelineDataUpdated(newClips, totalDuration, seekTime)
    }

    Connections {
        target: root
        function onMediaReady(mediaSource) {
            let helper = Qt.createQmlObject('import Vidclip 1.0; VideoClip {}', root)
            let videoClip = helper.fromMediaSource(mediaSource)
            helper.destroy()

            var oldTotal = totalDuration
            videoClip.timelineStart = oldTotal
            clipModel.append({ "source": videoClip })
            updateTotalDuration()
            setPointerPosition(oldTotal)
            syncDataToPreview(oldTotal)
        }
    }

    /*Component.onCompleted: {
        setPointerPosition(0)
    }*/

    function setPointerPosition(timeSeconds) {
        //console.log("ooooooooooooo" + timeSeconds)
        if (timeSeconds < 0) timeSeconds = 0
        if (timeSeconds > totalDuration) timeSeconds = totalDuration
        let newX = timeSeconds * pixelsPerSecond + 3
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
        let maxEnd = 0
        for (let i = 0; i < clipModel.count; ++i) {
            let c = clipModel.get(i).source
            let effectiveDuration = c.duration / c.speed
            let end = c.timelineStart + effectiveDuration
            if (end > maxEnd) maxEnd = end
        }
        totalDuration = maxEnd
        updateDuration(totalDuration)
    }

    function timeLinePreview(mediaSource){
        let totalImage = parseInt(mediaSource.duration / 3);
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
        pushUndoState()
        let currentTime = (timePointerId.x - 3) / pixelsPerSecond
        let duration = currentTime - clip.timelineStart

        let left = Qt.createQmlObject('import Vidclip 1.0; VideoClip {}', root)
        left.source = clip.source
        left.sourceOffset = clip.sourceOffset
        left.duration = duration
        left.timelineStart = clip.timelineStart
        left.extractPreview()

        let right = Qt.createQmlObject('import Vidclip 1.0; VideoClip {}', root)
        right.source = clip.source
        right.sourceOffset = clip.sourceOffset + duration
        right.duration = clip.duration - duration
        right.timelineStart = clip.timelineStart + duration
        right.extractPreview()

        clipModel.remove(index)
        clipModel.insert(index, { "source": left })
        clipModel.insert(index + 1, { "source": right })

        updateClipsTimeline()
        updateTotalDuration()
        setPointerPosition(currentTime)
        syncDataToPreview(currentTime)
    }

    function trimLeftCurrent() {
        let idx = timeThumbnailViewId.currentIndex
        if (idx < 0 || idx >= clipModel.count) {
            console.warn("没有选中剪辑")
            return
        }
        pushUndoState()

        let clip = clipModel.get(idx).source
        if (!clip) {
            console.warn("无效剪辑对象")
            return
        }

        let currentTime = (timePointerId.x - 3) / pixelsPerSecond
        let delta = currentTime - clip.timelineStart

        clip.trimLeft(delta)

        for (let j = idx + 1; j < clipModel.count; ++j) {
            let nextClip = clipModel.get(j).source
            if (!nextClip) continue
            nextClip.timelineStart = nextClip.timelineStart - delta
        }
        updateClipsTimeline()
        updateTotalDuration()
        setPointerPosition(currentTime)
        syncDataToPreview(currentTime)
    }

    function trimRightCurrent() {
        let idx = timeThumbnailViewId.currentIndex
        if (idx < 0 || idx >= clipModel.count) {
            console.warn("没有选中剪辑")
            return
        }
        pushUndoState()

        let clip = clipModel.get(idx).source
        if (!clip) {
            console.warn("无效剪辑对象")
            return
        }

        let currentTime = (timePointerId.x - 3) / pixelsPerSecond
        let delta = clip.timelineStart + clip.duration - currentTime

        clip.trimRight(delta)

        for (let j = idx + 1; j < clipModel.count; ++j) {
            let nextClip = clipModel.get(j).source
            if (!nextClip) continue
            nextClip.timelineStart = nextClip.timelineStart - delta
        }
        updateClipsTimeline()
        updateTotalDuration()
        setPointerPosition(currentTime)
        syncDataToPreview(currentTime)
    }


    function deleteSelectedClip() {
        let index = timeThumbnailViewId.currentIndex
        if (index < 0 || index >= clipModel.count) {
            console.warn("请先在时间轴上点击选中一个剪辑")
            return
        }
        pushUndoState()
        let deletedClip = clipModel.get(index).source
        let deletedDuration = deletedClip.duration / deletedClip.speed
        clipModel.remove(index)
        for (let i = index; i < clipModel.count; i++) {
            let nextClip = clipModel.get(i).source
            if (!nextClip) continue
            nextClip.timelineStart = nextClip.timelineStart - deletedDuration
            if (nextClip.timelineStart < 0) nextClip.timelineStart = 0
        }
        updateClipsTimeline()
        updateTotalDuration()
        timeThumbnailViewId.currentIndex = -1
        if (clipModel.count === 0) {
            timelineDataUpdated([], 0, 0)
            setPointerPosition(0)
            seekRequested(0)
            return
        }
        var seekTime = 0
        if (index > 0 && (index - 1) < clipModel.count) {
            let preClip = clipModel.get(index - 1).source
            if (preClip) {
                seekTime = preClip.timelineStart + preClip.duration / preClip.speed
            } else {
                seekTime = 0
            }
        } else {
            let firstClip = clipModel.get(0).source
            if (firstClip) {
                seekTime = firstClip.timelineStart
            } else {
                seekTime = 0
            }
        }
        setPointerPosition(seekTime)
        syncDataToPreview(seekTime)
    }

    function pushUndoState() {
        var state = saveClipState()
        undoStack.push(state)
        if (undoStack.length > maxUndoStack) {
            undoStack.shift()
        }
        redoStack = []
        updateUndoButtons()
    }

    function saveClipState() {
        var clipsData = []
        for (var i = 0; i < clipModel.count; i++) {
            var clip = clipModel.get(i).source
            clipsData.push({
                source: clip.source ? clip.source.filePath : "",
                sourceOffset: clip.sourceOffset,
                duration: clip.duration,
                timelineStart: clip.timelineStart,
                speed: clip.speed,
                scale: clip.scale,
                scaleX: clip.scaleX,
                scaleY: clip.scaleY,
                offsetX: clip.offsetX,
                offsetY: clip.offsetY,
                rotation: clip.rotation,
                volume: clip.volume,
                uniformScale: clip.uniformScale
            })
        }
        return {
            clips: clipsData,
            _pointerTime: (timePointerId.x - 3) / pixelsPerSecond
        }
    }

    function restoreClipState(state) {
        var pointerTime = state._pointerTime || 0
        var clipsData = state.clips || []
        clipModel.clear()
        clips = []
        for (var i = 0; i < clipsData.length; i++) {
            var s = clipsData[i]
            var mediaSource = null
            if (materialModel) {
                for (var j = 0; j < materialModel.count; j++) {
                    var item = materialModel.get(j)
                    if (item.source && item.source.filePath === s.source) {
                        mediaSource = item.source
                        break
                    }
                }
            }
            if (mediaSource) {
                var helper = Qt.createQmlObject('import Vidclip 1.0; VideoClip {}', root)
                var clip = helper.fromMediaSource(mediaSource)
                helper.destroy()
                clip.sourceOffset = s.sourceOffset
                clip.duration = s.duration
                clip.timelineStart = s.timelineStart
                clip.speed = s.speed !== undefined ? s.speed : 1.0
                clip.scale = s.scale !== undefined ? s.scale : 100.0
                clip.scaleX = s.scaleX !== undefined ? s.scaleX : 100.0
                clip.scaleY = s.scaleY !== undefined ? s.scaleY : 100.0
                clip.offsetX = s.offsetX !== undefined ? s.offsetX : 0.0
                clip.offsetY = s.offsetY !== undefined ? s.offsetY : 0.0
                clip.rotation = s.rotation !== undefined ? s.rotation : 0.0
                clip.volume = s.volume !== undefined ? s.volume : 1.0
                clip.uniformScale = s.uniformScale !== undefined ? s.uniformScale : true
                clip.extractPreview()
                clipModel.append({ "source": clip })
                clips.push({
                    source: "file://" + clip.source.filePath,
                    start: clip.sourceOffset,
                    end: clip.sourceOffset + clip.duration,
                    timeLineStart: clip.timelineStart,
                    videoClip: clip
                })
            }
        }
        updateTotalDuration()
        return pointerTime
    }

    function undo() {
        if (undoStack.length === 0) return
        redoStack.push(saveClipState())
        var state = undoStack.pop()
        var pointerTime = restoreClipState(state)
        updateUndoButtons()
        if (clipModel.count > 0) {
            if (pointerTime > totalDuration) pointerTime = totalDuration
            if (pointerTime < 0) pointerTime = 0
            timelineDataUpdated(clips, totalDuration, pointerTime)
            setPointerPosition(pointerTime)
            seekRequested(pointerTime)
        } else {
            timelineDataUpdated([], 0, 0)
            setPointerPosition(0)
            seekRequested(0)
        }
    }

    function redo() {
        if (redoStack.length === 0) return
        undoStack.push(saveClipState())
        var state = redoStack.pop()
        var pointerTime = restoreClipState(state)
        updateUndoButtons()
        if (clipModel.count > 0) {
            if (pointerTime > totalDuration) pointerTime = totalDuration
            if (pointerTime < 0) pointerTime = 0
            timelineDataUpdated(clips, totalDuration, pointerTime)
            setPointerPosition(pointerTime)
            seekRequested(pointerTime)
        } else {
            timelineDataUpdated([], 0, 0)
            setPointerPosition(0)
            seekRequested(0)
        }
    }

    function updateUndoButtons() {
        Actions._undo.enabled = undoStack.length > 0
        Actions._redo.enabled = redoStack.length > 0
    }

    function clearHistory() {
        undoStack = []
        redoStack = []
        updateUndoButtons()
    }
    function copySelectedClip() {
        let index = timeThumbnailViewId.currentIndex
        if (index < 0 || index >= clipModel.count) {
            console.warn("请先在时间轴上点击选中一个剪辑")
            return
        }
        let sourceClip = clipModel.get(index).source
        if (!sourceClip) {
            console.warn("无效剪辑对象")
            return
        }
        pushUndoState()
        let helper = Qt.createQmlObject('import Vidclip 1.0; VideoClip {}', root)
        let newClip = helper.fromMediaSource(sourceClip.source)
        helper.destroy()
        if (!newClip) {
            console.warn("创建剪辑副本失败")
            return
        }
        newClip.sourceOffset = sourceClip.sourceOffset
        newClip.duration = sourceClip.duration
        newClip.speed = sourceClip.speed
        newClip.scale = sourceClip.scale
        newClip.scaleX = sourceClip.scaleX
        newClip.scaleY = sourceClip.scaleY
        newClip.offsetX = sourceClip.offsetX
        newClip.offsetY = sourceClip.offsetY
        newClip.rotation = sourceClip.rotation
        newClip.volume = sourceClip.volume
        newClip.uniformScale = sourceClip.uniformScale
        let originalEnd = sourceClip.timelineStart + sourceClip.duration / sourceClip.speed
        newClip.timelineStart = originalEnd
        newClip.extractPreview()
        clipModel.insert(index + 1, { "source": newClip })
        let insertedDuration = newClip.duration / newClip.speed
        for (let i = index + 2; i < clipModel.count; i++) {
            let nextClip = clipModel.get(i).source
            if (!nextClip) continue
            nextClip.timelineStart = nextClip.timelineStart + insertedDuration
        }
        updateTotalDuration()
        timeThumbnailViewId.currentIndex = index + 1
        let seekTime = newClip.timelineStart
        setPointerPosition(seekTime)
        syncDataToPreview(seekTime)
        clipInformation(newClip)
    }
}

