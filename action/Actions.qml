pragma Singleton
import QtQuick
import QtQuick.Controls
import style

Item{
    property alias _new: _new
    property alias _import: _import
    property alias _export: _export
    property alias quit: _quit
    property alias language: _language
    property alias about: _about

    Action {
        id:_new
        text: qsTr("New")
        icon.name:"document-new"
        icon.color: Style.textcolor
    }

    Action {
        id:_import
        text: qsTr("Import")
        icon.name:"document-import"
        icon.color: Style.textcolor
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
}
