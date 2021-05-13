module models;
import asdf;

struct NewSource {
    string url;
    string name;
    int interval;
}

struct FeedsFrequency
{
    double perDay;
    double perWeek;
    double perMonth;
}

struct Ignore {

}

struct Alias {
    string name;
}

struct SourceOverview
{
    @Ignore()
    ulong sourceId;
    @Alias("Unread Count")
    uint unreadCount;
    @Alias("Favorites Count")
    uint favoritesCount;
    @Alias("Feeds Count")
    uint feedsCount;
    @Ignore()
    FeedsFrequency frequency;
}

enum State
{
    Neutral,
    Enabled,
    Disabled
}

struct SourceViewDto
{
    ulong id;
    string url;
    string name;
    uint interval;
    @Ignore()
    string normalized;
    @Alias("Last Update")
    string lastUpdate;
    uint count;
}

struct FeedDto
{
    ulong sourceId;
    string url;
    string title;
    string author;
    string publishedDate;
    @serdeOptional string description;
    @serdeOptional string content;
    @serdeKeys("favorite") bool isFavorite;
    @serdeKeys("read") bool isRead;
    @serdeKeys("delete") bool isDeleted;
}

struct Page
{
    int total;
    FeedDto[] resources;

    public bool isEmpty() {
        return total == 0;
    }
}

