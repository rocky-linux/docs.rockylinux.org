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
            {data.map((item, index) => (
                <a key={index} href={item.slug} className="py-3 flex flex-col border-b border-gray-200 dark:border-gray-200">
                    <h4 className="mb-2">{item.frontmatter.title}</h4>
                    <p className="text-sm text-gray-500">{item.excerpt}</p>
                </a>
            ))}
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
                excerpt
                slug
            }
        }
    }
`;