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
                <li key={index}><a href={item.slug}>{item.frontmatter.title !== '' ? item.frontmatter.title : 'Nameless Documentation Piece'}</a></li>
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
                slug
            }
        }
    }
`;