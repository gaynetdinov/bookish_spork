-module(bookish_spork_request).

-export([
    new/0,
    request_line/4,
    add_header/3,
    content_length/1
]).

-export([
    method/1,
    uri/1,
    version/1,
    headers/1,
    body/1,
    body/2
]).

-type http_version() :: {
    Major :: integer(),
    Minor :: integer()
}.

-record(request, {
    method        :: undefined | atom(),
    uri           :: undefined | string(),
    version       :: undefined | http_version(),
    headers = #{} :: map(),
    body          :: undefined | binary()
}).

-opaque request() :: #request{}.

-export_type([
    request/0
]).

-spec new() -> request().
%% @private
new() -> #request{}.

-spec request_line(
    Request :: request(),
    Method  :: atom(),
    Uri     :: string() | undefined,
    Version :: string() | undefined
) -> request().
%% @private
request_line(Request, Method, Uri, Version) ->
    Request#request{ method = Method, uri = Uri, version = Version }.

-spec add_header(Request :: request(), Name :: string(), Value :: string()) -> request().
%% @private
add_header(Request, Name, Value) when is_atom(Name) ->
    add_header(Request, atom_to_list(Name), Value);
add_header(#request{ headers = Headers } = Request, Name, Value) ->
    HeaderName = string:lowercase(Name),
    Request#request{ headers = maps:put(HeaderName, Value, Headers) }.

-spec content_length(Request :: request()) -> integer().
%% @doc Content-Length header value as intger
content_length(#request{ headers = Headers }) ->
    case maps:get("content-length", Headers, undefined) of
        undefined ->
            0;
        ContentLength ->
            list_to_integer(ContentLength)
    end.

-spec method(Request :: request()) -> atom().
%% @doc http verb: 'GET', 'POST','PUT', 'DELETE', 'OPTIONS', ...
method(#request{ method = Method}) -> Method.

-spec uri(Request :: request()) -> string().
%% @doc path with query string
uri(#request{ uri = Uri}) -> Uri.

-spec version(Request :: request()) -> string() | undefined.
%% @doc http protocol version tuple. Most often would be {1, 1}
version(#request{ version = Version }) -> Version.

-spec headers(Request :: request()) -> map().
%% @doc http headers map. Header names are normalized and lowercased
headers(#request{ headers = Headers }) -> Headers.

-spec body(Request :: request()) -> binary().
%% @doc request body
body(#request{ body = Body }) -> Body.

-spec body(Request :: request(), Body :: binary()) -> request().
%% @private
body(Request, Body) -> Request#request{ body = Body }.
