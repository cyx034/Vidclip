import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtMultimedia
import style
import Vidclip 1.0

Item{
    id:root
    property real thumbWidth: 128
    property real thumbHeight: thumbWidth * 9 / 16

    property int currentIndex: -1
    signal mediaSelected(string fileUrl, string fileType)

    property alias materialModel: materialModel
    property alias medioDialogId: medioDialogId

    Rectangle{
        anchors.fill: parent
        color: Style.m_background
        border.color: Style.border
        border.width: 1
    }


    Rectangle{
        id:importButtonId
        x:Style.spacing
        y:Style.spacing
        width: parent.width - Style.spacing*2
        height: 66
        radius: 8
        color: haverId.hovered?Style.highlight:Style.m_button

        HoverHandler{
            id:haverId
            enabled: true;
        }

        TapHandler{
            onTapped: function(){
                medioDialogId.open()
            }
        }
        Image{
            anchors.centerIn: parent
            height: 40
            width: 40
            source: "qrc:/image/add.svg"
        }
    }

    FileDialog{
        id: medioDialogId
        title: "Choose file"
        nameFilters: ["媒体文件 (*.mp3 *.wav *.flac *.mp4 *.avi *.mov *.jpg *.png *.jpeg *.gif)",
            "音频 (*.mp3 *.wav *.flac)",
            "视频 (*.mp4 *.avi *.mov)",
            "图片 (*.jpg *.png *.jpeg *.gif)"]
        fileMode: FileDialog.OpenFiles // Allow for selecting multiple files //多选文件  SaveFile保存文件...
        onAccepted: function(){
            for (var i = 0; i < selectedFiles.length; ++i) {
                addMediaItem(selectedFiles[i])
            }
        }

        onRejected: function(){
        }

    }

    ListModel{id:materialModel}

    GridView {
        id: gridView
        x: Style.spacing
        y: importButtonId.height + Style.spacing*2
        width: parent.width - x - Style.spacing   // 让宽度自适应
        height: parent.height - y - Style.spacing
        cellWidth: thumbWidth + Style.spacing               // 每个单元格宽
        cellHeight: thumbHeight + Style.spacing                // 每个单元格高
        model: materialModel
        clip: true

        delegate: Rectangle {
            width: thumbWidth                // 实际缩略图区域宽
            height: thumbHeight               // 实际缩略图区域高
            color: "transparent"

            Image {
                id:materialItemId
                anchors.fill: parent
                source: model.thumbnail
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: model.name
                color: "white"
                font.pixelSize: 12
                elide: Text.ElideRight
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Drag.active: dragHandler.active
            Drag.dragType: Drag.Automatic
            Drag.supportedActions: Qt.CopyAction
            Drag.imageSource: model.thumbnail
            Drag.imageSourceSize: Qt.size(thumbWidth,thumbHeight)
            Drag.mimeData: {"text/uri-list": "file://" + model.source.filePath}
            Drag.hotSpot.x: thumbWidth / 2
            Drag.hotSpot.y: thumbHeight / 2

            DragHandler {
                id: dragHandler
                target: null
            }

            TapHandler {
                onTapped: {
                    currentIndex = index
                    // 发出选中信号，传递文件URL和类型
                    var fileUrl = "file://" + model.source.filePath
                    mediaSelected(fileUrl, model.type)
                }
            }

        }
    }

    function addMediaItem(fileUrl) {
        let filePath = fileUrl.toString()
        if (filePath.startsWith("file://"))
            filePath = filePath.substring(7)
        let parts = filePath.split('/')
        let fileName = parts[parts.length - 1]

        let fileType = getFileType(fileName)   // 返回 "video", "audio", "image"

        let helper = Qt.createQmlObject('import Vidclip 1.0; MediaSource {}', root)
        let mediaSource = helper.fromFile(filePath,fileType)
        helper.destroy()
        if (!mediaSource) {
            console.error("无法解析文件:", filePath)
            return
        }

        console.log(mediaSource.filePath)

        if (fileType === "video") {

            let thumbnailer = Qt.createQmlObject('import Vidclip 1.0; VideoThumbnailer {}', root)
            if (thumbnailer === null) {
                console.error("创建 VideoThumbnailer 失败，请检查注册");
                return;
            }
            thumbnailer.thumbnailReady.connect(function(path, image) {
                materialModel.append({
                    "name": fileName, "source": mediaSource, "type": fileType,
                    "thumbnail": image
                })
                thumbnailer.destroy()
            });

            thumbnailer.thumbnailFailed.connect(function(path, error) {
                console.error("缩略图生成失败:", filePath, error);
                materialModel.append({
                    "name": fileName, "source": mediaSource, "type": fileType,
                    "thumbnail": "qrc:/image/video.png"
                })
                thumbnailer.destroy()
            });
            thumbnailer.generateThumbnail(filePath)
        }
        if (fileType === "image") {
            materialModel.append({
                name: fileName,
                source: mediaSource,
                type: fileType,
                thumbnail: fileUrl.toString()
            })
        }else if(fileType === "audio"){
            materialModel.append({
                name: fileName,
                source: mediaSource,
                type: fileType,
                thumbnail: "qrc:/image/music.png"
            })
        }
    }

    function getFileType(fileName) {
        let ext = fileName.split('.').pop().toLowerCase()
        if (["mp4", "mov", "mkv", "avi", "flv"].includes(ext)) return "video"
        if (["mp3", "wav", "flac", "aac", "ogg"].includes(ext)) return "audio"
        if (["jpg", "jpeg", "png", "gif", "bmp", "svg"].includes(ext)) return "image"
        return "unknown"
    }

}



