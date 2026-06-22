pragma Singleton
import QtQuick

QtObject {
    // 颜色
    property color background: "#3e3e3e"      // 窗口背景
    property color surface: "#2d2d2d"         // 菜单栏背景
    property color textcolor: "#ffffff"            // 文字颜色
    property color highlight: "#8d8d8d"       // 鼠标悬停背景
    property color border: "#9c9c9c"          // 边框色

    property color m_background:"#272727"
    property color m_button:"#707070"

    property color v_background:"#242424"
    property color v_time:"#353535"
    property color v_key: "#191919"

    property color t_background: "#272727"
    property color t_shaft: "#353535"

    property color d_background: "#272727"
    property color d_button:"#707070"

    property color p_background: "#272727"

    // 尺寸
    property int spacing: 8
    property int radius: 4
    property int fontSizeNormal: 13
}