import * as React from "react";
import Page from "../components/Page";

/**
 * Parses an author text, following the same format as NPM's `author` field.
 * @param {string} text The author text to parse
 */
const formatAuthor = text => {
    const out = {};

    // Check if author string includes emails
    if (text.includes('<') && text.includes('>')) {
        const startPos = text.lastIndexOf('<') + 1;

        const len = text.lastIndexOf('>') - startPos; // Get email length
        out.email = text.substr(startPos, len); // Get the email as a substring
        text = text.replace(`<${out.email}>`, ''); // Remove the email from the text
    }

    out.name = text.trim();

    return out;
}

export default ({ children, pageContext: { frontmatter } }) => {
    let author = undefined;
    if (frontmatter.author) {
        author = formatAuthor(frontmatter.author);
    }
    return (
        <Page meta={{ title: frontmatter.title }}>
            <div>
                <h1 className="mb-2">{ frontmatter.title }</h1>
                {author ? <span id="author" className="italic">By {author.name}</span> : null}
            </div>
            <hr />
            <div className="prose max-w-full dark-mode:prose-dark dark:text-gray-300 pb-10">
                { children }
            </div>
        </Page>
    );
};