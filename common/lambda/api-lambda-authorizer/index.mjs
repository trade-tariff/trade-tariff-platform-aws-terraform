import { createDecipheriv } from "crypto";
import { createPublicKey } from "crypto";

const REGION        = process.env.AWS_REGION;
const USER_POOL_ID  = process.env.COGNITO_USER_POOL_ID;
const REQUIRED_SCOPE = process.env.REQUIRED_SCOPE ?? "tariff/read";

const ISSUER   = `https://cognito-idp.${REGION}.amazonaws.com/${USER_POOL_ID}`;
const JWKS_URL = `${ISSUER}/.well-known/jwks.json`;

// Module-level cache — survives across warm invocations
let jwksCache = null;
let jwksCacheTime = 0;
const JWKS_CACHE_TTL_MS = 10 * 60 * 1000; // 10 minutes

async function getJwks() {
  const now = Date.now();
  if (jwksCache && (now - jwksCacheTime) < JWKS_CACHE_TTL_MS) {
    return jwksCache;
  }
  const res = await fetch(JWKS_URL);
  if (!res.ok) throw new Error(`Failed to fetch JWKS: ${res.status}`);
  jwksCache = await res.json();
  jwksCacheTime = now;
  return jwksCache;
}

function base64UrlDecode(str) {
  const padded = str.replace(/-/g, "+").replace(/_/g, "/");
  const pad = padded.length % 4;
  return Buffer.from(pad ? padded + "=".repeat(4 - pad) : padded, "base64");
}

function parseJwt(token) {
  const parts = token.split(".");
  if (parts.length !== 3) throw new Error("Invalid JWT structure");
  return {
    header:  JSON.parse(base64UrlDecode(parts[0])),
    payload: JSON.parse(base64UrlDecode(parts[1])),
    signature: parts[2],
    raw: { header: parts[0], payload: parts[1], signature: parts[2] }
  };
}

async function verifySignature(token, jwks) {
  const { header, raw } = parseJwt(token);

  const jwk = jwks.keys.find(k => k.kid === header.kid);
  if (!jwk) throw new Error(`No JWK found for kid: ${header.kid}`);
  if (jwk.alg !== "RS256") throw new Error(`Unexpected algorithm: ${jwk.alg}`);

  const key = await crypto.subtle.importKey(
    "jwk",
    jwk,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["verify"]
  );

  const data    = Buffer.from(`${raw.header}.${raw.payload}`);
  const sig     = base64UrlDecode(raw.signature);
  const valid   = await crypto.subtle.verify("RSASSA-PKCS1-v1_5", key, sig, data);

  if (!valid) throw new Error("Signature verification failed");
}

function validateClaims(payload) {
  const now = Math.floor(Date.now() / 1000);

  if (payload.iss !== ISSUER)
    throw new Error(`Issuer mismatch: ${payload.iss}`);

  if (payload.exp <= now)
    throw new Error(`Token expired at ${payload.exp}`);

  if (payload.token_use !== "access")
    throw new Error(`Invalid token_use: ${payload.token_use}`);

  const scopes = (payload.scope ?? "").split(" ");
  if (!scopes.includes(REQUIRED_SCOPE))
    throw new Error(`Missing required scope. Got: ${scopes}`);
}

function extractToken(event) {
  // TOKEN authorizer type sends authorizationToken directly
  const raw = event.authorizationToken
    ?? event.headers?.Authorization
    ?? event.headers?.authorization;

  if (!raw) return null;
  const parts = raw.split(" ");
  return parts.length === 2 && parts[0].toLowerCase() === "bearer"
    ? parts[1]
    : parts[0];
}

function buildPolicy(effect, methodArn, payload) {
  // Wildcard the ARN so a cached policy covers all methods on the stage
  // arn:aws:execute-api:region:account:api-id/stage/METHOD/resource
  //                                          ↑ keep only up to stage
  const [arnPrefix, apiGatewayPart] = methodArn.split(":");
  const parts = methodArn.split(":");
  const gwParts = parts[5].split("/");
  const wildcardArn = [...parts.slice(0, 5), gwParts.slice(0, 2).join("/") + "/*/*"].join(":");

  return {
    principalId: payload.sub ?? "unknown",
    policyDocument: {
      Version: "2012-10-17",
      Statement: [{
        Action:   "execute-api:Invoke",
        Effect:   effect,
        Resource: wildcardArn
      }]
    },
    context: {
      sub:      payload.sub,
      scope:    payload.scope,
      clientId: payload.client_id
    }
  };
}

export const handler = async (event) => {
  const token = extractToken(event);

  if (!token) {
    console.log("No token found in request");
    throw new Error("Unauthorized");
  }

  try {
    const { payload } = parseJwt(token);
    const jwks = await getJwks();

    await verifySignature(token, jwks);
    validateClaims(payload);

    console.log(`Authorized: sub=${payload.sub} scope=${payload.scope}`);
    return buildPolicy("Allow", event.methodArn, payload);

  } catch (err) {
    console.log(`Unauthorized: ${err.message}`);
    throw new Error("Unauthorized"); // APIGW interprets throw as 401
  }
};
