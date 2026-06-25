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
                    if(mediaStatus == MediaPlayer.LoadedMedia && !materialModel){
                        totalDuration = mediaPlayer.duration
                    }
                }

            }

            MediaPlayer{
                id:timeLineMediaPlayer
                source: mediaUrl
                property bool pendingPlay: false
                property real pendingPosition: -1
                audioOutput: AudioOutput {
                    id: timeLineAudioOutput
                }
                videoOutput: VideoOutput {
                    id: timelineVideoOutput
                }

                function loadClip(time){
                    currClip = locationClip(time)
                    var clip = clips[currClip]
                    mediaUrl = clip.source
                    timeLineMediaPlayer.source = clip.source
                    var offset = (time - clip.timeLineStart) * 1000
                    var duration = (clip.end - clip.start) * 1000
                    offset = Math.max(0, Math.min(offset, duration))
                    pendingPosition = offset
                    pendingPlay = true
                }

                onPositionChanged:function(position) {
                    if (position >= Math.floor((clips[currClip].end - clips[currClip].start) * 1000) && currClip < clips.length - 1){
                        currClip++;
                        timeLineMediaPlayer.source =  clips[currClip].source;
                        timeLineMediaPlayer.position = 0;
                        timeLineMediaPlayer.play();
                        playId.isplay = true;

                    }
                    mediaPosition = clips[currClip].timeLineStart * 1000 + position;
                    progressChanged(mediaPosition/1000.0);
                }

                onMediaStatusChanged: {
                    if (mediaStatus === MediaPlayer.LoadedMedia) {
                        if (pendingPosition >= 0) {
                            timeLineMediaPlayer.position = pendingPosition
                            if (pendingPlay) {
                                timeLineMediaPlayer.play()
                                playId.isplay = true
                            }
                            pendingPosition = -1
                            pendingPlay = false
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
                    if(!materialModel)
                        mediaPlayer.position = value

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
        }else{
            currClip = locationClip(seconds)
            if (currClip === undefined || currClip < 0) return
            var clip = clips[currClip]
            var offset = (seconds - clip.timeLineStart) * 1000
            var duration = (clip.end - clip.start) * 1000
            offset = Math.max(0, Math.min(offset, duration))
            timeLineMediaPlayer.position = offset
            mediaPosition = seconds * 1000
        }
    }

    function locationClip(time){
        for(var i=0;i<clips.length;i++){
            if(clips[i].timeLineStart <=time && time <=clips[i].timeLineStart+clips[i].end-clips[i].start){
                return i
            }
        }
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

    function setTimeLineMedia(mediaClips,Duration,time){
        materialModel = true
        clips = mediaClips

        totalDuration = Duration*1000

        if (timelineVideoOutput.parent !== mediaId) {
            timelineVideoOutput.parent = mediaId
            timelineVideoOutput.anchors.fill = mediaId
            timelineVideoOutput.visible = true
        }
        timeLineMediaPlayer.loadClip(time)
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

}