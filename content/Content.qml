import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import action

Item {
    id:centralId
    anchors.fill:parent

    property string currentMediaUrl: ""
    property string currentMediaType: ""

    property bool previewFullscreen: false
    property Window rootWindow: Window.window

    property alias materialBin:materialBin

    property var clip:[]

    RowLayout{
        anchors.fill: parent
        ColumnLayout{

            RowLayout{
                Layout.fillWidth: true
                Layout.fillHeight: true

                MaterialBin{
                    id:materialBin
                    Layout.preferredWidth: 440
                    Layout.fillHeight: true
                    visible: !previewFullscreen
                    onMediaSelected: function(fileUrl,fileType){
                        currentMediaUrl = fileUrl
                        currentMediaType = fileType
                        videoPreview.setMedia(fileUrl, fileType)
                    }
                }

                VideoPreview{
                    id:videoPreview
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onMediaFullScreen: function(isfull){
                        previewFullscreen = isfull
                        if(isfull){
                            if(rootWindow.menuBar){
                                rootWindow.menuBar.visible = !isfull

                            }
                            rootWindow.showFullScreen()
                        }else{
                            if(rootWindow.menuBar){
                                rootWindow.menuBar.visible = !isfull

                            }
                            rootWindow.showNormal()
                        }
                    }
                }
            }

            TimelineArea{
                id: timelineAreaId
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                visible: !previewFullscreen
                materialModel: materialBin.materialModel
                onTotalDurationChanged: {

                    videoPreview.totalDuration = totalDuration*1000
                }
            }

        }
        ParameterPanel{
            id:parameterPanelId
            Layout.preferredWidth: 320
            Layout.fillHeight: true
            visible: !previewFullscreen

        }
    }

    function clearVideoPreview() {
        videoPreview.materialModel = false
        videoPreview.mediaUrl = ""
        videoPreview.mediaType = ""
        videoPreview.totalDuration = 0
        videoPreview.clips = []
        videoPreview.currClip = 0
        videoPreview._switching = false
        videoPreview.mediaPosition = 0

        if (videoPreview.timeLineMediaPlayer) {
            videoPreview.timeLineMediaPlayer.stop()
            videoPreview.timeLineMediaPlayer.source = ""
        }
        if (videoPreview.mediaPlayer) {
            videoPreview.mediaPlayer.stop()
            videoPreview.mediaPlayer.source = ""
        }

        if (videoPreview.timelineVideoOutput) {
            videoPreview.timelineVideoOutput.visible = false
        }
    }

    Component.onCompleted: {
        timelineAreaId.openTimeLineMedia.connect(function(time){
            if (timelineAreaId.clips && timelineAreaId.clips.length > 0) {
               videoPreview.setTimeLineMedia(timelineAreaId.clips, timelineAreaId.totalDuration, time)
            }else {
               clearVideoPreview()
            }
        })

        timelineAreaId.seekRequested.connect(function(time) {
            videoPreview.seekTo(time)
        })
        videoPreview.progressChanged.connect(function(seconds) {
            timelineAreaId.setPointerPosition(seconds)
        })
        timelineAreaId.clipInformation.connect(function(clip){
            parameterPanelId.setClipInfo(clip)
        })

        parameterPanelId.scaleChange.connect(function(scale){
            videoPreview.zoom = scale/100
        })
        parameterPanelId.positionXChange.connect(function(x){
            videoPreview.offsetX = x
        })
        parameterPanelId.positionYChange.connect(function(y){
            videoPreview.offsetY = y
        })
        parameterPanelId.scaleWidthChange.connect(function(scaleX){
            videoPreview.zoomX = scaleX
        })
        parameterPanelId.scaleHeightChange.connect(function(scaleY){
            videoPreview.zoomY = scaleY
        })
        parameterPanelId.rotatChange.connect(function(scale){
            videoPreview.rotat = scale
        })
        parameterPanelId.volumeChange.connect(function(volume){
            videoPreview.mvolume = volume
        })
        parameterPanelId.speedChange.connect(function(speed){
            videoPreview.speed = speed
        })

        timelineAreaId.updateDuration.connect(function(duration){
            console.log(duration)
            parameterPanelId.totalDuration = duration
        })

        Actions.splitRequested.connect(function(){
            timelineAreaId.splitClip()
        })
        Actions.trimRightRequested.connect(function() {
           timelineAreaId.trimRightCurrent()
        })
        Actions.trimLeftRequested.connect(function() {
            timelineAreaId.trimLeftCurrent()
        })
        Actions.deleteRequested.connect(function(){
            timelineAreaId.deleteSelectedClip()
        })
        timelineAreaId.timelineDataUpdated.connect(function(updatedClips, duration, seekTime) {
            if (updatedClips && updatedClips.length > 0) {
                videoPreview.setTimeLineMedia(updatedClips, duration, seekTime)
            } else {
                clearVideoPreview()
            }
        })
    }
}
