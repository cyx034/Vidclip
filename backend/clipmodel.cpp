#include "clipmodel.h"

ClipModel::ClipModel(QObject *parent)
    : QAbstractListModel(parent)
{}

int ClipModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_clipList.size();
}

QVariant ClipModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_clipList.size())
        return {};
    const ClipItem &item = m_clipList[index.row()];
    switch (role)
    {
    case TrackId: return item.trackId;
    case StartSec: return item.startSec;
    case DurationSec: return item.durationSec;
    case SourceUrl: return item.sourceUrl;
    case FileName: return item.fileName;
    case ThumbnailUrls: return item.thumbnailUrls;
    default: return {};
    }
}

QHash<int, QByteArray> ClipModel::roleNames() const
{
    return {
        {TrackId, "trackId"},
        {StartSec, "startSec"},
        {DurationSec, "durationSec"},
        {SourceUrl, "sourceUrl"},
        {FileName, "fileName"},
        {ThumbnailUrls, "thumbnailUrls"}
    };
}

int ClipModel::addNewClip(const QString &sourceUrl, const QString &fileName)
{
    beginInsertRows({}, m_clipList.size(), m_clipList.size());
    ClipItem newItem;
    newItem.sourceUrl = sourceUrl;
    newItem.fileName = fileName;
    newItem.thumbnailUrls = QStringList(); // 初始空列表，永远不为undefined
    m_clipList.append(newItem);
    endInsertRows();
    return m_clipList.size() - 1;
}

void ClipModel::updateClipThumbnails(int rowIndex, const QStringList &urlList)
{
    if (rowIndex < 0 || rowIndex >= m_clipList.size()) return;
    m_clipList[rowIndex].thumbnailUrls = urlList;
    emit dataChanged(createIndex(rowIndex, 0), createIndex(rowIndex, 0), {ThumbnailUrls});
}
