/// <reference types="@fastly/js-compute" />
import { getServer } from '../static-publisher/statics.js';
import { CacheOverride } from "fastly:cache-override";
// import { allowDynamicBackends } from "fastly:experimental";
//
// allowDynamicBackends(true);
const staticContentServer = getServer();

const backendName = "docs-vercel";

import { Logger } from "fastly:logger";

// eslint-disable-next-line no-restricted-globals
addEventListener("fetch", (event) => event.respondWith(handleRequest(event)));
async function handleRequest(event) {
  const originalRequest = event.request;
  const url = new URL(event.request.url);
  const path = url.pathname;

  const logger = new Logger("JavaScriptLog");

  function doLog(msg) {
    console.log("[" + path + "]" + msg);
    logger.log("[" + path + "]" + msg);
  }

  // Check if the requested path has a locale slug (e.g., /fr/)
  const localeRegex = /\/(af|de|fr|es|id|it|ja|ko|zh|sv|tr|pl|pt|pt-BR|ru|uk)\//
  const hasLocaleSlug = localeRegex.test(path);

  // If there's a locale slug, try serving the translation
  if (hasLocaleSlug) {
    doLog("Attempting to serve localized page for " + path);
    var response = await staticContentServer.serveRequest(event.request);
    if (response == null || response.status > 400) {
        doLog("Failed to serve localized page. Attempting to serve page from Vercel");
        // let cacheOverride = new CacheOverride("override", { ttl: 60 });
        response = await fetch(event.request, { backend: backendName });
        doLog("[vercel] " +response.url+"|"+response.status);
        if (response != null && response.status < 400) {
          doLog("Fetched localized content from Vercel");
          return response
        }
    }
  }

  doLog("begin default route handling");
  // If no translation is found or there's no locale slug, serve the English version
  const englishPath = path.replace(localeRegex, '/');
  const englishRequest = new Request(url.origin + englishPath);
  const englishResponse = await staticContentServer.serveRequest(englishRequest);

  if (englishResponse != null && englishResponse.status < 400) {
    doLog("fetched content from edge cache");
    return englishResponse;
  }

  doLog("failed to fetch content from edge cache; attempt to serve from vercel");
  // If we **still** can't find the artifact, try to find it on docs.r.o for the user, I guess
  // let cacheOverride = new CacheOverride("override", { ttl: 60 });
  response = await fetch(originalRequest, { backend: backendName });

  if (response != null && response.status < 400) {
    doLog("fetched content from vercel");
    return response
  }

  doLog("request failed. return 404");
  // If neither translation nor English version is found, return a 404 response
  return new Response('Not found', { status: 404 });
}
