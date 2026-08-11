// rewrite extensionless requests to '.html'
// and any requests ending in '/' to the index.html

async function handler(event) {
  var request = event.request;
  var uri = request.uri;

  if (uri.endsWith('/')) {
    request.uri += "index.html";
  } else if (!uri.includes('.')) {
    request.uri += '.html';
  }

  return request;
}
