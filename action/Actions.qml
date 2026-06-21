pragma Singleton
import QtQuick
import QtQuick.Controls
import style

Item{
    signal importRequested()

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
        icon.source:"../image/split.svg"
        icon.color: Style.textcolor
    }

    Action{
        id:trim_left
        icon.source: "../image/trim-left.svg"
        icon.color: Style.textcolor
    }

    Action{
        id:trim_right
        icon.source: "../image/trim-right.svg"
        icon.color: Style.textcolor
    }

}
