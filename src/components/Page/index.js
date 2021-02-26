import * as React from 'react';
import { Helmet } from 'react-helmet';
import Container from '../Container';
import Footer from '../Footer';
import Navbar from '../Navbar';

/**
 * @interface PageMetaObject
 * @param {string} title The title of the page
 */

/**
 * @interface PageOptions
 * @property {import("react").ReactChildren} children The elements to render on the page
 * @property {PageMetaObject} meta The metadata to load into the page.
 */

/**
 * A default page container, used to template other pages in the site.
 *
 * @param {PageOptions} options The options to instantiate the site with.
 * @param {boolean} wide Whether the page should be wider than usual
 * @param {boolean} ultrawide Whether the page should take up the width of the viewport
 */
export default ({
    children,
    wide,
    ultrawide,
    meta: { title, description, keywords },
}) => {
    return (
        <>
            <Helmet>
                <title>{title} - Rocky Linux Documentation</title>

                <meta
                    name="description"
                    content={
                        description
                            ? description
                            : 'The documentation for Rocky Linux, the community-driven enterprise operating system.'
                    }
                />
                <meta
                    name="keywords"
                    content={
                        keywords
                            ? keywords
                            : 'rocky linux, documentation, docs, tutorials, learning, linux, sysadmin'
                    }
                />
            </Helmet>
            <Navbar ultrawide={ultrawide} />
            <main className="dark:bg-gray-900 dark:text-gray-300 bg-white flex-grow mt-14">
                <Container ultrawide={ultrawide} wide={wide}>
                    {children}
                </Container>
            </main>
            <Footer />
        </>
    );
};
