import { Link } from 'gatsby';
import { MDXRenderer } from 'gatsby-plugin-mdx';
import { MDXProvider } from '@mdx-js/react';
import * as React from 'react';
import Page from '../components/Page';

const components = { Link };

const buildContentList = (headings, topLevel) => {
    return (
        <ul className={`list-inside${topLevel ? '' : ' pl-4'}`}>
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

export default ({ pageContext: { frontmatter, headings, body } }) => {
    return (
        <Page wide meta={{ title: frontmatter.title }}>
            <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
                <div>
                    <h4 className="text-lg mb-2 font-bold">Manuals</h4>
                    <ul className="text-base">
                        <li className="font-bold tracking-widest text-gray-600 text-sm uppercase mt-4">
                            Getting Started
                        </li>
                        <li>
                            <Link
                                className="py-1 px-2 block hover:bg-green-200 dark:hover:text-white hover:bg-opacity-30 transition duration-100 ease-in-out rounded"
                                activeClassName="bg-green-200 hover:bg-green-200 font-bold dark:text-black"
                                to="/manuals/install/"
                            >
                                Installation
                            </Link>
                        </li>
                        <li className="font-bold tracking-widest text-gray-600 text-sm uppercase mt-4">
                            Software
                        </li>
                        <li>
                            <Link
                                className="py-1 px-2 block hover:bg-green-200 dark:hover:text-white hover:bg-opacity-30 transition duration-100 ease-in-out rounded"
                                activeClassName="bg-green-200 hover:bg-green-200 font-bold dark:text-black"
                                to="/manuals/ssh-keygen/"
                            >
                                An overview of ssh-keygen
                            </Link>
                        </li>
                    </ul>
                </div>

                <div className="md:col-span-2 lg:col-span-3 xl:col-span-3">
                    <div
                        className="block xl:hidden border-l-4 w-full pl-4 border-gray-200 transition duration-300 ease-in-out mb-6"
                        style={{ height: 'fit-content' }}
                    >
                        <b className="mb-2">Page Contents</b>
                        {buildContentList(headings, true)}
                    </div>
                    <div className="max-w-screen-md prose dark-mode:prose-dark dark:text-gray-300 pb-10">
                        <MDXProvider components={components}>
                            <MDXRenderer>{body}</MDXRenderer>
                        </MDXProvider>
                    </div>
                </div>

                <div
                    className="hidden xl:block border-l-4 dark:border-gray-600 w-full pl-4 border-gray-200 transition duration-300 ease-in-out mb-6"
                    style={{ height: 'fit-content' }}
                >
                    <b className="mb-2">Page Contents</b>
                    {buildContentList(headings, true)}
                </div>
            </div>
        </Page>
    );
};
