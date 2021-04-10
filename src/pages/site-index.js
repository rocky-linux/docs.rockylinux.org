import { graphql } from 'gatsby';
import * as React from 'react';
import Page from '../components/Page';

export default ({ data }) => {
    data = data.allMdx.nodes;

    return (
        <Page meta={{ title: 'Site Index' }}>
            <h1>Site Index</h1>
            <hr />

            <ul className="list-disc list-inside">
            {data.map((item, index) => {
                let title = item.frontmatter.title;
                if (!title) {
                    title = item.headings[0] ? item.headings[0].value : 'Untitled Documentation Piece';
                }

                return (
                    <a key={index} href={item.slug} className="py-3 flex flex-col border-b border-gray-200 dark:border-gray-200">
                        <h5 className="mb-2 font-bold">{title}</h5>
                        <p className="text-sm text-gray-500">{item.excerpt}</p>
                    </a>
                );
            })}
            </ul>
        </Page>
    );
};

export const query = graphql`
    {
        allMdx {
            nodes {
                frontmatter {
                    title
                }
                headings(depth: h1) { value }
                excerpt
                slug
            }
        }
    }
`;