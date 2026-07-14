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

    Q_PROPERTY(double scale READ scale WRITE setScale NOTIFY scaleChanged)
    Q_PROPERTY(double scaleX READ scaleX WRITE setScaleX NOTIFY scaleXChanged)
    Q_PROPERTY(double scaleY READ scaleY WRITE setScaleY NOTIFY scaleYChanged)
    Q_PROPERTY(double offsetX READ offsetX WRITE setOffsetX NOTIFY offsetXChanged)
    Q_PROPERTY(double offsetY READ offsetY WRITE setOffsetY NOTIFY offsetYChanged)
    Q_PROPERTY(double rotation READ rotation WRITE setRotation NOTIFY rotationChanged)
    Q_PROPERTY(double volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(double speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(bool uniformScale READ uniformScale WRITE setUniformScale NOTIFY uniformScaleChanged)

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

    double scale() const { return m_scale; }
    double scaleX() const { return m_scaleX; }
    double scaleY() const { return m_scaleY; }
    double offsetX() const { return m_offsetX; }
    double offsetY() const { return m_offsetY; }
    double rotation() const { return m_rotation; }
    double volume() const { return m_volume; }
    double speed() const { return m_speed; }
    bool uniformScale() const { return m_uniformScale; }

    // Setter（带边界检查和信号发射）
    void setSource(MediaSource* source);
    void setSourceOffset(double offset);
    void setDuration(double duration);
    void setTimelineStart(double start);

    Q_INVOKABLE void extractPreview();

    void setScale(double scale);
    void setScaleX(double scaleX);
    void setScaleY(double scaleY);
    void setOffsetX(double offsetX);
    void setOffsetY(double offsetY);
    void setRotation(double rotation);
    void setVolume(double volume);
    void setSpeed(double speed);
    void setUniformScale(bool uniform);

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

    void scaleChanged();
    void scaleXChanged();
    void scaleYChanged();
    void offsetXChanged();
    void offsetYChanged();
    void rotationChanged();
    void volumeChanged();
    void speedChanged();
    void uniformScaleChanged();

    void parametersUpdated();

private:
    MediaSource* m_source = nullptr;
    double m_sourceOffset = 0.0;  //在视频的哪里开始
    double m_duration = 0.0; //片段时长
    double m_timelineStart = 0.0; //在时间轴的哪里开始

    QStringList m_urls;

    double m_scale = 100.0;
    double m_scaleX = 100.0;
    double m_scaleY = 100.0;
    double m_offsetX = 0.0;
    double m_offsetY = 0.0;
    double m_rotation = 0.0;
    double m_volume = 1.0;
    double m_speed = 1.0;
    bool m_uniformScale = true;

    void validateAndFix();
    void updateTimelineEnd();

    void emitParameterUpdated();

};