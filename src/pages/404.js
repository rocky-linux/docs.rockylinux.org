import * as React from 'react';
import { Link } from 'gatsby';
import Page from '../components/Page';

export default () => {
    return (
        <Page meta={{ title: 'Not found' }}>
            <h1>Page not found</h1>
            <p>
                Sorry{' '}
                <span role="img" aria-label="Pensive emoji">
                    😔
                </span>{' '}
                we couldn’t find what you were looking for.
                <br />
                {process.env.NODE_ENV === 'development' ? (
                    <>
                        <br />
                        Try creating a page in <code>src/pages/</code>.
                        <br />
                    </>
                ) : null}
                <br />
                <Link to="/">Go home</Link>.
            </p>
        </Page>
    );
};
