#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

extern "C" {
#include <libavformat/avformat.h>
}

class MediaSource : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString filePath READ filePath CONSTANT)
    Q_PROPERTY(double duration READ duration CONSTANT)

public:
    explicit MediaSource(QObject *parent = nullptr);
    ~MediaSource();

    //从文件创建 MediaSource 对象，失败返回 nullptr
    Q_INVOKABLE MediaSource* fromFile(const QString &filePath);

    QString filePath() const { return m_filePath; }
    double duration() const { return m_duration; }

    //如果需要访问 FFmpeg 上下文（比如后续解码预览），可以提供一个获取方法
    AVFormatContext* formatContext() const { return m_formatCtx; }

private:
    //私有构造函数
    MediaSource(const QString &filePath, double duration, AVFormatContext *ctx, QObject *parent);

    QString m_filePath;
    double m_duration;
    AVFormatContext *m_formatCtx;  // 保留打开的文件上下文，便于后续重复使用
};