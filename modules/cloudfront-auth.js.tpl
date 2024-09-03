function handler(event) {
  var authHeaders = event.request.headers.authorization;
  var expected = "Basic ${base64}";

  if (authHeaders && authHeaders.value === expected) {
    return event.request;
  }

  var response = {
    statusCode: 401,
    statusDescription: "Unauthorized",
    headers: {
      "www-authenticate": {
        value: 'Basic realm="OTT Backups"',
      },
    },
  };

  return response;
}
