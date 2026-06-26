#include "videoclip.h"
#include "mediasource.h"
#include <QDebug>

VideoClip::VideoClip(QObject *parent)
    : QObject(parent)
{
}

VideoClip::~VideoClip()
{
    // 不负责释放 MediaSource，因为它由素材库管理
}

VideoClip* VideoClip::fromMediaSource(MediaSource* source, QObject* parent)
{
    if (!source) return nullptr;
    VideoClip* clip = new VideoClip(parent);
    clip->setSource(source);
    clip->setSourceOffset(0.0);
    clip->setDuration(source->duration());
    clip->setTimelineStart(0.0);
    clip->extractPreview();
    return clip;
}

void VideoClip::setSource(MediaSource* source)
{
    if (m_source == source) return;
    m_source = source;
    emit sourceChanged();
    // 如果 duration 还是默认值，可自动设置为源的时长
    if (m_duration == 0.0 && source) {
        setDuration(source->duration());
    }
}

void VideoClip::setSourceOffset(double offset)
{
    if (qFuzzyCompare(m_sourceOffset, offset)) return; //qFuzzyCompare对比浮点数
    if (offset < 0) offset = 0;
    if (m_source && offset > m_source->duration()) offset = m_source->duration();
    m_sourceOffset = offset;
    emit sourceOffsetChanged();
    // 修改源偏移可能影响有效时长（不能超出源文件结束）
    if (m_source) {
        double maxDur = m_source->duration() - m_sourceOffset;
        if (m_duration > maxDur) setDuration(maxDur);
    }
    emit timelineEndChanged();
}

void VideoClip::setDuration(double duration)
{
    if (duration < 0.01) duration = 0.01; // 最小 10ms
    if (m_source) {
        double maxDur = m_source->duration() - m_sourceOffset;
        if (duration > maxDur) duration = maxDur;
    }
    if (qFuzzyCompare(m_duration, duration)) return;
    m_duration = duration;
    emit durationChanged();
    emit timelineEndChanged();
}

void VideoClip::setTimelineStart(double start)
{
    if (start < 0) start = 0;
    if (qFuzzyCompare(m_timelineStart, start)) return;
    m_timelineStart = start;
    emit timelineStartChanged();
    emit timelineEndChanged();
}

void VideoClip::trimLeft(double delta)
{
    if (delta <= 0) return;
    double newOffset = m_sourceOffset + delta;
    double newDuration = m_duration - delta;
    if (newOffset < 0) newOffset = 0;
    if (newDuration < 0.01) return;
    setSourceOffset(newOffset);
    setDuration(newDuration);
    setTimelineStart(m_timelineStart);
    extractPreview();
}

void VideoClip::trimRight(double delta)
{
    if (delta <= 0) return;
    double newDuration = m_duration - delta;
    if (newDuration < 0.01) return;
    setDuration(newDuration);
    extractPreview();
}

void VideoClip::move(double newTimelineStart)
{
    setTimelineStart(newTimelineStart);
}

void VideoClip::updateTimelineEnd()
{
    emit timelineEndChanged();
}

void VideoClip::extractPreview()
{
    int scale;
    int startScale;

    if (m_duration != 0.0) {
        scale = m_source->duration() / m_duration;
    } else {
        scale = m_source->duration();
    }
    if (m_sourceOffset != 0.0) {
        startScale = m_source->duration() / m_sourceOffset;
    } else {
        startScale = m_source->duration();
    }
    int mClip = m_source->urls().size() / scale;
    int mStartScale = m_source->urls().size() / startScale;
    m_urls = m_source->urls().mid(mStartScale, mClip);
    emit urlsChanged();
}