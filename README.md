# docs.rockylinux.org

## Overview

This repository is responsible for building and deploying the official Rocky Linux documentation site, hosted at [docs.rockylinux.org](https://docs.rockylinux.org). The site is built and deployed automatically via the [Vercel](https://vercel.com/) platform.

> [!IMPORTANT]
> This repository contains the *build and deployment logic only*. It does not contain the documentation content itself.

## Table of Contents
- [Content Source](#content-source)
- [How the Build Process Works](#how-the-build-process-works)
- [Key Files & Scripts](#key-files--scripts)
- [Deep Dive: The `vercel-build.sh` Script](#deep-dive-the-vercel-buildsh-script)
- [How to Maintain the Site](#how-to-maintain-the-site)
- [Managing Deployments on Vercel](#managing-deployments-on-vercel)
  - [Vercel CLI](#vercel-cli)
  - [Vercel Web UI](#vercel-web-ui)
- [Local Development & Testing](#local-development--testing)

## Content Source

All documentation content is sourced from the [rocky-linux/documentation](https://github.com/rocky-linux/documentation) GitHub repository. The build script in this repository clones the content repo during the Vercel deployment process.

## How the Build Process Works

The deployment process is orchestrated by Vercel, which executes a custom build script.

1.  **Trigger:** A push to this repository's `main` branch triggers a new build on Vercel.
2.  **Build:** Vercel runs the `./scripts/vercel-build.sh` script, which uses [mkdocs](https://www.mkdocs.org/) and the [mike](https://github.com/jimporter/mike) plugin to build a versioned static HTML site.
3.  **Deploy:** The script places the final generated site into the `site/` directory, which Vercel then deploys to production.
4.  **URL Structure:** The site uses a "Root + Versioned" deployment strategy. The latest documentation (currently Rocky Linux 10) is served from the root URL (`/`), while all documentation versions remain accessible via versioned paths (e.g., `/8/`, `/9/`, `/latest/`).

## Key Files & Scripts

-   `vercel.json`: Configures Vercel to use the custom build command and specifies the output directory (`site`).
-   `scripts/vercel-build.sh`: The primary script that orchestrates the entire build. It contains all the logic for cloning, versioning, and building the documentation.
-   `requirements.txt`: A standard Python file listing the dependencies required for the build, such as `mkdocs` and `mike`.
-   `mkdocs.yml`: The main configuration file for `mkdocs`. The build script manages which configuration is used for the build.

## Deep Dive: The `vercel-build.sh` Script

This script is the heart of the repository and is designed to run within the Vercel environment. For maintainers, understanding its structure is key.

#### Stage 1: Initialization
The script begins by installing Python dependencies from `requirements.txt`. It also creates a small `mkdocs` executable wrapper script. This ensures that `mike` can find and use the correct `mkdocs` instance within the Vercel build environment's `PATH`.

#### Stage 2: The `build_version` Function
This function is called for each documentation version that needs to be built. It:
1.  Clones a specific branch (e.g., `rocky-8`) from the `rocky-linux/documentation` repository.
2.  Crucially, it performs a full clone to preserve the entire git history. This is required for the `git-revision-date-localized-plugin` to accurately display when a page was last updated.
3.  It uses symlinks to make the cloned content available to `mike` while preserving the git context.

#### Stage 3: Building with `mike`
After cloning a version, the script uses `mike deploy` to build the static HTML for that version. `mike` manages the versioning by committing the built site to a temporary `gh-pages` branch within the build environment. This process is repeated for all specified versions.

#### Stage 4: Site Extraction
Once `mike` has built all versions into the `gh-pages` branch, the script extracts the complete static site into the `site/` directory using `git archive`. This directory is the final artifact that Vercel will deploy.

#### Stage 5: Root Deployment
To ensure `docs.rockylinux.org` serves the latest documentation directly, the script performs a final step: it copies all content from the `site/latest/` directory to the root of the `site/` directory. It carefully preserves the `versions.json` file to ensure the version-switching dropdown menu continues to function correctly across the entire site.

## How to Maintain the Site

Maintenance typically involves modifying the build script to add, update, or remove documentation versions.

#### Adding a New Documentation Version
1.  Open `scripts/vercel-build.sh`.
2.  Find the section where `build_version` is called.
3.  Add a new line for the new version, specifying the version number and the corresponding branch name from the content repository. For example, to add Rocky Linux 11 from the `rocky-11` branch:
    ```bash
    build_version "11" "rocky-11" "" ""
    ```

#### Changing the Default Version
The default version is the one aliased to `latest`.
1.  Open `scripts/vercel-build.sh`.
2.  Modify the `build_version` call that includes `"latest"` as the alias. For example, to make version 11 the new latest:
    ```bash
    # Old
    build_version "10" "main" "latest" ""

    # New
    build_version "11" "rocky-11" "latest" ""
    ```
3.  The `mike set-default` command uses `latest`, so it does not need to be changed.

#### Removing an Old Version
1.  Open `scripts/vercel-build.sh`.
2.  Find the `build_version` call for the version you want to remove and delete or comment out the line.

## Managing Deployments on Vercel

Deployments are handled automatically by Vercel when commits are pushed to the `main` branch. However, maintainers can also manage deployments manually via the Vercel CLI or the web dashboard.

### Vercel CLI

For more direct control, the Vercel CLI is a powerful tool. It allows you to deploy, manage, and inspect your project from the command line.

#### 1. Installation
First, install the Vercel CLI globally using `npm` (Node.js is required):
```shell
npm i -g vercel
```

#### 2. Login
Log in to your Vercel account. This will likely open a browser window for authentication.
```shell
vercel login
```

#### 3. Linking the Project
Before you can manage a project, you must link your local directory to the remote Vercel project. This is a crucial one-time step.

```shell
# Clone the repository if you haven't already
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
cd docs.rockylinux.org

# Link the project
vercel link
```
The CLI will interactively guide you to select the correct Vercel scope (team) and project.

For non-interactive environments or to be explicit, you can use flags:
```shell
# Example of linking to a specific project within a specific scope (team)
vercel link --scope=rocky-linux-scope --project=docs-rockylinux-org
```
> [!NOTE]
> Replace `rocky-linux-scope` and `docs-rockylinux-org` with the actual scope and project names on Vercel.

#### 4. Triggering Manual Deployments
You can trigger new builds and deployments directly from your local machine. This is useful for testing changes in a preview environment before merging to `main`.

-   **Preview Deployment:** Create a unique preview deployment with its own URL. Vercel builds the project and provides a link to the result.
    ```shell
    vercel
    ```
-   **Production Deployment:** Push a new build to the official production domain (`docs.rockylinux.org`).
    ```shell
    vercel --prod
    ```
    > [!WARNING]
> This command updates the live site. It should only be used when you are certain the build is stable.

#### 5. Inspecting Deployments & Logs
-   **List Projects:** To see all projects you have access to:
    ```shell
    vercel project ls
    ```
-   **List Deployments:** To see a list of recent deployments for the linked project:
    ```shell
    vercel ls
    ```
-   **View Logs:** To view the build or runtime logs for a specific deployment in real-time, use the deployment URL provided by the `vercel` or `vercel ls` commands:
    ```shell
    vercel logs <deployment-url>
    ```

#### 6. CLI Troubleshooting
-   **Authentication Issues:** If you get permission errors, run `vercel login` again to re-authenticate.
-   **Wrong Project/Scope:** If commands are failing or not showing the right information, you may be linked to the wrong project. Run `vercel link` again to re-link your local directory. You can check the current link status by inspecting the `.vercel` directory.
-   **Build Failures:** If a manual deployment with `vercel` fails, the command will output a URL to the build logs for you to inspect.

### Vercel Web UI

The [Vercel Dashboard](https://vercel.com/) provides a user-friendly web interface for project management. After logging in and selecting the project, you can perform several key actions:

-   **Viewing Deployments:**
    1.  Navigate to the project's dashboard.
    2.  Click the **Deployments** tab.
    3.  Here you will see a complete history of all deployments (both production and preview), along with their status, branch, and commit message.

-   **Inspecting Logs:**
    1.  From the **Deployments** list, click on a specific deployment.
    2.  Select the **Build Logs** or **Functions** tab to view detailed logs. This is essential for diagnosing a failed build.

-   **Promoting to Production:**
    You can manually promote a successful preview deployment to production without needing a new build.
    1.  Find the desired preview deployment in the **Deployments** list.
    2.  Click the overflow menu (three dots) on the right.
    3.  Select **Promote to Production**.

-   **Managing Domains and Settings:**
    -   **Domains:** Use the **Settings -> Domains** tab to manage custom domains and subdomains.
    -   **Environment Variables:** Use the **Settings -> Environment Variables** tab to add, edit, or remove any necessary variables for the build environment.

## Local Development & Testing

You can simulate the Vercel build process locally to test changes.
1.  Ensure you have Python 3 and `pip` installed.
2.  Install the required dependencies:
    ```shell
    pip3 install -r requirements.txt
    ```
3.  Run the build script:
    ```shell
    ./scripts/vercel-build.sh
    ```
4.  The script will execute the full build process and place the output in the `site/` directory. You can inspect the contents or serve them locally with a simple web server to verify your changes.
    ```shell
    python3 -m http.server --directory site
    ```
