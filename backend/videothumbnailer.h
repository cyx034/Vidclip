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
    /*Q_PROPERTY(QString author READ author WRITE setAuthor NOTIFY authorChanged)
    Q_PROPERTY(QDateTime creationDate READ creationDate WRITE setCreationDate NOTIFY creationDateChanged)
    QML_ELEMENT  // 使用这些宏需要 #include <QtQml/qmlregistration.h>*/
    QML_ELEMENT
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
