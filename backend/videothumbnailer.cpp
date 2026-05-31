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
                QString tempFileName = QString("thumb_%1.png").arg(QUuid::createUuid().toString(QUuid::WithoutBraces));
                QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/" + tempFileName;
                qDebug() << "Saved thumbnail to:" << tempPath;
                // 保存QImage到本地临时文件
                thumb.save(tempPath);

                QString imageUrl = QUrl::fromLocalFile(tempPath).toString();

                QString filePath = m_watcher->property("filePath").toString();
                if (!thumb.isNull())
                    emit thumbnailReady(filePath, imageUrl);
                else
                    emit thumbnailFailed(filePath, "Failed to extract.");
            });
}

VideoThumbnailer::~VideoThumbnailer() = default;

void VideoThumbnailer::generateThumbnail(const QString &filePath)
{
    //在线程池异步执行Lambda
    auto future = QtConcurrent::run([this,filePath]() {

        return doExtract(filePath);
    });
    m_watcher->setProperty("filePath", filePath);
    m_watcher->setFuture(future); //QFuture<T>代表一个正在后台异步执行的任务
                                    //把异步任务绑定到监听器
}

QImage VideoThumbnailer::doExtract(const QString &filePath)
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

    //提取关键帧并解码
    AVPacket *pPacket = av_packet_alloc();
    AVFrame *pFrame = av_frame_alloc();
    while (av_read_frame(pFormatCtx, pPacket) == 0) {;
        if (pPacket->stream_index == videoStreamIdx) {
            if (avcodec_send_packet(pCodecCtx, pPacket) == 0) {
                if (avcodec_receive_frame(pCodecCtx, pFrame) == 0) {
                    //将解码后的YUV帧转换为RGB QImage
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