const path = require("path");

exports.createPages = async ({ graphql, actions, reporter }) => {
    // Destructure the createPage function from the actions object
    const { createPage } = actions;
    const result = await graphql(`
        query {
            allMdx {
                edges {
                    node {
                        id
                        body
                        slug
                        tableOfContents
                        frontmatter { title }
                    }
                }
            }
        }
    `);
    if (result.errors) {
        reporter.panicOnBuild('🚨  ERROR: Loading "createPages" query');
    }
    // Create blog post pages.
    const posts = result.data.allMdx.edges;
    // you'll call `createPage` for each result
    posts.forEach(({ node }, index) => {
        createPage({
            path: `/${node.slug}`,
            component: path.resolve(`./src/_util/contentPage.js`),
            context: {
                id: node.id,
                body: node.body,
                headings: node.tableOfContents,
                frontmatter: node.frontmatter
            },
        });
    });
};