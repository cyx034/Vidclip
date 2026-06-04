import QtQuick
import QtQuick.Controls
import style
import QtMultimedia

Item {
    id: root
    property string mediaUrl: ""
    property string mediaType: ""  // "video", "audio", "image"

    signal mediaFullScreen(bool isfull)

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
        }

        Rectangle{
            width: root.width
            height: root.height-mediaId.height
            color: Style.v_time

            /*Button{
                width: 30
                height: 30
                icon.color: Style.v_time
                icon.source: "../image/volume.svg"

            }*/

            Slider{
                id:timeSliderId
                width: parent.width-150
                from: 0
                to:mediaPlayer.duration
                value: mediaPlayer.position

                onMoved: {
                    mediaPlayer.position = value
                }
            }
            Row{
                id:timeRow
                anchors.right: parent.right
                spacing: 5
                Label{

                    text:formatTime(mediaPlayer.position)
                    font.pixelSize: 13
                    color: Style.textcolor
                }
                Label{
                    text:"/"
                    color: Style.textcolor
                }
                Label{
                    text:formatTime(mediaPlayer.duration)
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
                    source: "../image/double-left.svg"
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
                    source: "../image/double-right.svg"
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
                    source: playId.isplay?"../image/play.svg":"../image/pause.svg"
                }
                TapHandler{
                    onTapped:{
                        if(playId.isplay){
                            playId.isplay = false
                            mediaPlayer.pause()
                        }else{
                            playId.isplay = true
                            mediaPlayer.play()
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
                    source: !fullId.fullscreenAction?"../image/full-screen.svg":"../image/off-screen.svg"
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
                    source: "../image/volume.svg"
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
                        value: mediaPlayer.audioOutput.volume
                        orientation: Qt.Vertical
                        from:0.0
                        to:1.0
                        onValueChanged: {
                            mediaPlayer.audioOutput.volume =value
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

    function setMedia(url, type) {
        mediaUrl = url
        mediaType = type
        mediaPlayer.play()
        playId.isplay = true
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