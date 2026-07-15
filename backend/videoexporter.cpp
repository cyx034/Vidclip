#include "videoexporter.h"
#include <QProcess>
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QUuid>
#include <QDebug>

struct VideoExporterPrivate
{
    QVariantList clips;
    QVariantMap settings;
    QString outputPath;
    QString tempDir;
    QStringList tempFiles;
    int currentStep = 0;
    int totalClips = 0;
    QProcess *process = nullptr;
    bool isAborted = false;

    // 导出参数
    int width = 1920;
    int height = 1080;
    double fps = 30.0;
    int bitrateKbps = 5000;
    QString encoder = "libx264";
    QString containerFormat = "mp4";

    void parseSettings(const QVariantMap &settings) {
        QString resolution = settings.value("resolution", "1920x1080").toString();
        QStringList parts = resolution.split('x');
        if (parts.size() == 2) {
            width = parts[0].toInt();
            height = parts[1].toInt();
        }
        fps = settings.value("frameRate", 30.0).toDouble();
        bitrateKbps = settings.value("bitrate", 5000).toInt();

        QString encoderName = settings.value("encoder", "H.264").toString();
        if (encoderName.compare("H.264", Qt::CaseInsensitive) == 0)
            encoder = "libx264";
        else if (encoderName.compare("H.265", Qt::CaseInsensitive) == 0)
            encoder = "libx265";
        else if (encoderName.compare("VP9", Qt::CaseInsensitive) == 0)
            encoder = "libvpx-vp9";
        else
            encoder = "libx264";
        qDebug() << "VideoExporter 编码器映射:" << encoderName << "→" << encoder;

        containerFormat = settings.value("format", "mp4").toString().toLower();
        if (containerFormat == "mov") containerFormat = "mov";
        else if (containerFormat == "avi") containerFormat = "avi";
        else if (containerFormat == "mkv") containerFormat = "mkv";
        else containerFormat = "mp4";
    }

    QStringList buildClipCommand(const QVariantMap &clip, int index) {
        QString source = clip.value("source").toString();
        double start = clip.value("start", 0.0).toDouble();
        double end = clip.value("end", 0.0).toDouble();
        double duration = end - start;
        double speed = clip.value("speed", 1.0).toDouble();
        double scaleX = clip.value("scaleX", 100.0).toDouble();
        double scaleY = clip.value("scaleY", 100.0).toDouble();
        double rotation = clip.value("rotation", 0.0).toDouble();
        double offsetX = clip.value("offsetX", 0.0).toDouble();
        double offsetY = clip.value("offsetY", 0.0).toDouble();

        QStringList filters;

        //自定义缩放
        int outW = qRound(width * scaleX / 100.0);
        int outH = qRound(height * scaleY / 100.0);
        if (outW < 1) outW = 1;
        if (outH < 1) outH = 1;
        filters << QString("scale=%1:%2").arg(outW).arg(outH);

        //旋转后强制缩放回outW:outH以保证尺寸一致
        if (rotation != 0.0) {
            double rad = rotation * M_PI / 180.0;
            filters << QString("rotate=%1:fillcolor=black").arg(rad, 0, 'f', 6);
            filters << QString("scale=%1:%2").arg(outW).arg(outH);
        }

        //根据图像尺寸与目标尺寸的关系，决定裁剪还是填充
        if (outW > width || outH > height) {
            int cropX = (outW - width) / 2 - qRound(offsetX);
            int cropY = (outH - height) / 2 - qRound(offsetY);
            if (cropX < 0) cropX = 0;
            if (cropY < 0) cropY = 0;
            if (cropX > outW - width) cropX = outW - width;
            if (cropY > outH - height) cropY = outH - height;
            filters << QString("crop=%1:%2:%3:%4")
                           .arg(width).arg(height).arg(cropX).arg(cropY);
        } else {
            int padX = qRound(offsetX);
            int padY = qRound(offsetY);
            if (padX < 0) padX = 0;
            if (padY < 0) padY = 0;
            if (padX + outW > width) padX = width - outW;
            if (padY + outH > height) padY = height - outH;
            filters << QString("pad=%1:%2:%3:%4:black")
                           .arg(width).arg(height).arg(padX).arg(padY);
        }

        //变速
        if (speed != 1.0) {
            double ptsFactor = 1.0 / speed;
            filters << QString("setpts=%1*PTS").arg(ptsFactor, 0, 'f', 6);
        }

        QString filterStr = filters.join(",");
        QString tempFile = tempDir + "/clip_" + QString::number(index) + "." + containerFormat;

        //构造ffmpeg命令行
        QStringList args;
        args << "-ss" << QString::number(start, 'f', 6)
             << "-i" << source
             << "-t" << QString::number(duration, 'f', 6)
             << "-vf" << filterStr
             << "-c:v" << encoder
             << "-b:v" << QString::number(bitrateKbps) + "k"
             << "-preset" << "medium"
             << "-crf" << "18"
             << "-c:a" << "aac"
             << "-b:a" << "128k"
             << "-y"
             << tempFile;

        //对特定编码器调整参数
        if (encoder == "libx265") {
            args.removeAll("-preset");
            args.removeAll("medium");
            args.removeAll("-crf");
            args.removeAll("18");
            args << "-preset" << "medium" << "-crf" << "22";
        } else if (encoder == "libvpx-vp9") {
            args.removeAll("-preset");
            args.removeAll("medium");
            args.removeAll("-crf");
            args.removeAll("18");
            args << "-row-mt" << "1" << "-cpu-used" << "4";
        }

        qDebug() << "ffmpeg 命令:" << args.join(" ");
        return args;
    }

    QStringList buildConcatCommand() {
        QString listPath = tempDir + "/concat.txt";
        QFile listFile(listPath);
        if (!listFile.open(QIODevice::WriteOnly | QIODevice::Text))
            return QStringList();

        QTextStream out(&listFile);
        for (const QString &tf : tempFiles) {
            QString path = QDir::toNativeSeparators(tf);
            if (path.contains(' '))
                path = "'" + path + "'";
            out << "file " << path << "\n";
        }
        listFile.close();

        QStringList args;
        args << "-f" << "concat"
             << "-safe" << "0"
             << "-i" << listPath
             << "-c" << "copy"
             << "-y"
             << outputPath;
        return args;
    }

    void cleanupTemp() {
        for (const QString &tf : tempFiles)
            QFile::remove(tf);
        QFile::remove(tempDir + "/concat.txt");
        QDir(tempDir).rmdir(".");
    }

    int estimateProgress() {
        if (totalClips == 0) return 0;
        int stepWeight = 100 / (totalClips + 1);
        int progress = currentStep * stepWeight;
        if (currentStep == totalClips)
            progress = 95;
        return qMin(progress, 100);
    }
};

VideoExporter::VideoExporter(QObject *parent)
    : QObject(parent)
    , d_ptr(new VideoExporterPrivate)
{
}

VideoExporter::~VideoExporter()
{
    if (d_ptr->process) {
        d_ptr->process->kill();
        d_ptr->process->deleteLater();
        d_ptr->process = nullptr;
    }
    delete d_ptr;
}

void VideoExporter::exportTimeline(const QVariantList &clips,
                                   const QVariantMap &settings,
                                   const QString &outputPath)
{
    if (clips.isEmpty()) {
        emit exportFailed("剪辑列表为空");
        return;
    }

    QFileInfo outFileInfo(outputPath);
    QDir outDir = outFileInfo.absoluteDir();
    if (!outDir.exists()) {
        if (!outDir.mkpath(".")) {
            emit exportFailed("无法创建输出目录: " + outDir.absolutePath());
            return;
        }
    }

    //初始化
    d_ptr->clips = clips;
    d_ptr->settings = settings;
    d_ptr->outputPath = outputPath;
    d_ptr->tempFiles.clear();
    d_ptr->currentStep = 0;
    d_ptr->totalClips = clips.size();
    d_ptr->isAborted = false;
    d_ptr->parseSettings(settings);

    //创建临时目录
    d_ptr->tempDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation)
                     + "/VideoExport_" + QUuid::createUuid().toString(QUuid::WithoutBraces);
    QDir dir;
    if (!dir.mkpath(d_ptr->tempDir)) {
        emit exportFailed("无法创建临时目录");
        return;
    }

    startNextStep();
}

void VideoExporter::startNextStep()
{
    if (d_ptr->isAborted) {
        cleanup();
        return;
    }

    //所有剪辑处理完毕合并
    if (d_ptr->currentStep >= d_ptr->totalClips) {
        QStringList args = d_ptr->buildConcatCommand();
        if (args.isEmpty()) {
            emit exportFailed("无法创建合并列表");
            cleanup();
            return;
        }

        d_ptr->process = new QProcess(this);
        connect(d_ptr->process, &QProcess::finished, this, &VideoExporter::onProcessFinished);
        connect(d_ptr->process, &QProcess::errorOccurred, this, &VideoExporter::onProcessErrorOccurred);
        d_ptr->process->start("ffmpeg", args);
        return;
    }

    //处理当前剪辑
    QVariantMap clip = d_ptr->clips[d_ptr->currentStep].toMap();
    QStringList args = d_ptr->buildClipCommand(clip, d_ptr->currentStep);

    d_ptr->process = new QProcess(this);
    connect(d_ptr->process, &QProcess::finished, this, &VideoExporter::onProcessFinished);
    connect(d_ptr->process, &QProcess::errorOccurred, this, &VideoExporter::onProcessErrorOccurred);
    d_ptr->process->start("ffmpeg", args);

    emit progressChanged(d_ptr->estimateProgress());
}

void VideoExporter::onProcessFinished()
{
    QProcess *proc = qobject_cast<QProcess*>(sender());
    if (!proc) return;

    if (proc->exitCode() != 0) {
        QString error = proc->readAllStandardError();
        emit exportFailed("ffmpeg 执行失败: " + error);
        d_ptr->isAborted = true;
        cleanup();
        proc->deleteLater();
        return;
    }

    //如果是合并步骤完成
    if (d_ptr->currentStep >= d_ptr->totalClips) {
        d_ptr->cleanupTemp();
        emit progressChanged(100);
        emit exportFinished(d_ptr->outputPath);
        proc->deleteLater();
        return;
    }

    //记录临时文件，进入下一步
    QString tempFile = d_ptr->tempDir + "/clip_" + QString::number(d_ptr->currentStep) + "." + d_ptr->containerFormat;
    d_ptr->tempFiles.append(tempFile);
    d_ptr->currentStep++;
    emit progressChanged(d_ptr->estimateProgress());

    proc->deleteLater();
    startNextStep();
}

void VideoExporter::onProcessErrorOccurred(QProcess::ProcessError error)
{
    QProcess *proc = qobject_cast<QProcess*>(sender());
    if (proc) {
        emit exportFailed("进程错误: " + QString::number(error));
        proc->deleteLater();
    }
    d_ptr->isAborted = true;
    cleanup();
}

void VideoExporter::cleanup()
{
    d_ptr->cleanupTemp();
    if (d_ptr->process) {
        d_ptr->process->kill();
        d_ptr->process->deleteLater();
        d_ptr->process = nullptr;
    }
}