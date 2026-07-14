import QtQuick
import QtQuick.Controls
import style
import QtMultimedia

Item {
    id: root
    property string mediaUrl: ""
    property string mediaType: ""  // "video", "audio", "image"

    signal mediaFullScreen(bool isfull)

    signal progressChanged(real seconds)

    property var materialModel: null

    property real totalDuration:0
    property real mediaPosition:0

    property var clips: []
    property int currClip: 0
    property bool _switching: false

    property bool _seeking: false

    property real zoom: 1.0
    property real zoomX: 1.0
    property real zoomY: 1.0
    property real offsetX: 0.0
    property real offsetY: 0.0
    property real rotat:0.0
    property real mvolume:0.0
    property real speed: 1.0


    onMvolumeChanged: {
        timeLineMediaPlayer.audioOutput.volume = Math.pow(10,mvolume/20)
    }


    Rectangle{
        anchors.fill:parent
        color: Style.v_background
        border.color: Style.border
        border.width: 1
    }


    Column{
        //spacing: 2
        Rectangle{
            //anchors.centerIn: parent
            id:mediaId
            width: root.width
            height: root.height-50
            color:Style.v_background
            clip:true

            MediaPlayer {
                id: mediaPlayer
                source:mediaUrl
                audioOutput: AudioOutput {
                    id: audioOutput
                    //volume: volumeControl.value
                }
                videoOutput: videoOutput

                onPositionChanged: function(position) {
                    if(!materialModel)
                        mediaPosition = position
                    //progressChanged(position / 1000.0)
                }
                onMediaStatusChanged: {
                    if(!materialModel){
                        if(mediaStatus == MediaPlayer.LoadedMedia && !materialModel){
                            totalDuration = mediaPlayer.duration
                        }
                    }
                }

            }

            MediaPlayer{
                id:timeLineMediaPlayer
                source: mediaUrl
                property bool pendingPlay: false
                property real pendingPosition: -1
                playbackRate: speed
                audioOutput: AudioOutput {
                    id: timeLineAudioOutput
                }
                videoOutput: VideoOutput {
                    id: timelineVideoOutput
                    fillMode: VideoOutput.PreserveAspectFit
                    transform: [
                        Scale { xScale: zoom; yScale: zoom
                            origin.x: timelineVideoOutput.width / 2
                            origin.y: timelineVideoOutput.height / 2},
                        Scale { xScale: zoomX; yScale: zoomY
                            origin.x: timelineVideoOutput.width / 2
                            origin.y: timelineVideoOutput.height / 2},
                        Rotation {
                            angle: rotat
                            origin.x: timelineVideoOutput.width / 2
                            origin.y: timelineVideoOutput.height / 2},
                        Translate { x: offsetX; y: offsetY }
                    ]

                }



                function loadClip(time,autoPlay = true){
                    currClip = locationClip(time)
                    if (currClip < 0) {
                        console.warn("未找到对应时间段的剪辑，忽略加载")
                        return
                    }

                    let clip = clips[currClip]
                    mediaUrl = clip.source
                    timeLineMediaPlayer.source = clip.source

                    let offsetInClip = (time - clip.timeLineStart) * 1000
                    let sourcePosition = clip.start * 1000 + offsetInClip
                    sourcePosition = Math.max(clip.start * 1000, Math.min(sourcePosition, clip.end * 1000))

                    pendingPosition = sourcePosition
                    pendingPlay = autoPlay
                }

                onPositionChanged:function(position) {
                    if (_seeking) return
                    if(clips.length === 0){
                        timeLineMediaPlayer.stop()
                        timeLineMediaPlayer.source = ""
                        mediaPosition = 0
                        progressChanged(0)
                        playId.isplay = false
                        currClip = 0
                        _switching = false
                        return
                    }else{
                        //timeLineMediaPlayer.play()
                    }

                    if (materialModel && !_switching) {
                        let currentClip = clips[currClip]
                        let relativePos = position - currentClip.start * 1000
                        let clipDuration = (currentClip.end - currentClip.start) * 1000
                        if (relativePos >= Math.floor(clipDuration)) {
                            if (currClip >= clips.length - 1) {
                                timeLineMediaPlayer.pause()
                                playId.isplay = false
                                //mediaPosition = (currentClip.timeLineStart) * 1000 + clipDuration
                                //progressChanged(mediaPosition / 1000.0)
                                return
                            } else {
                                _switching = true
                                currClip++
                                let nextClip = clips[currClip]
                                if (!nextClip) {
                                    _switching = false
                                    return
                                }
                                let newSource = nextClip.source
                                if (String(timeLineMediaPlayer.source) === String(newSource)) {
                                    timeLineMediaPlayer.position = nextClip.start * 1000
                                    timeLineMediaPlayer.play()
                                    playId.isplay = true
                                    _switching = false
                                } else {
                                    timeLineMediaPlayer.source = newSource
                                    timeLineMediaPlayer.pendingPosition = nextClip.start * 1000
                                    timeLineMediaPlayer.pendingPlay = true
                                }
                                return
                            }
                        }else{
                            let currentClip2 = clips[currClip]
                            if (!currentClip2) return

                            let relativePos2 = position - currentClip2.start * 1000
                            mediaPosition = currentClip2.timeLineStart * 1000 + relativePos2
                            //console.log("ppppppppppppppp" + position + " " +mediaPosition)
                            progressChanged(mediaPosition / 1000.0)

                        }
                    }
                }

                onMediaStatusChanged: {
                    if (materialModel && mediaStatus === MediaPlayer.LoadedMedia) {
                        if (pendingPosition >= 0) {
                            timeLineMediaPlayer.position = pendingPosition
                            if (pendingPlay) {
                                timeLineMediaPlayer.play()
                                playId.isplay = true
                            }
                            pendingPosition = -1
                            pendingPlay = false
                            _switching = false
                        }
                    }
                }

            }


            VideoOutput {
                id: videoOutput
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectFit
                visible: mediaType === "video"
            }

            Image {
                id: imageDisplay
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                visible: mediaType === "image"
                source: mediaType === "image" ? mediaUrl : ""
                asynchronous: true  //异步加载
            }

            TapHandler{
                onTapped: {
                    if(playId.isplay === true){
                        playId.isplay = false
                        if(!materialModel){
                            mediaPlayer.pause()
                        }else{
                            timeLineMediaPlayer.pause()
                        }
                    }else{
                        playId.isplay = true
                        if(!materialModel){
                            mediaPlayer.play()
                        }else{
                            timeLineMediaPlayer.play()
                        }
                    }
                }
            }
        }

        Rectangle{
            width: root.width
            height: root.height-mediaId.height
            color: Style.v_time

            Slider{
                id:timeSliderId
                width: parent.width-150
                from: 0
                to:totalDuration
                value: mediaPosition

                onMoved: {
                    if(!materialModel){
                        mediaPlayer.position = value
                        mediaPosition = value
                    }else{
                        let seconds = value / 1000
                        root.seekTo(seconds)
                    }
                }
            }
            Row{
                id:timeRow
                anchors.right: parent.right
                spacing: 5
                Label{

                    text:formatTime(mediaPosition)
                    font.pixelSize: 13
                    color: Style.textcolor
                }
                Label{
                    text:"/"
                    color: Style.textcolor
                }
                Label{
                    text:formatTime(totalDuration)
                    font.pixelSize: 13
                    color: Style.textcolor
                }
            }

            Rectangle{
                id:leftId
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: leftImageId.implicitWidth
                height: leftImageId.implicitHeight
                color: Style.v_time
                scale: 0.6
                Image {
                    id:leftImageId
                    source: "qrc:/image/double-left.svg"
                }
                TapHandler{
                    onTapped:{

                    }
                }
            }

            Rectangle{
                id:rightId
                anchors.left: leftId.right
                anchors.bottom: parent.bottom
                width: rightImageId.implicitWidth
                height: rightImageId.implicitHeight
                color: Style.v_time
                scale: 0.6
                Image {
                    id:rightImageId
                    source: "qrc:/image/double-right.svg"
                }
                TapHandler{
                    onTapped:{

                    }
                }
            }

            Rectangle{
                id:playId
                anchors.left: rightId.right
                anchors.bottom: parent.bottom
                width: playImageId.implicitWidth
                height: playImageId.implicitHeight
                color: Style.v_time
                scale: 0.6
                property bool isplay: true
                Image {
                    id:playImageId
                    source: playId.isplay?"qrc:/image/pause.svg":"qrc:/image/play.svg"
                }
                TapHandler{
                    onTapped:{
                        if(playId.isplay){
                            playId.isplay = false
                            if(!materialModel)
                                mediaPlayer.pause()
                            timeLineMediaPlayer.pause()
                        }else{
                            playId.isplay = true
                            if(!materialModel)
                                mediaPlayer.play()
                            timeLineMediaPlayer.play()
                        }
                    }
                }
            }

            Rectangle{
                id:fullId
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: fullImageId.implicitWidth
                height: fullImageId.implicitHeight
                color: Style.v_time
                scale: 0.5
                property bool fullscreenAction: false
                Image {
                    id:fullImageId
                    source: !fullId.fullscreenAction?"qrc:/image/full-screen.svg":"qrc:/image/off-screen.svg"
                }
                TapHandler{
                    onTapped:{
                        if(!fullId.fullscreenAction){
                            fullId.fullscreenAction = true
                            mediaFullScreen(true)
                        }else{
                            fullId.fullscreenAction = false
                            mediaFullScreen(false)
                        }

                    }
                }
            }

            Rectangle{
                anchors.right: fullId.left
                anchors.bottom: parent.bottom
                width: volumeImageId.implicitWidth
                height: volumeImageId.implicitHeight
                color: Style.v_time
                scale: 0.5
                Image {
                    id:volumeImageId
                    source: "qrc:/image/volume.svg"
                }
                TapHandler{
                    onTapped:{
                        volumeBarId.visible = !volumeBarId.visible

                    }
                }

                Rectangle{
                    id:volumeBarId
                    visible: false
                    anchors.bottom: parent.top
                    width: volumeId.implicitWidth+30
                    height: volumeId.implicitHeight+20
                    radius:Style.radius
                    //color: Style.v_key
                    color: Qt.rgba(0, 0, 0, 0.6)
                    Slider{
                        id:volumeId
                        //visible: false
                        anchors.centerIn: parent
                        //anchors.horizontalCenter: parent.horizontalCenter
                        width: 100
                        height: 120
                        value: materialModel?timeLineMediaPlayer.audioOutput.volume:mediaPlayer.audioOutput.volume
                        orientation: Qt.Vertical
                        from:0.0
                        to:1.0
                        onValueChanged: {
                            if(!materialModel)
                                mediaPlayer.audioOutput.volume =value
                            timeLineMediaPlayer.audioOutput.volume = value
                        }
                    }
                    Text{
                        anchors.top: volumeId.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: Style.spacing
                        text: Math.round(volumeId.value*100)
                        color: Style.textcolor
                        font.pixelSize: 15
                    }
                }

            }
        }
    }

    function seekTo(seconds) {
        if (seconds < 0) seconds = 0
        if(!materialModel){
            mediaPlayer.position = seconds * 1000
            mediaPosition = seconds * 1000
        }else{
            _seeking = true
            currClip = locationClip(seconds)
            console.log("open" + currClip)
            if (currClip < 0){
                _seeking = false
                return
            }
            let clip = clips[currClip]
            let offsetInClip = (seconds - clip.timeLineStart) * 1000
            let sourcePosition = clip.start * 1000 + offsetInClip
            let minPos = clip.start * 1000
            let maxPos = clip.end * 1000
            sourcePosition = Math.max(minPos, Math.min(sourcePosition, maxPos))

            let currentSource = timeLineMediaPlayer.source.toString()
            let targetSource = clip.source.toString()
            if (currentSource !== targetSource) {
                // 切换源，并保持当前播放状态
                timeLineMediaPlayer.source = targetSource
                timeLineMediaPlayer.pendingPosition = sourcePosition
                timeLineMediaPlayer.pendingPlay = playId.isplay   // 保持当前播放/暂停状态
            } else {
                timeLineMediaPlayer.position = sourcePosition
            }

            //timeLineMediaPlayer.position = sourcePosition
            mediaPosition = seconds * 1000
            _seeking = false
        }
    }

    function locationClip(time){
        for(let i=0;i<clips.length;i++){
            if(clips[i].timeLineStart <=time && time <=clips[i].timeLineStart+clips[i].end-clips[i].start){
                return i
            }
        }
        return -1
    }

    function setMedia(url, type) {
        materialModel = false
        mediaUrl = url
        mediaType = type
        mediaPlayer.play()
        playId.isplay = true
        //totalDuration = mediaPlayer.duration
        //console.log(totalDuration)
    }

    function setTimeLineMedia(mediaClips,Duration,time,autoPlay = true){
        materialModel = true
        clips = mediaClips

        totalDuration = Duration*1000
        if (timelineVideoOutput.parent !== mediaId) {
            timelineVideoOutput.parent = mediaId
            timelineVideoOutput.anchors.fill = mediaId
            timelineVideoOutput.visible = true
        }
        timeLineMediaPlayer.loadClip(time,autoPlay)
        //seekTo(time)
    }

    function formatTime(ms) {
        if (ms <= 0) return "00:00:00"
        let total = Math.floor(ms / 1000)
        let h = Math.floor(total / 3600)
        let m = Math.floor((total % 3600) / 60)
        let s = total % 60
        let pad = (n) => n.toString().padStart(2, "0")
        return `${pad(h)}:${pad(m)}:${pad(s)}`
    }

    function updateClipVideo(clips,totalDuration){

    }

    function videoPause(){
        timeLineMediaPlayer.pause()
        playId.isplay = false
    }
}