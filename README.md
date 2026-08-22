# docs.rockylinux.org

## Overview

This repository is responsible for building and deploying the official Rocky Linux documentation site, hosted at [docs.rockylinux.org](https://docs.rockylinux.org). The site is built by GitHub Actions, published as static files to an S3 bucket, and served to the public through [Fastly](https://www.fastly.com/).

> [!IMPORTANT]
> This repository contains the *build and deployment logic only*. It does not contain the documentation content itself.

## Table of Contents
- [Content Source](#content-source)
- [How the Build Process Works](#how-the-build-process-works)
- [Key Files & Scripts](#key-files--scripts)
- [Deep Dive: The `build.sh` Script](#deep-dive-the-buildsh-script)
- [How to Maintain the Site](#how-to-maintain-the-site)
- [Deployment & Operations](#deployment--operations)
  - [Triggering a Deployment](#triggering-a-deployment)
  - [Purging the Fastly Cache](#purging-the-fastly-cache)
  - [Required Secrets & Variables](#required-secrets--variables)
  - [Troubleshooting](#troubleshooting)
- [Local Development & Testing](#local-development--testing)

## Content Source

All documentation content is sourced from the [rocky-linux/documentation](https://github.com/rocky-linux/documentation) GitHub repository. The build script in this repository clones the content repo at build time.

## How the Build Process Works

The pipeline is defined in `.github/workflows/build-docs.yml`.

1.  **Trigger:** A build starts on any of the following:
    - A push to this repository's `main` branch.
    - A daily schedule (`0 4 * * *` UTC), to pick up content changes in `rocky-linux/documentation`.
    - A manual `workflow_dispatch` run.
    - A `repository_dispatch` event of type `deploy-docs`, sent by the content repository when its docs change.

    Runs are serialized through the `s3-deploy` concurrency group, so deployments never overlap.

2.  **Build:** The workflow runs `./scripts/build.sh`, which uses [mkdocs](https://www.mkdocs.org/) and the [mike](https://github.com/jimporter/mike) plugin to build a versioned static HTML site into the `site/` directory.

3.  **Publish:** `aws s3 sync site/ s3://$S3_BUCKET/ --delete` uploads the result, with a `public, max-age=604800` cache header. The `--delete` flag means the bucket is an exact mirror of the build output.

4.  **Compress search indexes:** Each `search_index.json` is re-uploaded gzipped with `Content-Encoding: gzip`. These files can reach ~30MB uncompressed, which exceeds Fastly's cacheable object size limit, and S3 does not compress on the fly. Compressing them keeps the indexes cacheable at the edge and makes them roughly 6x faster to download.

5.  **Purge:** The workflow issues a Fastly soft purge for surrogate key `all`, so the edge picks up the new content. This step is `continue-on-error`, since a failed purge does not invalidate an otherwise successful deploy — the cache will expire on its own.

6.  **URL Structure:** The site uses a "Root + Versioned" deployment strategy. The latest documentation (currently Rocky Linux 10) is served from the root URL (`/`), while all documentation versions remain accessible via versioned paths (e.g., `/8/`, `/9/`, `/latest/`).

## Key Files & Scripts

-   `.github/workflows/build-docs.yml`: The build and deploy pipeline (build → S3 → Fastly purge).
-   `scripts/build.sh`: The primary script that orchestrates the entire build. It contains all the logic for cloning, versioning, and building the documentation.
-   `requirements.txt`: A standard Python file listing the dependencies required for the build, such as `mkdocs` and `mike`.
-   `configs/mkdocs.yml`: The main configuration file for `mkdocs`. The build script symlinks this to `mkdocs.yml` so `mike` can find it.

## Deep Dive: The `build.sh` Script

This script is the heart of the repository. For maintainers, understanding its structure is key.

#### Stage 1: Initialization
The script creates a Python 3.12 virtual environment with [`uv`](https://github.com/astral-sh/uv), installs the dependencies from `requirements.txt`, and puts `.venv/bin` on the `PATH` so `mkdocs` and `mike` resolve directly. It then applies a small in-place patch to `mkdocs-awesome-pages-plugin` for i18n stability.

#### Stage 2: The `build_version` Function
This function is called for each documentation version that needs to be built. It:
1.  Clones a specific branch (e.g., `rocky-8`) from the `rocky-linux/documentation` repository.
2.  Crucially, it performs a full clone to preserve the entire git history. This is required for the `git-revision-date-localized-plugin` to accurately display when a page was last updated.
3.  It uses symlinks to make the cloned content available to `mike` while preserving the git context.

#### Stage 3: Building with `mike`
After cloning a version, the script uses `mike deploy` to build the static HTML for that version. `mike` manages the versioning by committing the built site to a temporary `gh-pages` branch within the build environment. This process is repeated for all specified versions.

#### Stage 4: Site Extraction
Once `mike` has built all versions into the `gh-pages` branch, the script extracts the complete static site into the `site/` directory using `git archive`. This directory is the final artifact that gets synced to S3.

#### Stage 5: Root Deployment
To ensure `docs.rockylinux.org` serves the latest documentation directly, the script performs a final step: it copies all content from the `site/latest/` directory to the root of the `site/` directory. It carefully preserves the `versions.json` file to ensure the version-switching dropdown menu continues to function correctly across the entire site.

> [!WARNING]
> To give `mike` a repository to work in, the script deletes and re-initializes `.git` in the working directory. This is safe on a throwaway CI runner, but it will destroy your local git state if you run the script directly in a checkout you care about. See [Local Development & Testing](#local-development--testing).

## How to Maintain the Site

Maintenance typically involves modifying the build script to add, update, or remove documentation versions.

#### Adding a New Documentation Version
1.  Open `scripts/build.sh`.
2.  Find the section where `build_version` is called.
3.  Add a new line for the new version, specifying the version number and the corresponding branch name from the content repository. For example, to add Rocky Linux 11 from the `rocky-11` branch:
    ```bash
    build_version "11" "rocky-11" "" ""
    ```

#### Changing the Default Version
The default version is the one aliased to `latest`.
1.  Open `scripts/build.sh`.
2.  Modify the `build_version` call that includes `"latest"` as the alias. For example, to make version 11 the new latest:
    ```bash
    # Old
    build_version "10" "main" "latest" ""

    # New
    build_version "11" "rocky-11" "latest" ""
    ```
3.  The `mike set-default` command uses `latest`, so it does not need to be changed.

#### Removing an Old Version
1.  Open `scripts/build.sh`.
2.  Find the `build_version` call for the version you want to remove and delete or comment out the line.

> [!NOTE]
> Because the S3 sync uses `--delete`, removing a version from the build script also removes it from the live site on the next deploy.

## Deployment & Operations

Deployments are fully automated. Pushing to `main` — or a content change in `rocky-linux/documentation` — is all that is normally required.

### Triggering a Deployment

To start a build manually without pushing a commit:

```shell
# Requires the GitHub CLI, authenticated with access to the repo
gh workflow run build-docs.yml -R rocky-linux/docs.rockylinux.org
```

To watch the run and inspect logs:

```shell
gh run list   -R rocky-linux/docs.rockylinux.org --workflow=build-docs.yml --limit 5
gh run watch  -R rocky-linux/docs.rockylinux.org <run-id>
gh run view   -R rocky-linux/docs.rockylinux.org <run-id> --log-failed
```

The same workflow can also be triggered from the content repository via a `repository_dispatch` event of type `deploy-docs`.

### Purging the Fastly Cache

The workflow soft-purges the whole service after every successful deploy. To purge by hand — for example if the purge step failed, or if you changed something at the Fastly layer:

```shell
curl -X POST \
  "https://api.fastly.com/service/$FASTLY_SERVICE_ID/purge" \
  -H "Fastly-Key: $FASTLY_API_TOKEN" \
  -H "Fastly-Soft-Purge: 1" \
  -H "Surrogate-Key: all" \
  -H "Accept: application/json"
```

`FASTLY_SERVICE_ID` is exported by `.envrc` (via [direnv](https://direnv.net/)). Put your personal `FASTLY_API_TOKEN` in `.envrc.local`, which is git-ignored.

A soft purge marks content stale rather than evicting it, so the edge keeps serving the old copy until the new one is fetched. There is no hard-down window.

### Required Secrets & Variables

Configured in the repository's **Settings → Secrets and variables → Actions**.

| Name | Type | Purpose |
| --- | --- | --- |
| `S3_BUCKET` | secret | Destination bucket name for the built site |
| `AWS_ACCESS_KEY_ID` | secret | Credentials for the S3 sync |
| `AWS_SECRET_ACCESS_KEY` | secret | Credentials for the S3 sync |
| `FASTLY_SERVICE_ID` | secret | Fastly delivery service fronting the bucket |
| `FASTLY_API_TOKEN` | secret | Token with purge rights on that service |
| `AWS_REGION` | variable | Region of the S3 bucket |

### Troubleshooting

-   **Build failed:** Use `gh run view <run-id> --log-failed`. The most common causes are an upstream change in `rocky-linux/documentation` that breaks a mkdocs plugin, or the `mkdocs-awesome-pages-plugin` patch in Stage 1 failing to apply after a dependency bump.
-   **Deploy succeeded but the site looks stale:** The purge step is `continue-on-error`, so check whether it actually succeeded, and re-run the manual purge above if not.
-   **A page 404s that used to work:** Remember the sync runs with `--delete`. If a page vanished from the build output, it is now gone from the bucket too.
-   **Search returns nothing:** Check that `search_index.json` is being served with `Content-Encoding: gzip` and a 200 status, e.g. `curl -sI https://docs.rockylinux.org/search/search_index.json`.

## Local Development & Testing

You can run the full build locally to test changes.

> [!CAUTION]
> `scripts/build.sh` is destructive to its working directory: it runs `rm -rf .git` and re-initializes a fresh repository, and it overwrites `README.md` with a placeholder. **Do not run it directly inside your working checkout.** Copy the repository to a scratch directory first:

```shell
cp -r docs.rockylinux.org /tmp/docs-build && cd /tmp/docs-build
```

1.  Install [`uv`](https://github.com/astral-sh/uv). The script creates its own Python 3.12 virtual environment and installs `requirements.txt` into it, so no other setup is needed.
2.  Run the build script:
    ```shell
    ./scripts/build.sh
    ```
3.  The script will execute the full build process and place the output in the `site/` directory. Serve it locally to verify your changes:
    ```shell
    python3 -m http.server --directory site
    ```

A full build clones three branches of the content repository with complete history. Expect it to take roughly 10 minutes and produce about 3.7GB in `site/`, plus the `rockydocs-8`, `rockydocs-9` and `rockydocs-10` clones and a `.venv`.

The many `WARNING - External file: ...` messages during the build are expected. They come from the `privacy` plugin running with `assets_fetch: false` and do not indicate a problem.
