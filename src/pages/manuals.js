import { graphql } from "gatsby";
import * as React from "react";
import Page from "../components/Page";

export default ({ data: { allMdx: { edges } } }) => {
    return (
        <Page meta={{ title: 'Manuals' }}>
            <h1>Manuals</h1>
            <hr />

            { edges.map(({ node: item }) => (
                <>
                    <a href={`/${item.slug}`} key={item.id}>{item.frontmatter.title}</a>
                    <br />
                </>
            )) }
        </Page>
    );
};

export const pageQuery = graphql`
    {
        allMdx(filter: { slug: { glob: "manuals/**/*" } }) {
            edges {
                node {
                    id
                    frontmatter { title }
                    slug
                }
            }
        }
    }
`;