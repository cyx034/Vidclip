#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "backend/videothumbnailer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    qmlRegisterType<VideoThumbnailer>("Thumbnailer", 1, 0, "VideoThumbnailer");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.addImportPath("../..");
    engine.loadFromModule("Vidclip", "Main");

    return QGuiApplication::exec();
}
