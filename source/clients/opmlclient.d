module clients.opmlclient;
import clients.baseclient;
import requests;
import std.stdio;

class OpmlClient : BaseClient {

    this(string baseUrl) {
        super(baseUrl);
    }

    public void download() {
        auto rq = Request();
        Response rs = rq.get(baseUrl ~ "/opml");
        File f = File("opml", "wb");
        f.rawWrite(rs.responseBody.data);
        f.close();
    }


}