#pragma once

#include <QAbstractListModel>
#include <QStringList>
#include <QtQml>

struct ClipItem
{
    int trackId = 0;
    double startSec = 0.0;
    double durationSec = 2.0;
    QString sourceUrl;
    QString fileName;
    QStringList thumbnailUrls; // C++原生存储缩略图URL列表
};

class ClipModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT // Qt6自动注册到QML
public:
    enum ClipRoles {
        TrackId = Qt::UserRole + 1,
        StartSec,
        DurationSec,
        SourceUrl,
        FileName,
        ThumbnailUrls
    };
    Q_ENUM(ClipRoles) // 枚举导出QML

    explicit ClipModel(QObject *parent = nullptr);

    // 模型必须实现虚函数
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // QML可调用：新增一条视频剪辑，返回行下标
    Q_INVOKABLE int addNewClip(const QString &sourceUrl, const QString &fileName);
    // QML可调用：更新指定行的缩略图列表
    Q_INVOKABLE void updateClipThumbnails(int rowIndex, const QStringList &urlList);

private:
    QVector<ClipItem> m_clipList;
};
