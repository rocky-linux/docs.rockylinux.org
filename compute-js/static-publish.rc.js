/*
 * Copyright Fastly, Inc.
 * Licensed under the MIT license. See LICENSE file for details.
 */

// Commented items are defaults

/** @type {import('@fastly/compute-js-static-publish').StaticPublisherConfig} */
const config = {
  rootDir: "../build/minified/site",
  staticContentRootDir: "./static-publisher",
  kvStoreName: "docs.rockylinux.org",
  // excludeDirs: [ './node_modules' ],
  // excludeDotFiles: true,
  // includeWellKnown: true,
  // contentAssetInclusionTest: (filename) => true,
  contentCompression: [ 'br', 'gzip' ], // For this config value, default is [] if kvStoreName is null.
  // moduleAssetInclusionTest: (filename) => false,
  // contentTypes: [
  //   { test: /.custom$/, contentType: 'application/x-custom', text: false },
  // ],
  server: {
    publicDirPrefix: "",
    staticItems: ["/search/search_index.json"],
    staticDir: "../build/minified/site/assets",
    compression: [ 'br', 'gzip' ],
    spaFile: false,
    notFoundPageFile: "/404.html",
    autoExt: [],
    autoIndex: ["index.html","index.htm"],
  },
};

export default config;
