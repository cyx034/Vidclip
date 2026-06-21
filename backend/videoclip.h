#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class MediaSource;

class VideoClip : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(MediaSource* source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(double sourceOffset READ sourceOffset WRITE setSourceOffset NOTIFY sourceOffsetChanged)
    Q_PROPERTY(double duration READ duration WRITE setDuration NOTIFY durationChanged)
    Q_PROPERTY(double timelineStart READ timelineStart WRITE setTimelineStart NOTIFY timelineStartChanged)
    Q_PROPERTY(double timelineEnd READ timelineEnd NOTIFY timelineEndChanged)
    Q_PROPERTY(QStringList urls READ urls NOTIFY urlsChanged)

public:
    explicit VideoClip(QObject *parent = nullptr);
    ~VideoClip();

    //创建一个默认的 VideoClip（从源文件开始位置，全时长，时间轴从0开始）
    Q_INVOKABLE VideoClip* fromMediaSource(MediaSource* source, QObject* parent = nullptr);

    // Getter
    MediaSource* source() const { return m_source; }
    double sourceOffset() const { return m_sourceOffset; }
    double duration() const { return m_duration; }
    double timelineStart() const { return m_timelineStart; }
    double timelineEnd() const { return m_timelineStart + m_duration; }

    QStringList urls() const { return m_urls; }

    // Setter（带边界检查和信号发射）
    void setSource(MediaSource* source);
    void setSourceOffset(double offset);
    void setDuration(double duration);
    void setTimelineStart(double start);

    void extractPreview();

    // 便捷操作（Q_INVOKABLE 以便 QML 调用）
    Q_INVOKABLE void trimLeft(double delta);   // 正 delta 缩短左侧
    Q_INVOKABLE void trimRight(double delta);  // 正 delta 缩短右侧
    Q_INVOKABLE void move(double newTimelineStart);

signals:
    void sourceChanged();
    void sourceOffsetChanged();
    void durationChanged();
    void timelineStartChanged();
    void timelineEndChanged();  //在时间轴的结束位置改变
    void urlsChanged();

private:
    MediaSource* m_source = nullptr;
    double m_sourceOffset = 0.0;  //在视频的哪里开始
    double m_duration = 0.0; //片段时长
    double m_timelineStart = 0.0; //在时间轴的哪里开始

    QStringList m_urls;

    void validateAndFix();
    void updateTimelineEnd();

};