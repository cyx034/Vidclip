import QtQuick
import style
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property var currentClip: null
    property real totalDuration: 0

    onTotalDurationChanged: {
        durationId.text = infoItemId.formatTime(totalDuration * 1000)
    }

    Rectangle {
        anchors.fill: parent
        color: Style.p_background
        border.color: Style.border
        border.width: 1
    }

    component MText: Text {
        color: Style.textcolor
        font.pixelSize: 15
    }

    //默认信息面板
    Item {
        id: infoItemId
        anchors.fill: parent
        visible: true
        z: 0

        property string _projectName: "UnnamedProject"
        property string _projectFileLocation: "/"
        property string _ratio: "adapt"
        property string _resolution: "adapt"
        property string _frameRate: "25fps"
        property string _duration: formatTime(totalDuration)

        Text {
            id: titleTextId
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 6
            text:qsTr( "ItemInfomation")
            font.pixelSize: 16
            font.bold: true
            color: Style.textcolor
        }
        Rectangle {
            id: rectId
            anchors.top: titleTextId.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 6
            height: 2
            color: Style.border
        }
        GridLayout {
            id: gridLayoutId
            anchors.top: rectId.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            columns: 2
            columnSpacing: 10
            rowSpacing: 2
            MText { text: qsTr("ProjectName: ");  }
            MText { text: infoItemId._projectName; }
            MText { text: qsTr("ProjectFileLocation: "); }
            MText { text: infoItemId._projectFileLocation; }
            MText { text: qsTr("Ratio: "); }
            MText { text: infoItemId._ratio; }
            MText { text: qsTr("Resolution: "); }
            MText { text: infoItemId._resolution; }
            MText { text: qsTr("FrameRate: "); }
            MText { text: infoItemId._frameRate; }
            MText { text: qsTr("Duration: "); }
            MText { id: durationId; text: infoItemId._duration; }
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

    //剪辑参数面板
    Item {
        id: labelId
        anchors.fill: parent
        visible: false
        z: 1

        property int currentIndex: 0

        Row {
            id: labelRowId
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 6
            spacing: 20
            Repeater {
                model: [qsTr("Video"), qsTr("Audio"),qsTr( "Speed")]
                Text {
                    text: modelData
                    font.pixelSize: 16
                    color: index === labelId.currentIndex ? Style.textcolor : Style.highlight
                    TapHandler { onTapped: labelId.currentIndex = index }
                }
            }
        }

        Rectangle {
            id: rect2Id
            anchors.top: labelRowId.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: Style.border
        }

        //通用控件组件
        component MSpinBox: SpinBox {
            editable: true
            implicitWidth: 75
            palette.text: Style.textcolor
            palette.base: Style.m_background
            background: Rectangle {
                anchors.fill: parent
                color: Style.background
            }
            property string suffix: ""
            property regexp regExp: /^\s*(\d+)\s*$/
            validator: RegularExpressionValidator { regularExpression: regExp }

            textFromValue: function(value, locale) {
                return Number(value).toLocaleString(locale, 'f', 0) + suffix
            }
            valueFromText: function(text, locale) {
                return Number.fromLocaleString(locale, regExp.exec(text)[1])
            }
        }

        component MDoubleSpinBox: DoubleSpinBox {
            editable: true
            implicitWidth: 75
            palette.text: Style.textcolor
            palette.base: Style.m_background
            background: Rectangle {
                anchors.fill: parent
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

        //StackLayout 内容
        StackLayout {
            anchors.top: rect2Id.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            currentIndex: labelId.currentIndex

            //视频页
            Item {
                id: videoItemId
                implicitWidth: parent.width - 5
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
                        text: qsTr("Position size")
                        font.pixelSize: 14
                        font.bold: true
                        color: Style.textcolor
                        Layout.fillWidth: true
                    }

                    //等比缩放
                    RowLayout {
                        id: uniformRow
                        visible: true //由代码控制
                        spacing: 8
                        Label {
                            text: qsTr("Scale")
                            font.pixelSize: Style.fontSizeNormal
                            color: Style.textcolor
                            width: 50
                        }
                        Slider {
                            id: scaleSliderId
                            from: 1
                            to: 500
                            stepSize: 1
                            Layout.fillWidth: true
                            onMoved: {
                                if (currentClip) {
                                    currentClip.scale = value
                                    scaleSpinBoxId.value = value // 同步 SpinBox
                                }
                            }
                        }
                        MSpinBox {
                            id: scaleSpinBoxId
                            from: 1
                            to: 500
                            stepSize: 1
                            suffix: "%"
                            regExp: /^\s*(\d+)\s*%?\s*$/
                            onValueModified: {
                                if (currentClip) {
                                    currentClip.scale = value
                                    scaleSliderId.value = value
                                }
                            }
                        }
                    }

                    //非等比缩放宽度
                    RowLayout {
                        id: nonUniformWidthRow
                        visible: false
                        Label {
                            text: qsTr("Scale Width")
                            font.pixelSize: Style.fontSizeNormal
                            color: Style.textcolor
                            width: 50
                        }
                        Slider {
                            id: scaleWidthSliderId
                            from: 1
                            to: 500
                            stepSize: 1
                            onMoved: {
                                if (currentClip) {
                                    currentClip.scaleX = value
                                    scaleWidthSpinBoxId.value = value
                                }
                            }
                        }
                        MSpinBox {
                            id: scaleWidthSpinBoxId
                            from: 1
                            to: 500
                            stepSize: 1
                            suffix: "%"
                            regExp: /^\s*(\d+)\s*%?\s*$/
                            onValueModified: {
                                if (currentClip) {
                                    currentClip.scaleX = value
                                    scaleWidthSliderId.value = value
                                }
                            }
                        }
                    }

                    //非等比缩放高度
                    RowLayout {
                        id: nonUniformHeightRow
                        visible: false
                        Label {
                            text: qsTr("Scale height")
                            font.pixelSize: Style.fontSizeNormal
                            color: Style.textcolor
                            width: 50
                        }
                        Slider {
                            id: scaleHeightSliderId
                            from: 1
                            to: 500
                            stepSize: 1
                            onMoved: {
                                if (currentClip) {
                                    currentClip.scaleY = value
                                    scaleHeightSpinBoxId.value = value
                                }
                            }
                        }
                        MSpinBox {
                            id: scaleHeightSpinBoxId
                            from: 1
                            to: 500
                            stepSize: 1
                            suffix: "%"
                            regExp: /^\s*(\d+)\s*%?\s*$/
                            onValueModified: {
                                if (currentClip) {
                                    currentClip.scaleY = value
                                    scaleHeightSliderId.value = value
                                }
                            }
                        }
                    }

                    //等比开关
                    RowLayout {
                        spacing: 50
                        Label {
                            text: qsTr("Scale uniformly")
                            font.pixelSize: Style.fontSizeNormal
                            color: Style.textcolor
                            width: 50
                        }
                        Switch {
                            id: switchId
                            onCheckedChanged: {
                                if (currentClip) {
                                    currentClip.uniformScale = checked
                                    updateUIVisibility() // 切换显示模式
                                }
                            }
                        }
                    }

                    //位置
                    RowLayout {
                        spacing: 15
                        Label {
                            text: qsTr("Position")
                            font.pixelSize: 14
                            color: Style.textcolor
                        }
                        Label { text: "X:"; font.pixelSize: 15; color: Style.textcolor }
                        MSpinBox {
                            id: positionXSpinBox
                            from: -1000
                            to: 1000
                            editable: true
                            implicitWidth: 70
                            font.pixelSize: 12
                            onValueModified: {
                                if (currentClip) {
                                    currentClip.offsetX = value
                                }
                            }
                        }
                        Label { text: "Y:"; font.pixelSize: 15; color: Style.textcolor }
                        MSpinBox {
                            id: positionYSpinBox
                            from: -1000
                            to: 1000
                            editable: true
                            implicitWidth: 70
                            font.pixelSize: 12
                            onValueModified: {
                                if (currentClip) {
                                    currentClip.offsetY = value
                                }
                            }
                        }
                    }

                    //旋转
                    RowLayout {
                        spacing: 20
                        Label {
                            text: qsTr("Rotation")
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
                            regExp: /^\s*(\d+\.?\d*)\s*°?\s*$/
                            onValueModified: {
                                if (currentClip) {
                                    currentClip.rotation = value
                                }
                            }
                        }
                    }
                }
            }

            //音频页
            Item {
                id: audioItemId
                RowLayout {
                    spacing: 8
                    Label {
                        text: qsTr("Volume")
                        font.pixelSize: Style.fontSizeNormal
                        color: Style.textcolor
                        width: 50
                    }
                    Slider {
                        id: volumeSliderId
                        from: 0
                        to: 1
                        stepSize: 0.01
                        Layout.fillWidth: true
                        onMoved: {
                            if (currentClip) {
                                currentClip.volume = value
                                volumeSpinBoxId.value = value
                            }
                        }
                    }
                    MDoubleSpinBox {
                        id: volumeSpinBoxId
                        from: 0
                        to: 1
                        stepSize: 0.01
                        decimals: 2
                        suffix: ""
                        regExp: /^\s*(\d+\.?\d*)\s*$/
                        onValueModified: {
                            if (currentClip) {
                                currentClip.volume = value
                                volumeSliderId.value = value
                            }
                        }
                    }
                }
            }

            //变速页
            Item {
                id: speedItemId
                ColumnLayout {
                    anchors.fill: parent
                    anchors.top: parent.bottom
                    anchors.topMargin: 15
                    ColumnLayout {
                        spacing: 10
                        Layout.fillWidth: true
                        MText { text:qsTr( "Mulitiple") }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Slider {
                                id: mulitipleSliderId
                                from: 0.1
                                to: 10
                                stepSize: 0.1
                                Layout.fillWidth: true
                                snapMode: Slider.SnapAlways
                                onMoved: {
                                    if (currentClip) {
                                        currentClip.speed = value
                                        mulitipleSpinBoxId.value = value
                                    }
                                }
                            }
                            MDoubleSpinBox {
                                id: mulitipleSpinBoxId
                                from: 0.1
                                to: 100
                                stepSize: 0.1
                                suffix: "x"
                                regExp: /^\s*(-?\d+\.?\d{0,2})\s*(?:x)?\s*$/i
                                onValueModified: {
                                    if (currentClip) {
                                        currentClip.speed = value
                                        mulitipleSliderId.value = value
                                    }
                                }
                            }
                        }
                    }
                    ColumnLayout {
                        spacing: 10
                        Layout.fillWidth: true
                        MText { text: qsTr("Duration") }
                        RowLayout {
                            MText { id: durationDisplay; text: "0.00s" }
                            MDoubleSpinBox {
                                id: durationSpinBoxId
                                from: 0.01
                                to: 1000
                                stepSize: 0.1
                                suffix: "s"
                                regExp: /^\s*(\d+\.?\d*)\s*$/
                                onValueModified: {
                                    if (currentClip) {
                                        var newSpeed = currentClip.duration / value
                                        if (newSpeed < 0.1) newSpeed = 0.1
                                        if (newSpeed > 100) newSpeed = 100
                                        currentClip.speed = newSpeed
                                        // 更新其他控件
                                        mulitipleSliderId.value = newSpeed
                                        mulitipleSpinBoxId.value = newSpeed
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function updateUI() {
        if (!currentClip) return

        //视频参数
        scaleSliderId.value = currentClip.scale
        scaleSpinBoxId.value = currentClip.scale
        scaleWidthSliderId.value = currentClip.scaleX
        scaleWidthSpinBoxId.value = currentClip.scaleX
        scaleHeightSliderId.value = currentClip.scaleY
        scaleHeightSpinBoxId.value = currentClip.scaleY
        positionXSpinBox.value = currentClip.offsetX
        positionYSpinBox.value = currentClip.offsetY
        rotationSpinBox.value = currentClip.rotation
        switchId.checked = currentClip.uniformScale

        //音频
        volumeSliderId.value = currentClip.volume
        volumeSpinBoxId.value = currentClip.volume

        //变速
        mulitipleSliderId.value = currentClip.speed
        mulitipleSpinBoxId.value = currentClip.speed
        durationDisplay.text = currentClip.duration.toFixed(2) + "s"
        durationSpinBoxId.value = currentClip.duration / currentClip.speed
        durationSpinBoxId.from = currentClip.duration / 100
        durationSpinBoxId.to = currentClip.duration * 10

        updateUIVisibility()
    }

    function updateUIVisibility() {
        if (!currentClip) return
        uniformRow.visible = currentClip.uniformScale
        nonUniformWidthRow.visible = !currentClip.uniformScale
        nonUniformHeightRow.visible = !currentClip.uniformScale
    }

    //设置当前剪辑信息，更新 UI
    function setClipInfo(clip) {
        infoItemId.visible = false
        labelId.visible = true
        currentClip = clip
        if (clip) {
            totalDuration = clip.duration
            updateUI()
        }
    }
}