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
  let path = url.pathname;

  const logger = new Logger("JavaScriptLog");

  function doLog(msg) {
    console.log("[" + path + "] " + msg);
    logger.log("[" + path + "] " + msg);
  }

  let cacheOverride = new CacheOverride("override", {
    swr: '600', // stale while revalidate
    surrogateKey: 'docs',
    ttl: 21600,
  });

  // Check if the requested path has a locale slug (e.g., /fr/)
  const localeRegex = /\/(af|de|fr|es|id|it|ja|ko|zh|sv|tr|pl|pt|pt-BR|ru|uk)\//
  const hasLocaleSlug = localeRegex.test(path);

  var beresp;

  // If there's a locale slug, try serving the translation
  if (hasLocaleSlug) {
    doLog("Attempting to serve localized page for " + path);
    beresp = await staticContentServer.serveRequest(event.request, 'public, max-age=21600, stale-while-revalidate=600');
    if (beresp == null || beresp.status > 400) {
        // doLog("Failed to serve localized page. Attempting to serve page from Vercel");
        beresp = await fetch(event.request, {backend: backendName, cacheOverride});
        // doLog("[vercel] " +beresp.url+"|"+beresp.status);
        if (beresp != null && beresp.status < 400) {
          doLog("Localized content fetched from Vercel");
          return beresp
        }
    }
  }

  // If no translation is found or there's no locale slug, serve the English version
  path = hasLocaleSlug ? path.replace(localeRegex, '/') : path;
  const bereq = new Request(url.origin + path);
  beresp = await staticContentServer.serveRequest(bereq, 'public, max-age=21600, stale-while-revalidate=600');

  if (beresp != null && beresp.status < 400) {
    doLog("Static content fetched from edge cache");
    return beresp;
  }

  // If we **still** can't find the artifact, try to find it on docs.r.o for the user, I guess
  // let cacheOverride = new CacheOverride("override", { ttl: 60 });
  beresp = await fetch(originalRequest, {backend: backendName, cacheOverride});

  if (beresp != null && beresp.status < 400) {
    doLog("content fetched from vercel (fallback)");
    return beresp
  }

  // If neither translation nor English version is found, return a 404 response
  return new Response('Not found', { status: 404 });
}
