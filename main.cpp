#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "backend/videothumbnailer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/Vidclip/Window.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.addImportPath("../..");
    engine.loadFromModule("Vidclip", "Window");

    return QGuiApplication::exec();
}
