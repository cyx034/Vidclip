import QtQuick
import style
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id:root
    property var currentClip: null
    property real originalDuration: 0

    Rectangle{
        anchors.fill: parent
        color: Style.p_background
        border.color: Style.border
        border.width: 1
    }

    component MText:Text{
        color: Style.textcolor
        font.pixelSize: 15
    }

    //默认样式
    Item{
        id:infoItemId
        anchors.fill:parent
        visible:true
        z:0

        // 内部属性（存储显示数据，并设置默认值）
        property string _projectName: "UnnamedProject"
        property string _projectFileLocation: "/"
        property string _ratio:"adapt"
        property string _resolution: "adapt"
        property string _frameRate: "25fps"
        property string _duration: "00:00:00:00"

        Text {
            id:titleTextId
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top:parent.top
            anchors.topMargin: 6
            text: "ItemInfomation"
            font.pixelSize: 16
            font.bold: true
            color: Style.textcolor
        }

        Rectangle{
            id:rectId
            anchors.top: titleTextId.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 6
            height: 2
            color:Style.border
        }

        GridLayout {
            anchors.top: rectId.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            columns: 2
            columnSpacing: 10
            rowSpacing: 2

            MText { text: "ProjectName: ";  }
            MText { text: infoItemId._projectName;}

            MText { text: "ProjectFileLocation: ";}
            MText { text: infoItemId._projectFileLocation;}

            MText { text: "Ratio: ";}  //比例
            MText { text: infoItemId._ratio;}

            MText { text: "Resolution: ";}  //分辨率
            MText { text: infoItemId._resolution;}

            MText { text: "FrameRate: ";}   //帧率
            MText { text: infoItemId._frameRate;}

            MText { text: "Duration: ";}
            MText { text: infoItemId._duration;}
        }

        // 更新函数
        function updateInfo(info) {
            if (info.projectName !== undefined) _projectName = info.projectName
            if (info.projectFileLocation !== undefined) _projectFileLocation = info.projectFileLocation
            if (info.resolution !== undefined) _resolution = info.resolution
            if (info.frameRate !== undefined) _frameRate = info.frameRate
            if (info.colorSpace !== undefined) _colorSpace = info.colorSpace
            if (info.sampleRate !== undefined) _sampleRate = info.sampleRate
            if (info.duration !== undefined) _duration = info.duration
        }
    }

    //剪辑样式
    Item {
        id: labelId
        anchors.fill: parent
        visible:false
        z:1

        // 当前选中的标签索引（0:Video, 1:Audio, 2:Speed）
        property int currentIndex: 0

        // 三个标签
        Row {
            id: labelRowId
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top:parent.top
            anchors.topMargin: 6
            spacing: 20

            Repeater {
                model: ["Video", "Audio", "Speed"]
                Text {
                    text: modelData
                    font.pixelSize: 16
                    color: index === labelId.currentIndex ? Style.textcolor : Style.highlight
                    TapHandler{
                        onTapped:labelId.currentIndex = index
                    }
                }
            }
        }

        // 分割线
        Rectangle {
            id:rect2Id
            anchors.top: labelRowId.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: Style.border
        }

        component MSpinBox:SpinBox {
            editable: true
            implicitWidth: 100
            palette.text:Style.textcolor
            palette.base:Style.m_background
            background:Rectangle {
                anchors.fill:parent
                color: Style.background
            }
            property string suffix: ""
            property regexp regExp:/^\s*(\d+)\s*$/
            validator: RegularExpressionValidator { regularExpression: regExp }

            textFromValue: function(value, locale) {
                return Number(value).toLocaleString(locale, 'f', 0) + suffix
            }

            valueFromText: function(text, locale) {
                return Number.fromLocaleString(locale, regExp.exec(text)[1])
            }
        }

        component MDoubleSpinBox:DoubleSpinBox{
            editable: true
            implicitWidth: 100
            palette.text:Style.textcolor
            palette.base:Style.m_background
            background:Rectangle {
                anchors.fill:parent
                color: Style.background
            }
            property string suffix: ""
            property regexp regExp
            validator: RegularExpressionValidator { regularExpression: regExp }

            textFromValue: function(value, decimals, locale) {
                   return Number(value).toLocaleString(locale, 'f', decimals) + suffix
                }

            valueFromText: function(text, locale) {
                return Number.fromLocaleString(locale, regExp.exec(text)[1])
            }

        }

        // 页面内容（根据当前索引切换）
        StackLayout {
            anchors.top: rect2Id.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            currentIndex: labelId.currentIndex

            // 页面1：视频
            Item {
                id:videoItemId
                property real duration: 0
                Text {
                    anchors.centerIn: parent
                    text: "视频编辑内容"
                    color: Style.textcolor
                }
                property real positionX: 0
                property real positionY: 0
                property real scale: 100
                property real scaleWidth: 100
                property real scaleHeight: 100
                property bool uniformScale: true
                property real rotat: 0
                property real radius: 0
                readonly property regexp numberExtractionRegExp1: /^\s*(\d+)\s*%?\s*$/
                readonly property regexp numberExtractionRegExp2: /^\s*(\d+\.?\d*)\s*°?\s*$/


                implicitWidth: parent.width-5
                implicitHeight: columnLayout.implicitHeight + 24

                Rectangle {
                    anchors.fill: parent
                    color: Style.surface
                    border.color: Style.border
                    border.width: 1
                    radius: 4
                }



                ColumnLayout {
                    id: columnLayout
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10


                    Label {
                        text: qsTr("位置大小")
                        font.pixelSize: 14
                        font.bold: true
                        color: Style.textcolor
                        Layout.fillWidth: true
                    }


                    RowLayout {
                        visible: videoItemId.uniformScale
                        spacing: 8
                        Label {
                            text: qsTr("缩放")
                            font.pixelSize: Style.fontSizeNormal
                            color: Style.textcolor
                            width: 50
                        }

                        Slider {
                            id: scaleSliderId
                            from: 1
                            to: 500
                            stepSize: 1
                            value: videoItemId.scale
                            Layout.fillWidth: true
                            onMoved: {
                                videoItemId.scale = value
                                scaleSpinBoxId.value = value
                            }
                        }

                        MSpinBox{
                            id:scaleSpinBoxId
                            from: 1
                            to:500
                            stepSize: 1
                            value: videoItemId.scale
                            suffix: "%"
                            regExp: videoItemId.numberExtractionRegExp1
                            onValueModified: {
                                videoItemId.scale = value
                                scaleSliderId.value = value
                            }
                        }
                    }

                    RowLayout{
                        visible:!videoItemId.uniformScale
                        Label{
                            text: qsTr("缩放宽度")
                            font.pixelSize: Style.fontSizeNormal
                            color: Style.textcolor
                            width: 50
                        }
                        Slider{
                            id:scaleWidthSliderId
                            from: 1
                            to: 500
                            stepSize: 1
                            value:videoItemId.scaleWidth
                            onMoved: {
                                videoItemId.scaleWidth = value
                                scaleWidthSpinBoxId.value = value
                            }
                        }

                        MSpinBox{
                            id:scaleWidthSpinBoxId
                            from:1
                            to:500
                            stepSize: 1
                            suffix: "%"
                            value:videoItemId.scaleWidth
                            regExp: videoItemId.numberExtractionRegExp1
                            onValueModified: {
                                videoItemId.scaleWidth = value
                                scaleWidthSliderId.value = value
                            }
                        }

                    }

                    RowLayout{
                        visible:!videoItemId.uniformScale
                        Label{
                            text: qsTr("缩放高度")
                            font.pixelSize: Style.fontSizeNormal
                            color: Style.textcolor
                            width: 50
                        }
                        Slider{
                            id:scaleHeightSliderId
                            from: 1
                            to: 500
                            stepSize: 1
                            value:videoItemId.scaleHeight
                            onMoved: {
                                videoItemId.scaleHeight = value
                                scaleHeightSpinBoxId.value = value
                            }
                        }

                        MSpinBox{
                            id:scaleHeightSpinBoxId
                            from:1
                            to:500
                            stepSize: 1
                            suffix: "%"
                            value:videoItemId.scaleHeight
                            regExp: videoItemId.numberExtractionRegExp1
                            onValueModified: {
                                videoItemId.scaleHeight = value
                                scaleHeightSliderId.value = value
                            }
                        }

                    }

                    RowLayout {
                        spacing:50
                        Label {
                            text: qsTr("等比缩放")
                            font.pixelSize: Style.fontSizeNormal
                            color: Style.textcolor
                            width: 50
                        }
                        Switch {
                            id: switchId
                            checked: videoItemId.uniformScale
                            onCheckedChanged: {
                                videoItemId.uniformScale = checked
                            }
                        }
                    }

                    RowLayout {
                        spacing: 15
                        Label {
                            text: qsTr("位置")
                            font.pixelSize: 14
                            color: Style.textcolor
                        }
                        Label {
                            text: "X:"
                            font.pixelSize: 15
                            color: Style.textcolor
                        }
                        MSpinBox {
                            id: positionXSpinBox
                            from: 0
                            value: videoItemId.positionX
                            editable: true
                            implicitWidth: 70
                            font.pixelSize: 12
                            onValueModified: {
                                videoItemId.positionX = value
                            }
                        }
                        Label {
                            text: "Y:"
                            font.pixelSize: 15
                            color: Style.textcolor
                        }
                        MSpinBox {
                            id: positionYSpinBox
                            from: 0
                            value: videoItemId.positionY
                            editable: true
                            implicitWidth: 70
                            font.pixelSize: 12
                            onValueModified: {
                                videoItemId.positionY = value
                            }
                        }
                    }

                    RowLayout {
                        spacing: 20
                        Label {
                            text: qsTr("旋转")
                            font.pixelSize: 14
                            color: Style.textcolor
                        }
                        MDoubleSpinBox {
                            id: rotationSpinBox
                            from: 0.00
                            to: 360.00
                            stepSize: 0.01
                            decimals: 2
                            suffix: "°"
                            regExp:videoItemId.numberExtractionRegExp2
                            value: videoItemId.rotat
                            onValueModified: {
                                videoItemId.rotat = value
                            }
                        }
                    }

                    RowLayout {
                        spacing: 20
                        Label {
                            text: qsTr("圆角")
                            font.pixelSize: 14
                            color: Style.textcolor
                        }
                        MSpinBox {
                            id: radiusSpinBox
                            from: 0
                            to: 100
                            value: videoItemId.radius
                            onValueModified: {
                                videoItemId.radius = value
                            }
                        }
                    }
                }
            }

            // 页面2：音频
            Item {
                id:audioItemId
                property real volume: 0.0
                readonly property regexp numberExtractionRegExp3: /^\s*(-?\d+\.?\d?)\s*(?:dB)?\s*$/i
                RowLayout {
                    visible:true
                    spacing: 8
                    Label {
                        text: qsTr("音量")
                        font.pixelSize: Style.fontSizeNormal
                        color: Style.textcolor
                        width: 50
                    }

                    Slider {
                        id: volumeSliderId
                        from: -20
                        to: 20
                        value: audioItemId.volume
                        stepSize: 0.1
                        Layout.fillWidth: true

                        onMoved: {
                            if (audioItemId.volume !== value) {
                                audioItemId.volume = value
                            }
                        }
                    }

                    MDoubleSpinBox{
                        id:volumeSpinBoxId
                        from: -20
                        to: 20
                        stepSize: 0.1
                        decimals: 1
                        value: audioItemId.volume
                        suffix: "dB"
                        regExp: audioItemId.numberExtractionRegExp3
                        onValueModified: {
                            if (audioItemId.volume !== value) {
                                audioItemId.volume = value
                            }
                        }
                    }

                }

            }

            // 页面3：变速
            Item {
                id:speedItemId
                property real speed: 1.00
                property real duration: 0
                property real currentDuration: 0
                property real originalDuration: 0
                ColumnLayout{
                    anchors.fill:parent
                    anchors.top:parent.bottom
                    anchors.topMargin: 15
                    ColumnLayout{
                        spacing: 10
                        Layout.fillWidth: true
                        MText {
                            text: "Mulitiple"
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            visible:true
                            spacing: 8
                            Slider {
                                id: mulitipleSliderId
                                from: 0.1
                                to: 100
                                value: speedItemId.speed
                                stepSize: 0.1
                                Layout.fillWidth: true
                                snapMode:Slider.SnapAlways

                                onMoved: {
                                    speedItemId.speed = value
                                    mulitipleSpinBoxId.value= value
                                    root.onSpeedChanged(value)

                                }
                            }
                            MDoubleSpinBox{
                                id:mulitipleSpinBoxId
                                from:0.1
                                to:100
                                stepSize:0.1
                                value: speedItemId.speed
                                suffix: "x"
                                regExp:/^\s*(-?\d+\.?\d{0,2})\s*(?:x)?\s*$/i
                                onValueModified: {
                                    speedItemId.speed = value
                                    mulitipleSliderId.value = value
                                    root.onSpeedChanged(value)
                                }
                            }
                        }
                    }
                    ColumnLayout{
                        spacing: 10
                        Layout.fillWidth: true
                        ColumnLayout{
                            spacing: 10
                            Layout.fillWidth: true
                            MText{
                                text:"Duration"
                            }
                            RowLayout{
                                MText{
                                    text: speedItemId.originalDuration.toFixed(2) + "s"
                                }
                                MDoubleSpinBox{
                                    id:durationSpinBoxId
                                    from:speedItemId.originalDuration/100
                                    to:speedItemId.originalDuration*10
                                    stepSize:0.1
                                    value: speedItemId.duration
                                    suffix: "s"
                                    regExp: /^\s*(\d+\.?\d*)\s*$/
                                    onValueModified: {
                                        var newSpeed = speedItemId.originalDuration / value
                                        if (newSpeed < 0.1) newSpeed = 0.1
                                        if (newSpeed > 100) newSpeed = 100
                                        // 应用速度
                                        root.onSpeedChanged(newSpeed)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    function setClipInfo(clip) {
        infoItemId.visible = false
        labelId.visible = true
    }

    function updateVideoPanel(clip) {

    }

    function onSpeedChanged(newSpeed){
        if(!currentClip)return
        var newDuration = originalDuration/newSpeed
        currentClip.setDuration(newDuration)
        speedItemId.currentDuration = newDuration
    }

    function updateAudioPanel(clip) {
    }

    function updateSpeedPanel(clip) {

        if(!clip)return
        var currentDuration = clip.duration

        if(originalDuration > 0 ){
            speedItemId.speed = originalDuration/currentDuration
        }else{
            originalDuration = currentDuration
            speedItemId.speed = 1.0
        }

        speedItemId.currentDuration = currentDuration
        speedItemId.originalDuration = originalDuration
    }
}
