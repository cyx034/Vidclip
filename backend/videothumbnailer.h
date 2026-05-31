#pragma once

#include <QObject>
#include <QImage>
#include <QString>
#include <QFutureWatcher>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>
}

class VideoThumbnailer : public QObject
{
    Q_OBJECT
public:
    explicit VideoThumbnailer(QObject *parent = nullptr);
    ~VideoThumbnailer();

    Q_INVOKABLE void generateThumbnail(const QString &filePath);

signals:
    void thumbnailReady(const QString &filePath, const QString &thumbnail);
    void thumbnailFailed(const QString &filePath, const QString &error);

private:
    QFutureWatcher<QImage> *m_watcher;
    QImage doExtract(const QString &filePath);
};
