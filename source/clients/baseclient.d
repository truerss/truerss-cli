module clients.baseclient;
import requests;
import std.utf;
import apierror;

class BaseClient {
    protected string baseUrl;

    protected string api = "/api/v1";

    this(string baseUrl) {
        this.baseUrl = baseUrl;
    }

    protected string get(string url) {
        auto rq = Request();
        auto rs = rq.get(this.baseUrl ~ url);
        auto str = cast(string) (rs.responseBody);
        if (rs.code > 399) {
            throw new ApiError(rs.code, ValidationError.empty(str));
        }
        return str;
    }
}
