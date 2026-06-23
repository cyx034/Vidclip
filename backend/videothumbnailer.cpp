#include "videothumbnailer.h"
#include <QtConcurrent/QtConcurrent>
#include <QDebug>

VideoThumbnailer::VideoThumbnailer(QObject *parent)
    : QObject(parent)
{
    // 异步处理，避免阻塞

    m_watcher = new QFutureWatcher<QImage>(this); //QFutureWatcher<T>专门监听QFuture，
    connect(m_watcher, &QFutureWatcher<QImage>::finished, //任务完成信号
            this, [this]() {
                QImage thumb = m_watcher->result();
                QString filePath = m_watcher->property("filePath").toString();

                // 确保目录存在
                QString tempDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/Vidclip";
                QDir dir;
                if (!dir.exists(tempDir) && !dir.mkpath(tempDir)) {
                    qWarning() << "无法创建目录:" << tempDir;
                    emit thumbnailFailed(filePath, "Cannot create temp directory");
                    return;
                }

                QString tempFileName = QString("thumb_%1.png").arg(QUuid::createUuid().toString(QUuid::WithoutBraces));
                QString tempPath = dir.filePath(tempFileName);
                bool saved = thumb.save(tempPath);
                if (!saved) {
                    qWarning() << "保存缩略图失败:" << tempPath;
                    emit thumbnailFailed(filePath, "Failed to save image");
                    return;
                }
                qDebug() << "Saved thumbnail to:" << tempPath;

                QString imageUrl = QUrl::fromLocalFile(tempPath).toString();
                if (!thumb.isNull())
                    emit thumbnailReady(filePath, imageUrl);
                else
                    emit thumbnailFailed(filePath, "Failed to extract.");
            });

    m_batchWatcher = new QFutureWatcher<QStringList>(this);
    connect(m_batchWatcher, &QFutureWatcher<QStringList>::finished,
            this, [this]() {
                QStringList urls = m_batchWatcher->result();
                QString filePath = m_batchWatcher->property("filePath").toString();
                if (!urls.isEmpty()) {
                    emit thumbnailsReady(filePath, urls);
                } else {
                    emit thumbnailsFailed(filePath, "Failed to extract thumbnails");
                }
            });
}

VideoThumbnailer::~VideoThumbnailer() = default;

void VideoThumbnailer::generateThumbnail(const QString &filePath)
{
    //在线程池异步执行Lambda
    auto future = QtConcurrent::run([this,filePath]() {

        return doExtract(filePath,0);
    });
    m_watcher->setProperty("filePath", filePath);
    m_watcher->setFuture(future); //QFuture<T>代表一个正在后台异步执行的任务
                                    //把异步任务绑定到监听器
}

void VideoThumbnailer::generateThumbnails(const QString &filePath, int count)
{
    auto future = QtConcurrent::run([this, filePath, count]() {
        return extractThumbnails(filePath, count);
    });
    m_batchWatcher->setProperty("filePath", filePath);
    m_batchWatcher->setFuture(future);
}

QImage VideoThumbnailer::doExtract(const QString &filePath,double timeSec)
{
    QImage thumbnail;

    AVFormatContext *pFormatCtx = nullptr;
    if (avformat_open_input(&pFormatCtx, filePath.toUtf8().constData(), nullptr, nullptr) < 0)
        return thumbnail;
    if (avformat_find_stream_info(pFormatCtx, nullptr) < 0) {
        avformat_close_input(&pFormatCtx);
        return thumbnail;
    }

    int videoStreamIdx = -1;
    const AVCodec *pCodec = nullptr;
    AVCodecContext *pCodecCtx = nullptr;
    for (unsigned int i = 0; i < pFormatCtx->nb_streams; ++i) {
        AVStream *stream = pFormatCtx->streams[i];

        if (stream->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoStreamIdx = i;
            const AVCodec *pCodec = avcodec_find_decoder(pFormatCtx->streams[i]->codecpar->codec_id);
            if (!pCodec) break;
            pCodecCtx = avcodec_alloc_context3(pCodec);
            avcodec_parameters_to_context(pCodecCtx, pFormatCtx->streams[i]->codecpar);
            if (avcodec_open2(pCodecCtx, pCodec, nullptr) == 0) break;
            avcodec_free_context(&pCodecCtx);
            pCodecCtx = nullptr;
        }
    }

    if (videoStreamIdx == -1 || !pCodecCtx) {
        avformat_close_input(&pFormatCtx);
        return thumbnail;
    }

    // 跳到指定时间点（关键帧）
    int64_t timestamp = (int64_t)(timeSec / av_q2d(pFormatCtx->streams[videoStreamIdx]->time_base));
    av_seek_frame(pFormatCtx, videoStreamIdx, timestamp, AVSEEK_FLAG_BACKWARD);
    avcodec_flush_buffers(pCodecCtx);

    // 读取并解码最近的一帧
    AVPacket *pPacket = av_packet_alloc();
    AVFrame *pFrame = av_frame_alloc();
    while (av_read_frame(pFormatCtx, pPacket) == 0) {
        if (pPacket->stream_index == videoStreamIdx) {
            if (avcodec_send_packet(pCodecCtx, pPacket) == 0) {
                if (avcodec_receive_frame(pCodecCtx, pFrame) == 0) {
                    SwsContext *swsCtx = sws_getContext(pCodecCtx->width, pCodecCtx->height, pCodecCtx->pix_fmt,
                                                        pCodecCtx->width, pCodecCtx->height, AV_PIX_FMT_RGB32,
                                                        SWS_BILINEAR, nullptr, nullptr, nullptr);
                    if (swsCtx) {
                        QImage rgbImg(pCodecCtx->width, pCodecCtx->height, QImage::Format_ARGB32);
                        uint8_t *dst_data[1] = { rgbImg.bits() };
                        int dst_linesize[1] = { pCodecCtx->width * 4 };
                        sws_scale(swsCtx, pFrame->data, pFrame->linesize, 0, pCodecCtx->height,
                                  dst_data, dst_linesize);
                        thumbnail = rgbImg.copy();
                        sws_freeContext(swsCtx);
                    }
                    break;
                }
            }
        }
        av_packet_unref(pPacket);
    }

    //清理内存
    av_packet_free(&pPacket);
    av_frame_free(&pFrame);
    avcodec_free_context(&pCodecCtx);
    avformat_close_input(&pFormatCtx);

    return thumbnail;
}

QStringList VideoThumbnailer::extractThumbnails(const QString &filePath, int count)
{
    QStringList imageUrls;
    count = qBound(1, count, 200);

    //获取视频总时长（秒）
    AVFormatContext *pFormatCtx = nullptr;
    if (avformat_open_input(&pFormatCtx, filePath.toUtf8().constData(), nullptr, nullptr) < 0)
        return imageUrls;
    if (avformat_find_stream_info(pFormatCtx, nullptr) < 0) {
        avformat_close_input(&pFormatCtx);
        return imageUrls;
    }
    double duration = pFormatCtx->duration / (double)AV_TIME_BASE;
    avformat_close_input(&pFormatCtx);

    if (duration <= 0) return imageUrls;

    //计算均匀时间点（从 0 到 duration，两端都包含）
    QList<double> timePoints;
    double step = duration / count;
    for (int i = 0; i < count; ++i) {
        double t = i * step;
        if (t >= duration) t = duration - 0.001; // 避免超出
        timePoints.append(t);
    }

    //依次提取每一帧
    for (int i = 0; i < timePoints.size(); ++i) {
        QImage img = doExtract(filePath,timePoints[i]);
        if (!img.isNull()) {
            //保存为临时 PNG，并生成 file:// URL
            QString tempFileName = QString("Vidclip/thumb_%1_%2.png").arg(QUuid::createUuid().toString(QUuid::WithoutBraces)).arg(i);
            QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/" + tempFileName;
            if (img.save(tempPath)) {
                imageUrls.append(QUrl::fromLocalFile(tempPath).toString());
            }
        } else {
            //如果某一帧提取失败，可以添加一个空白占位，或者跳过
            //此处简单跳过，不中断整体流程
            qWarning() << "Failed to extract frame at time" << timePoints[i];
        }
    }

    return imageUrls;
}