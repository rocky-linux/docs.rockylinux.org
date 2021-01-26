import * as React from "react";
import Navbar from '../Navbar';

export default ({ children, title }) => {
    return (
        <>
            <Navbar />
            <main>
                {children}
            </main>
        </>
    );
};
