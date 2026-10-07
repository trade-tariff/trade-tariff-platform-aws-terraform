// Give equal API requests one cache key.
//
// The Accept header is part of the CloudFront cache key for the API, because
// it can select the API version (v1 or v2) and the format (for example CSV).
// But clients send many values that the backend treats the same way: a
// missing header, */*, application/json and application/vnd.hmrc.2.0+json
// all give the same v2 JSON response. Without this function CloudFront keeps
// a separate copy of each response for each of these values.
//
// We change only those values. All other values go to the backend unchanged.

var CANONICAL_ACCEPT = 'application/vnd.hmrc.2.0+json';

var DEFAULT_JSON_ACCEPTS = {
  '*/*': true,
  'application/json': true,
  'application/vnd.hmrc.2.0+json': true,
};

async function handler(event) {
  var request = event.request;
  var accept = request.headers.accept;

  if (!accept) {
    request.headers.accept = { value: CANONICAL_ACCEPT };
    return request;
  }

  var value = accept.value.trim().toLowerCase();

  if (DEFAULT_JSON_ACCEPTS[value]) {
    request.headers.accept = { value: CANONICAL_ACCEPT };
  }

  return request;
}
