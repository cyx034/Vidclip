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
    Q_PROPERTY(QString fileType READ fileType CONSTANT)
    Q_PROPERTY(double duration READ duration CONSTANT)
    Q_PROPERTY(QStringList urls READ urls WRITE setUrls NOTIFY urlsChanged)

public:
    explicit MediaSource(QObject *parent = nullptr);
    ~MediaSource();

    //从文件创建 MediaSource 对象，失败返回 nullptr
    Q_INVOKABLE MediaSource* fromFile(const QString &filePath,QString fileType);

    QString filePath() const { return m_filePath; }
    double duration() const { return m_duration; }
    QString fileType() const { return m_fileType; }
    QStringList urls() const { return m_urls; }

    void setUrls(QStringList urls);

    //如果需要访问 FFmpeg 上下文（比如后续解码预览），可以提供一个获取方法
    AVFormatContext* formatContext() const { return m_formatCtx; }

signals:
    void urlsChanged();

private:
    //私有构造函数
    MediaSource(const QString &filePath, double duration, QString fileType,AVFormatContext *ctx, QObject *parent);

    QString m_filePath;
    double m_duration;
    AVFormatContext *m_formatCtx;  // 保留打开的文件上下文，便于后续重复使用
    QStringList m_urls;
    QString m_fileType;
};