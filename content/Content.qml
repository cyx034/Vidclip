import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Item {
    id:centralId
    anchors.fill:parent

    property string currentMediaUrl: ""
    property string currentMediaType: ""

    property bool previewFullscreen: false
    property Window rootWindow: Window.window

    ColumnLayout{
        anchors.fill: parent

        RowLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true

            MaterialBin{
                Layout.preferredWidth: 480
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
            Layout.fillWidth: true
            Layout.preferredHeight: 400
            visible: !previewFullscreen
        }

    }
}
