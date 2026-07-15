cmake_minimum_required(VERSION 4.3.2)
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "451f2fe2-a8a2-47c3-bc32-94786d8fc91b")
set(CMAKE_CXX_MODULE_STD ON)

project(Vidclip VERSION 0.1 LANGUAGES CXX)
find_package(Qt6 6.10 REQUIRED COMPONENTS Quick LinguistTools)#

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.10)

cmake_minimum_required(VERSION 4.3.2)
set(QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR} CACHE STRING "" FORCE)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_add_executable(appVidclip  WIN32)
qt_standard_project_setup(REQUIRES 6.5 I18N_TRANSLATED_LANGUAGES zh_CN)#
qt_add_resources(appVidclip "images"
    PREFIX "/"
    FILES
        image/add.svg
        image/double-left.svg
        image/double-right.svg
        image/full-screen.svg
        image/icon.jpg
        image/music.png
        image/off-screen.svg
        image/pause.svg
        image/play.svg
        image/video-one.svg
        image/video.png
        image/volume.svg
        image/split.svg
        image/trim-left.svg
        image/trim-right.svg
)

qt_add_qml_module(appVidclip
    URI Vidclip
    VERSION 1.0
    SOURCES     main.cpp
    QML_FILES   Window.qml
    QML_FILES style/Style.qml
    QML_FILES components/VideoPreview.qml
    QML_FILES content/Content.qml
    QML_FILES components/MaterialBin.qml
    QML_FILES components/TimelineArea.qml
    QML_FILES action/Actions.qml
    SOURCES backend/videothumbnailer.cpp backend/videothumbnailer.h
    SOURCES backend/mediasource.h backend/mediasource.cpp
    SOURCES backend/videoclip.h backend/videoclip.cpp
    RESOURCES readme
    QML_FILES components/Dialogs.qml
    QML_FILES components/ParameterPanel.qml
    RESOURCES

)
qt_add_translations(appVidclip
    TS_FILE_BASE qml
    TS_FILE_DIR i18n
    RESOURCE_PREFIX /qt/qml/Vidclip/i18n
)#####
find_package(PkgConfig REQUIRED)
pkg_check_modules(FFMPEG REQUIRED libavcodec libavformat libavutil libswscale)
target_include_directories(appVidclip PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/backend
    ${FFMPEG_INCLUDE_DIRS})
target_link_directories(appVidclip PRIVATE ${FFMPEG_LIBRARY_DIRS})


target_compile_features(appVidclip PRIVATE cxx_std_23)
target_link_libraries(appVidclip
    PRIVATE Qt6::Quick
    ${FFMPEG_LIBRARIES}
)

set(CMAKE_INSTALL_PREFIX "/opt/${PROJECT_NAME}" CACHE PATH "Install path prefix" FORCE)
install(TARGETS appVidclip
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# C++ Modules support
set(VIDCLIP_MODULE_FILES
    # math.cppm                             # 模块文件
)
source_group("Vidclip" FILES ${VIDCLIP_MODULE_FILES})
target_sources(appVidclip
    PRIVATE FILE_SET cxx_modules TYPE CXX_MODULES
        BASE_DIRS   ${CMAKE_CURRENT_SOURCE_DIR}
        FILES  ${VIDCLIP_MODULE_FILES}
)



#include_directories(/usr/include/ffmpeg4.4)



