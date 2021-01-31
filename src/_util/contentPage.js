import * as React from "react";
import Page from "../components/Page";

export default ({ children, pageContext: { frontmatter } }) => {
    console.log(frontmatter);
    return (
        <Page meta={{ title: frontmatter.title }}>
            <div className="prose max-w-full dark-mode:prose-dark dark:text-gray-300">
                <h1>{frontmatter.title}</h1>
                <hr />
                { children }
            </div>
        </Page>
    );
};