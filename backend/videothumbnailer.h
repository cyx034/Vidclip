#pragma once

#include <QObject>
#include <QImage>
#include <QString>
#include <QFutureWatcher>
#include <QtQml/qqmlregistration.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>
}

class VideoThumbnailer : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit VideoThumbnailer(QObject *parent = nullptr);
    ~VideoThumbnailer();

    Q_INVOKABLE void generateThumbnail(const QString &filePath);

    Q_INVOKABLE void generateThumbnails(const QString &filePath, int count);

signals:

    void thumbnailReady(const QString &filePath, const QString &thumbnail);
    void thumbnailFailed(const QString &filePath, const QString &error);

    void thumbnailsReady(const QString &filePath, const QStringList &thumbnailUrls);
    void thumbnailsFailed(const QString &filePath, const QString &error);

private:
    QFutureWatcher<QImage> *m_watcher;
    QFutureWatcher<QStringList> *m_batchWatcher;

    QImage doExtract(const QString &filePath,double timeSec);
    QStringList extractThumbnails(const QString &filePath,int count);
};
