import * as React from "react";

/**
 * A wrapper box that constrains the width of the content.
 */
export default ({ children }) => {
    return (
        <div className="max-w-screen-lg w-full mx-auto px-4 pt-10 lg:px-0">
            {children}
        </div>
    );
};