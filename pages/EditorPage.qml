import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Item {
    id:centralId
    anchors.fill:parent

    property string currentMediaUrl: ""
    property string currentMediaType: ""

    ColumnLayout{
        anchors.fill: parent

        RowLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true

            MaterialBin{
                Layout.preferredWidth: 480
                Layout.fillHeight: true
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
                onMediaFullScreen: function(){

                }
            }
        }

        TimelineArea{
            Layout.fillWidth: true
            Layout.preferredHeight: 400
        }

    }
}
