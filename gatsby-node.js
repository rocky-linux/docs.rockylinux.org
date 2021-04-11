const path = require('path');

exports.createPages = async ({ graphql, actions, reporter }) => {
    // Destructure the createPage function from the actions object
    const { createPage } = actions;
    const result = await graphql(`
        query {
            allFile {
                edges {
                    node {
                        childMdx {
                            id
                            frontmatter {
                                title
                            }
                            body
                            tableOfContents
                        }
                        relativePath
                    }
                }
            }
        }
    `);
    if (result.errors) {
        reporter.panicOnBuild('🚨  ERROR: Loading "createPages" query');
    }
    // Create blog post pages.
    const posts = result.data.allFile.edges;
    // you'll call `createPage` for each result
    posts.forEach(({ node: { relativePath, childMdx: node } }) => {
        if (node !== null) {
            relativePath = relativePath.replace('.md', '');
            relativePath = relativePath.replace('.mdx', '');
            createPage({
                path: `/${relativePath}`,
                component: path.resolve(`./src/_util/contentPage.js`),
                context: {
                    id: node.id,
                    body: node.body,
                    headings: node.tableOfContents,
                    frontmatter: node.frontmatter,
                },
            });
        }
    });
};