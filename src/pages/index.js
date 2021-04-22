import { Link } from 'gatsby';
import * as React from 'react';
import Page from '../components/Page';

const IndexPage = () => {
    return (
        <Page meta={{ title: 'Home' }}>
            <div className="h-56 text-center">
                <h1 className="mb-4 text-gray-800">Rocky Linux Documentation</h1>
                <p className="text-normal md:text-xl text-gray-400 mb-8">The home of all Rocky Linux documentation.</p>
                <Link to="/site-index" className="p-4 bg-green-500 rounded-lg text-md font-bold text-white inline shadow-lg border-2 border-green-600">Go to index</Link> 
            </div>
        </Page>
    );
};

export default IndexPage;