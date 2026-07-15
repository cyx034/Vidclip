#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>
#include <QFutureWatcher>
#include <QtQml/qqmlregistration.h>
#include <QProcess>

class VideoExporterPrivate;

class VideoExporter : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit VideoExporter(QObject *parent = nullptr);
    ~VideoExporter();

    Q_INVOKABLE void exportTimeline(const QVariantList &clips,
                                    const QVariantMap &settings,
                                    const QString &outputPath);

signals:
    void progressChanged(int percent);
    void exportFinished(const QString &outputPath);
    void exportFailed(const QString &error);

private slots:
    void onProcessFinished();
    void onProcessErrorOccurred(QProcess::ProcessError error);

private:
    void startNextStep();
    void cleanup();

    //QFutureWatcher<void> *m_watcher;
    VideoExporterPrivate *d_ptr;
};