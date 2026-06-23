import QtQuick
import style
import QtQuick.Controls
import QtQuick.Layouts

Item {
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
    /*Item{
        id:infoItemId
        anchors.fill:parent

        // 内部属性（存储显示数据，并设置默认值）
        property string _projectName: "UnnamedProject"
        property string _projectFileLocation: "/"
        property string _resolution: "1920x1080"
        property string _frameRate: "25fps"
        property string _colorSpace: "SDR-Rec.709"
        property string _sampleRate: "44100Hz"
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

            MText { text: "Resolution: ";}
            MText { text: infoItemId._resolution;}

            MText { text: "FrameRate: ";}
            MText { text: infoItemId._frameRate;}

            MText { text: "ColorSpace: ";}     //色彩空间
            MText { text: infoItemId._colorSpace;}

            MText { text: "SampleRate: ";}   //采样率
            MText { text: infoItemId._sampleRate;}

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

        Connections{
            //连接信号
        }
    }*/

    //剪辑样式
    Item {
        id: labelId
        anchors.fill: parent

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
            implicitWidth: 70
            palette.text:Style.textcolor
            palette.base:Style.m_background
            background:Rectangle {
                anchors.fill:parent
                color: Style.background
            }
            property string prefix: ""
            property string suffix: ""
            property regexp regExp:/^\s*(\d+)\s*$/
            validator: RegularExpressionValidator { regularExpression: regExp }

            textFromValue: function(value, locale) {
                return prefix + Number(value).toLocaleString(locale, 'f', 0) + suffix
            }

            valueFromText: function(text, locale) {
                return Number.fromLocaleString(locale, regExp.exec(text)[1])
            }
        }

        component MDoubleSpinBox:DoubleSpinBox{
            editable: true
            implicitWidth: 70
            palette.text:Style.textcolor
            palette.base:Style.m_background
            background:Rectangle {
                anchors.fill:parent
                color: Style.background
            }
            property string prefix: ""
            property string suffix: ""
            property regexp regExp
            validator: RegularExpressionValidator { regularExpression: regExp }

            textFromValue: function(value, decimals, locale) {
                   return prefix + Number(value).toLocaleString(locale, 'f', decimals) + suffix
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
                            onValueChanged: {
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
                            onValueChanged: {
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
                            onValueChanged: {
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
                            onValueChanged: {
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
                            onValueChanged: {
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
                            onValueChanged: {
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
                            onValueChanged: {
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
                            onValueChanged: {
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
                            suffix: ""
                            value: videoItemId.radius
                            onValueChanged: {
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
                readonly property regexp numberExtractionRegExp3: /\D*?(-?\d*\.?\d+)dB$/
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

                        onValueChanged: {
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
                        onValueChanged: {
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
                readonly property regexp numberExtractionRegExp: /\D*?(-?\d*\.?\d+)x$/
                ColumnLayout{
                    MText {
                        text: "Mulitiple"
                    }
                    RowLayout {
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

                            onValueChanged: {
                                speedItemId.speed = value
                                mulitipleSpinBoxId.value= value
                            }
                        }

                        MDoubleSpinBox{
                            id:mulitipleSpinBoxId
                            from:0.1
                            to:100
                            stepSize:0.1
                            value: speedItemId.speed
                            suffix: "x"
                            regExp: speedItemId.numberExtractionRegExp
                            onValueChanged: {
                                speedItemId.speed = value
                                mulitipleSliderId.value = value
                            }
                        }
                    }
                    MText{
                        text:"Duration"
                    }
                }
            }
        }
    }
}
