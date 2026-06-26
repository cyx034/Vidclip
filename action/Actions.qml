pragma Singleton
import QtQuick
import QtQuick.Controls
import style

Item{
    signal importRequested()
    signal trimLeftRequested()
    signal trimRightRequested()

    property alias _import: _import
    property alias _export: _export
    property alias quit: _quit
    property alias language: _language
    property alias about: _about

    property alias _undo: _undo
    property alias _redo: _redo
    property alias _split: _split
    property alias trim_left:trim_left
    property alias trim_right: trim_right
    property alias _delete: _delete

    signal aboutRequested()  //about信号
    signal exportRequested()  //export信号

    Action {
        id:_import
        text: qsTr("Import")
        icon.name:"document-import"
        icon.color: Style.textcolor
        onTriggered:{
            importRequested()
        }
    }
    Action {
        id:_export
        text: qsTr("Export")
        icon.name:"document-export"
        icon.color: Style.textcolor
        onTriggered: {
            exportRequested()  //发射export信号
        }
    }

    Action {
        id: _quit
        text: qsTr("Quit")
        icon.name: "application-exit"
        shortcut: StandardKey.Quit
        onTriggered: Qt.quit();
    }

    Action {
        id:_language
        text: qsTr("Language")
        icon.name: "globe"
        icon.color: Style.textcolor
    }

    Action {
        id:_about
        text: qsTr("About")
        icon.name: "help-about"
        onTriggered: {
            aboutRequested()  // 发射about信号
        }
    }

    Action{
        id:_undo
        icon.name: "edit-undo"
        icon.color: Style.textcolor
        shortcut:StandardKey.Undo
    }

    Action{
        id:_redo
        icon.name: "edit-redo"
        icon.color: Style.textcolor
        shortcut:StandardKey.Redo
    }

    Action{
        id:_split
        icon.source:"qrc:/image/split.svg"
        icon.color: Style.textcolor
    }

    Action{
        id:trim_left
        icon.source: "qrc:/image/trim-left.svg"
        icon.color: Style.textcolor
        onTriggered: {
            trimLeftRequested()
        }
    }

    Action{
        id:trim_right
        icon.source: "qrc:/image/trim-right.svg"
        icon.color: Style.textcolor
        onTriggered: {
            trimRightRequested()
        }
    }

    Action{
        id:_delete
        icon.name:"delete"
        icon.color: Style.textcolor
    }

}
