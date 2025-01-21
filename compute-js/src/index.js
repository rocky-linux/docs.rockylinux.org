/// <reference types="@fastly/js-compute" />
import { getServer } from '../static-publisher/statics.js';
import { CacheOverride } from "fastly:cache-override";
// import { SimpleCache } from 'fastly:cache';

const staticContentServer = getServer();

const backendName = "docs-vercel";

import { Logger } from "fastly:logger";
import { env } from "fastly:env";

// eslint-disable-next-line no-restricted-globals
addEventListener("fetch", (event) => event.respondWith(handleRequest(event)));
async function handleRequest(event) {
  const originalRequest = event.request;
  const url = new URL(originalRequest.url);
  const path = url.pathname;

  const logger = new Logger("JavaScriptLog");

  const region = env("FASTLY_REGION");
  const devMode = region === "Somewhere" ? true : false;

  async function debugLog(msg) {
    if (devMode) {
      console.log("[" + path + "] " + msg);
      logger.log("[" + path + "] " + msg);
    }
  }

  let cacheOverride = new CacheOverride("override", {
    swr: '600', // stale while revalidate
    surrogateKey: 'docs',
    ttl: 21600,
  });
  let vercelOverride = cacheOverride;
  vercelOverride.surrogateKey = 'vercel';

  // Check if the requested path has a locale slug (e.g., /fr/)
  // TODO(neil): this should be generated from the config
  const localeRegex = /\/(af|de|fr|es|id|it|ja|ko|zh|sv|tr|pl|pt|pt-BR|ru|uk)\//
  const hasLocaleSlug = localeRegex.test(path);

  var beresp;

  // If there's a locale slug, try serving the translation
  if (hasLocaleSlug) {
    debugLog("Attempting to serve localized page for " + path);
    beresp = await staticContentServer.serveRequest(event.request, 'public, max-age=21600, stale-while-revalidate=600');
    if (beresp != null && beresp.status < 400) {
      return beresp;
    }
  }

  // If no translation is found or there's no locale slug, serve the English version
  fallbackPath = hasLocaleSlug ? path.replace(localeRegex, '/') : path;
  const bereq = new Request(url.origin + path);
  beresp = await staticContentServer.serveRequest(bereq, 'public, max-age=21600, stale-while-revalidate=600')
  if (beresp != null && beresp.ok) {
    debugLog("Static content fetched from edge cache");
    return beresp;
  }

  // If neither translation nor English version is found, return a 404 response
  return new Response('Not found', { status: 404 });
}
