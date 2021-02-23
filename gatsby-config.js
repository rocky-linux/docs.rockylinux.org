module.exports = {
    siteMetadata: {
        title: 'Rocky Linux Documentation',
        siteUrl: process.env.VERCEL_URL
            ? `https://${process.env.VERCEL_URL}/`
            : 'http://localhost:8000',
    },
    plugins: [
        'gatsby-plugin-postcss',
        'gatsby-plugin-sharp',
        'gatsby-plugin-react-helmet',
        'gatsby-plugin-sitemap',
        {
            resolve: 'gatsby-plugin-manifest',
            options: {
                name: 'Rocky Linux Documentation',
                short_name: 'Rocky Docs',
                start_url: '/',
                background_color: '#18181b',
                theme_color: '#10B981',
                display: 'standalone',
                icon: 'src/images/icon.svg',
            },
        },
        'gatsby-plugin-offline',
        'gatsby-transformer-sharp',
        {
            resolve: 'gatsby-source-filesystem',
            options: {
                name: 'images',
                path: './src/images/',
            },
            __key: 'images',
        },
        {
            resolve: 'gatsby-source-filesystem',
            options: {
                name: 'pages',
                path: './src/pages/',
            },
            __key: 'pages',
        },
        {
            resolve: `gatsby-source-git`,
            options: {
                name: `rocky-docs`,
                remote: `https://github.com/hbjydev/documentation.git`,
                branch: `docs-site-changes`,
            },
            __key: 'contents',
        },
        {
            resolve: 'gatsby-plugin-mdx',
            options: {
                extensions: [`.mdx`, `.md`],
                remarkPlugins: [
                    require('remark-slug'),
                    require('remark-highlight.js'),
                ],
            },
        },
    ],
};
