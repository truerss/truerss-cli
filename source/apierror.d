module apierror;
import std.range;

class ApiError: Exception {
    private ValidationError _error;
    private int _code;

    this(int code, ValidationError error) {
      auto message = error.errors.join(", ");
      super(message);
      this._error = error;
      this._code = code;
    }

    public bool is404() {
        return _code == 404;
    }

}

struct ValidationError
{ 
   string[] errors;

    public static ValidationError empty(string msg) {
        string[] tmp = [msg];
        return ValidationError(tmp);
    }
}

// {"errors":["https://news.ycombinator.com is not a valid RSS/Atom feed"]}