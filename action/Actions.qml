pragma Singleton
import QtQuick
import QtQuick.Controls

Item{
    property alias open: _open
    property alias save: _save
    property alias quit: _quit
    property alias about: _about

    // For the icon names of Action objects, please refer to the documentation:
    // https://specifications.freedesktop.org/icon-naming-spec/latest/
    Action {
        id: _open
        text: qsTr("&Open...")
        icon.name: "document-open"
        shortcut: StandardKey.Open
    }

    Action {
        id: _save
        text: qsTr("&Save")
        shortcut: StandardKey.Save
        icon.name: "document-save"
    }

    Action {
        id: _quit
        text: qsTr("&Quit")
        icon.name: "application-exit"
        shortcut: StandardKey.Quit
        onTriggered: Qt.quit();
    }

    Action {
        id: _about
        text: qsTr("&About")
        icon.name: "help-about"
    }
}
