import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id:centralId
    anchors.fill:parent

    property string currentMediaUrl: ""
    property string currentMediaType: ""

    property bool previewFullscreen: false
    property Window rootWindow: Window.window

    property alias materialBin:materialBin

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
            }

        }
        ParameterPanel{
            Layout.preferredWidth: 320
            Layout.fillHeight: true
            visible: !previewFullscreen

        }
    }

    Component.onCompleted: {
        timelineAreaId.seekRequested.connect(function(time) {
            videoPreview.seekTo(time)
        })
        videoPreview.progressChanged.connect(function(seconds) {
            timelineAreaId.setPointerPosition(seconds)
        })
        timelineAreaId.clipInformation.connect(function(clip){
            //填入ParameterPanel的槽
        })
    }
}
