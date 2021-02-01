module.exports = {
    siteMetadata: {
        title: "Rocky Linux Documentation",
        siteUrl: process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}/` : 'http://localhost:8000'
    },
    plugins: [
        {
            resolve: "gatsby-plugin-manifest",
            options: {
                name: "Rocky Linux Documentation",
                short_name: "Rocky Docs",
                start_url: "/",
                background_color: "#18181b",
                theme_color: "#10B981",
                display: "standalone",
                icon: "src/images/favicon.ico"
            }
        },
        "gatsby-plugin-postcss",
        "gatsby-plugin-sharp",
        "gatsby-plugin-react-helmet",
        "gatsby-plugin-sitemap",
        "gatsby-plugin-offline",
        {
            resolve: "gatsby-plugin-manifest",
            options: {
                icon: "src/images/icon.png",
            },
        },
        "gatsby-transformer-sharp",
        {
            resolve: "gatsby-source-filesystem",
            options: {
                name: "images",
                path: "./src/images/",
            },
            __key: "images",
        },
        {
            resolve: "gatsby-source-filesystem",
            options: {
                name: "pages",
                path: "./src/pages/",
            },
            __key: "pages",
        },
        {
            resolve: "gatsby-source-filesystem",
            options: {
                name: "contents",
                path: "./src/content/",
            },
            __key: "contents",
        },
        {
            resolve: `gatsby-plugin-page-creator`,
            options: {
                path: `./src/content`,
            },
        },
        {
            resolve: "gatsby-plugin-mdx",
            options: {
                extensions: [`.mdx`, `.md`],
                defaultLayouts: {
                    default: require.resolve('./src/_util/contentPage')
                }
            }
        },
    ],
};
