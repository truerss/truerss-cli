module commandcontroller;
import std.stdio;
import std.range;
import std.algorithm;
import std.algorithm.comparison;
import std.conv;
import std.array;
import std.typecons;
import std.traits;
import std.string;
import std.uri;
import url;
import std.algorithm.iteration;
import clients.sourceclient;
import clients.opmlclient;
import clients.feedsclient;
import models;
import apierror;

class CommandController {

    protected SourceClient _sourceClient;
    protected OpmlClient _opmlClient;
    protected FeedsClient _feedsClient;

    private static uint defaultSize = 10;

    public this(
        SourceClient sourceClient,
        OpmlClient opmlClient,
        FeedsClient feedsClient
    ) {
        _sourceClient = sourceClient;
        _opmlClient = opmlClient;
        _feedsClient = feedsClient;
    }

    public void all() {
       auto result = _sourceClient.getAllSources();
       foreach (source; result) {
         writeln(to!string(source.id) ~ ": " ~ source.url);
       }
    }

    public void latest() {
        auto page = _sourceClient.latest();
        printPage(page, "No entries");
    }

    public void favorites() {
        auto page = _feedsClient.favorites();
        printPage(page, "No new entries");
    }

    private static void printPage(Page page, string whenEmpty) {
        auto xs = page.resources;
        if (page.isEmpty()) {
            writeln("No new entries");
            return;
        }
        ulong max = 0;

        foreach (x; xs) {
            auto len = x.title.walkLength;
            if (len > max) {
                max = len;
            }
        }

        foreach (x; xs) {
            auto len = x.title.walkLength;
            auto diffSize = max - len + defaultSize;
            auto between = replicate(" ", diffSize);
            writeln(x.title ~ between ~ x.url);
        }
        writeln("Total: " ~ to!string(page.total));
    }

    public void download() {
        _opmlClient.download();
    }

    public void add(string url, string name, string interval) {
        auto tmpInterval = 8;
        auto tmpName = url.parseURL.host;

        if (uriLength(url) < 0) {
            writeln(url ~ " is not a valid URL!");
            return;
        }
        if (!interval.empty) {
            tmpInterval = conv( interval);
            if (tmpInterval <= 0) {
                writeln("Interval must be positive integer");
                return;
            }
        }
        if (!name.empty) {
            tmpName = name;
        }

        auto newSource = NewSource(url, tmpName, tmpInterval);
        try {
            auto result = _sourceClient.addSource(newSource);
            if (result) {
                writeln("Source " ~ url ~ " was added");
            } else {
                writeln("Source " ~ url ~ " was not added");
            }
        } catch(Exception ex) {
            writeln("Can not add new source " ~ url ~ " because: " ~ ex.message);
        }
    }

    private static int conv(string str) {
        try {
            return to!int(str);
        } catch (Exception ex) {
            return -1;
        }
    }

    public void overview(string str) {
        int id = 0;
        try {
            id = to!int(str);
            if (id <= 0) {
                overviewHelp(str);
                return;
            }
            auto source = _sourceClient.getOne(id);
            auto overview = _sourceClient.overview(id);
            auto tmp = max(findMax(source), findMax(overview));
            print(source, tmp);
            print(overview, tmp);

        } catch(ConvException ex) {
            overviewHelp(str);
        } catch(ApiError error) {
            if (error.is404()) {
                writeln("Source " ~ to!string(id) ~ " not found");
                return;
            }
            writeln(error.message());
        }
    }

    private ulong findMax(T)(T instance) {
        ulong max = 0;
        foreach (member; __traits(allMembers, T)) {
            auto len = member.walkLength;
            if (len > max) {
                max = len;
            }
        }
        return max;
    }

    private T print(T)(T instance, ulong max) {
        foreach (member; __traits(allMembers, T)) {
            auto value = __traits(getMember, instance, member);
            auto len = to!string(member).walkLength;
            auto attrs = __traits(getAttributes, __traits(getMember, T, member));
            auto field = member.capitalize;
            foreach(attr; attrs) {
                static if (is(typeof(attr) == Alias)) {
                    field = attr.name;
                }
            }
            if (!hasUDA!(__traits(getMember, T, member), Ignore)) {
                print(max, to!string(value), field);
            }
        }
        return instance;
    }

    private static void print(ulong max, string value, string member) {
        auto len = member.walkLength;
        auto diffSize = max - len + defaultSize;
        auto between = replicate(" ", diffSize);
        writeln(member ~ between ~ to!string(value));
    }

    private static overviewHelp(string str) {
        writeln("Positive number is required, given: " ~ str);
    }

}
