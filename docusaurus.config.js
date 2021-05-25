/** @type {import('@docusaurus/types').DocusaurusConfig} */
module.exports = {
  title: 'Rocky Linux Docs',
  tagline: 'The official source for Rocky Linux documentation',
  url: 'https://docs.rockylinux.org',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',
  organizationName: 'rocky-linux', // Usually your GitHub org/user name.
  projectName: 'documentation', // Usually your repo name.
  themeConfig: {
    navbar: {
      title: 'Documentation',
      logo: {
        alt: 'Rocky Linux Logo',
        src: 'https://raw.githubusercontent.com/rocky-linux/branding/main/logo/src/icon-primary.svg',
      },
      items: [
        {
          type: 'doc',
          docId: 'en/index',
          position: 'left',
          label: 'Table of Contents',
        },
        {
          href: 'https://github.com/rocky-linux/documentation',
          label: 'GitHub (Content)',
          position: 'right',
        },
        {
          href: 'https://github.com/rocky-linux/docs.rockylinux.org',
          label: 'GitHub (UI)',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Community',
          items: [
            {
              label: 'Mattermost',
              href: 'https://chat.rockylinux.org',
            },
            {
              label: 'Forums',
              href: 'https://forums.rockylinux.org',
            },
            {
              label: 'Reddit',
              href: 'https://reddit.com/r/rockylinux',
            },
            {
              label: 'Twitter',
              href: 'https://twitter.com/rocky_linux',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'Wiki',
              to: 'https://wiki.rockylinux.org',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/rocky-linux',
            },
            {
              label: 'GitLab',
              href: 'https://git.rockylinux.org',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Rocky Enterprise Software Foundation. Built with Docusaurus.`,
    },
    algolia: {
      apiKey: '0194e174499263cab0b1fcd3f16765af',
      indexName: 'rockylinux'
    }
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl:
            'https://github.com/rocky-linux/documentation/edit/main/',
        },
        blog: false,
        pages: {},
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};
