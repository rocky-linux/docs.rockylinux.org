import { graphql } from 'gatsby';
import * as React from 'react';
import Container from '../components/Container';
import Page from '../components/Page';

const SiteIndexPage = ({ data }) => {
    data = data.allMdx.nodes;

    return (
        <Page nopad meta={{ title: 'Site Index' }}>
            <div className="border-b border-gray-200 flex flex-col justify-center h-44">
                <div className="max-w-screen-lg w-full mx-auto px-4">
                    <h1>Site Index</h1>
                    <p className="text-gray-500 pt-2">
                        A single page covering every article of documentation we
                        hold.
                    </p>
                </div>
            </div>
            <Container>
                <div className="grid grid-cols-1 md:grid-cols-2 2xl:grid-cols-3 gap-4">
                    {data.map((item, index) => {
                        let title = item.frontmatter.title;
                        if (!title) {
                            title = item.headings[0]
                                ? item.headings[0].value
                                : 'Untitled Documentation Piece';
                        }

                        let excerpt = item.excerpt.replace(title, '').trim();

                        return (
                            <a
                                key={index}
                                href={`/${item.slug}`}
                                className="bg-white dark:bg-gray-700 shadow-md hover:shadow-lg rounded-md flex flex-col p-6 transition duration-200"
                            >
                                <h5 className="mb-2 font-bold dark:text-gray-300">
                                    {title}
                                </h5>
                                <p className="text-sm text-gray-500 dark:text-gray-400 break-words">
                                    {excerpt}
                                </p>
                            </a>
                        );
                    })}
                </div>
            </Container>
        </Page>
    );
};

export default SiteIndexPage;

export const query = graphql`
    {
        allMdx {
            nodes {
                frontmatter {
                    title
                }
                headings(depth: h1) {
                    value
                }
                excerpt(truncate: true, pruneLength: 300)
                slug
            }
        }
    }
`;
