module clients.feedsclient;
import std.utf;
import std.conv;
import requests;
import asdf;
import models;
import clients.baseclient;

class FeedsClient: BaseClient {

    this(string baseUrl) {
        super(baseUrl);
    }

    public Page favorites(uint offset = 0, uint limit = 30) {
        return get(api ~ "/feeds/favorites?offset=" ~
        to!string(offset) ~ "&limit=" ~ to!string(limit)).deserialize!(Page);
    }
}
