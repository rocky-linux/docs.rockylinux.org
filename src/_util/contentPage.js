import { Link } from 'gatsby';
import { MDXRenderer } from 'gatsby-plugin-mdx';
import { MDXProvider } from '@mdx-js/react';
import * as React from 'react';
import Page from '../components/Page';
import 'highlight.js/styles/atom-one-dark-reasonable.css';
import Container from '../components/Container';

const a = props => {
    let href = props.href;
    if (props.href && props.href.endsWith('.md')) {
        href = props.href.replace('.md', '');
    }

    return <a {...props} href={href} />
};

const components = { Link, a };

const buildContentList = (headings, topLevel) => {
    return (
        <ul className={`list-inside${topLevel ? '' : ' pl-2'}`}>
            {headings.items.map(buildContentItem)}
        </ul>
    );
};

const buildContentItem = (heading) => {
    const { title, url } = heading;
    let inner = null;

    if (heading.items) {
        inner = buildContentList(heading);
    }

    return (
        <li key={url}>
            <a className="dark:text-gray-200 text-gray-600" href={url}>
                {title}
            </a>
            {inner}
        </li>
    );
};

const contentPage = ({ pageContext: { frontmatter, headings, body, relativePath } }) => {
    let title = frontmatter.title;
    if (!frontmatter.title) {
        title = headings.items[0].title;
    }

    return (
        <Page ultrawide meta={{ title: title }}>
            <Container wide noPadTop>
                <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
                    <div className="md:col-span-2 lg:col-span-3 xl:col-span-3">
                        <div
                            className="text-sm block xl:hidden border-l-4 w-full pl-4 border-gray-200 dark:border-gray-600 transition duration-300 ease-in-out mb-6"
                            style={{
                                height: 'fit-content',
                                '-moz-height': '-moz-fit-content',
                            }}
                        >
                            {buildContentList(headings, true)}
                            <hr className="w-full border-1 dark:border-gray-600 border-gray-200 border my-2" />
                            <a className="text-sm" href={`https://github.com/rocky-linux/documentation/blob/main/${relativePath}`}>
                                Edit this page
                            </a>
                        </div>
                        <div className="max-w-screen-md prose dark-mode:prose-dark dark:text-gray-300 pb-10">
                            <MDXProvider components={components}>
                                <MDXRenderer>{body}</MDXRenderer>
                            </MDXProvider>
                        </div>
                    </div>

                    <div className="hidden sticky top-24 text-sm xl:block border-l-4 dark:border-gray-600 w-full pl-4 border-gray-200 transition duration-300 ease-in-out mb-6 h-fc">
                        {buildContentList(headings, true)}

                        <hr className="w-full border-1 dark:border-gray-600 border my-2" />
                        <a className="text-sm" href={`https://github.com/rocky-linux/documentation/blob/main/${relativePath}`}>
                            Edit this page
                        </a>
                    </div>
                </div>
            </Container>
        </Page>
    );
};

export default contentPage;