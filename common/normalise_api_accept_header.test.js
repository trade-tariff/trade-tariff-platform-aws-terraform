// Run with: node --test common/
//
// CloudFront Functions are plain scripts with a global handler, not modules,
// so we load the source into a fresh context and call handler from there.

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

const source = fs.readFileSync(path.join(__dirname, 'normalise_api_accept_header.js'), 'utf8');

function runHandler(headers) {
  const context = vm.createContext({});
  vm.runInContext(source, context);

  return context.handler({ request: { uri: '/uk/api/commodities/0101210000', headers: headers } });
}

const CANONICAL = 'application/vnd.hmrc.2.0+json';

test('sets the canonical value when the Accept header is missing', async () => {
  const request = await runHandler({});

  assert.equal(request.headers.accept.value, CANONICAL);
});

for (const value of ['*/*', 'application/json', 'application/vnd.hmrc.2.0+json', ' Application/JSON ']) {
  test(`replaces "${value}" with the canonical value`, async () => {
    const request = await runHandler({ accept: { value: value } });

    assert.equal(request.headers.accept.value, CANONICAL);
  });
}

for (const value of [
  'text/csv',
  'application/vnd.hmrc.1.0+json',
  'application/vnd.hmrc.2.0+csv',
  'application/json, text/plain, */*',
  'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
]) {
  test(`keeps "${value}" unchanged`, async () => {
    const request = await runHandler({ accept: { value: value } });

    assert.equal(request.headers.accept.value, value);
  });
}

test('keeps the other headers and the uri unchanged', async () => {
  const request = await runHandler({ authorization: { value: 'Bearer token' } });

  assert.equal(request.headers.authorization.value, 'Bearer token');
  assert.equal(request.uri, '/uk/api/commodities/0101210000');
});
