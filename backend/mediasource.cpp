#include "mediasource.h"
#include <QDebug>

MediaSource::MediaSource(QObject *parent)
    : QObject(parent), m_duration(0.0), m_formatCtx(nullptr)
{
}

MediaSource::~MediaSource()
{
    if (m_formatCtx) {
        avformat_close_input(&m_formatCtx);
    }
}

MediaSource* MediaSource::fromFile(const QString &filePath)
{
    AVFormatContext *ctx = nullptr;
    //打开输入文件
    if (avformat_open_input(&ctx, filePath.toUtf8().constData(), nullptr, nullptr) != 0) {
        qWarning() << "Failed to open file:" << filePath;
        return nullptr;
    }
    //获取流信息
    if (avformat_find_stream_info(ctx, nullptr) < 0) {
        qWarning() << "Failed to find stream info for:" << filePath;
        avformat_close_input(&ctx);
        return nullptr;
    }
    //计算时长
    double duration = ctx->duration / (double)AV_TIME_BASE;
    if (duration <= 0) {
        //如果无法获取时长，尝试从视频流中获取
        for (unsigned int i = 0; i < ctx->nb_streams; ++i) {
            AVStream *stream = ctx->streams[i];
            if (stream->duration != AV_NOPTS_VALUE) {
                double streamDuration = stream->duration * av_q2d(stream->time_base);
                if (streamDuration > duration) duration = streamDuration;
            }
        }
    }
    //创建MediaSource对象，并转移ctx的所有权
    return new MediaSource(filePath, duration, ctx, nullptr);
}

MediaSource::MediaSource(const QString &filePath, double duration, AVFormatContext *ctx, QObject *parent)
    : QObject(parent), m_filePath(filePath), m_duration(duration), m_formatCtx(ctx)
{
}
