module clients.sourceclient;
import std.utf;
import std.conv;
import requests;
import asdf;
import models;
import apierror;
import clients.baseclient;

class SourceClient: BaseClient {

    this(string baseUrl) {
        super(baseUrl);
    }

    public SourceViewDto[] getAllSources() {
        return get(api ~ "/sources/all").deserialize!(SourceViewDto[]);
    }

    public SourceViewDto getOne(uint id) {
        return get(api ~ "/sources/" ~ to!string(id)).deserialize!(SourceViewDto);
    }

    public Page latest() {
        return get(api ~ "/sources/latest").deserialize!(Page);
    }

    // todo generalize
    public bool addSource(NewSource newSource) {
        auto json = newSource.serializeToJson();
        auto r = postContent(baseUrl ~ api ~ "/sources", json);
        auto rq = Request();
        rq.method("post");
        auto rs = rq.post(baseUrl ~ api ~ "/sources", json);
        auto str = cast(string) (rs.responseBody);
        if (rs.code > 399) {
            auto tmp = str.deserialize!(ValidationError);
            throw new ApiError(rs.code, tmp);
        }
        return true;
    }

    public SourceOverview overview(uint sourceId) {
        return get(api ~ "/overview/" ~ to!string(sourceId)).deserialize!(SourceOverview);
    }

}
